import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:reactive_notify/src/singleton_states.dart';

/// [ReactiveBuilder] is a widget that listens to a [ReactiveState] and rebuilds itself
/// whenever the value changes. It also provides an option to reset the state to its default
/// value when the widget is disposed.
///
/// Example usage:
/// ```dart
/// final connectionState = ReactiveState<ConnectionElement>(() => ConnectionElement.connected);
///
/// ReactiveBuilder<ConnectionElement>(
///   valueListenable: connectionState,
///   cleanStateOnDispose: true,
///   builder: (context, value) {
///     switch (value) {
///       case ConnectionElement.error:
///         return Container(child: Text('Un error Grave'), color: Colors.red);
///       case ConnectionElement.connected:
///         return Text("Está conectado");
///       default:
///         return Text('AMor eso no es');
///     }
///   },
/// );
/// ```
class ReactiveBuilder<T> extends StatefulWidget {
  /// The [ReactiveState] whose value you depend on in order to build.
  ///
  /// This widget does not ensure that the [ReactiveState]'s value is not
  /// null, therefore your [builder] may need to handle null values.
  final ValueListenable<T> valueListenable;

  /// A flag to determine if the state should be reset to its default value when the widget is disposed.
  final bool cleanStateOnDispose;

  /// The builder function which builds a widget depending on the [valueListenable]'s value.
  final Widget Function(BuildContext context, T value) builder;

  /// Creates a [ReactiveBuilder].
  ///
  /// The [valueListenable] parameter is required and specifies the value to listen to.
  /// The [builder] parameter is required and provides the widget building logic based on the value.
  /// The [cleanStateOnDispose] parameter is optional and defaults to false.
  const ReactiveBuilder({
    super.key,
    required this.valueListenable,
    required this.builder,
    this.cleanStateOnDispose = false,
  });

  @override
  State<StatefulWidget> createState() => _ReactiveBuilderState<T>();
}

class _ReactiveBuilderState<T> extends State<ReactiveBuilder<T>> {
  late T value;
  Timer? debounceTimer;
  @override
  void initState() {
    super.initState();
    // Initialize the value from the valueListenable and start listening for changes.
    value = widget.valueListenable.value;
    widget.valueListenable.addListener(_valueChanged);
  }

  @override
  void didUpdateWidget(ReactiveBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the widget is updated, check if the valueListenable has changed.
    // If it has, remove the listener from the old valueListenable and add it to the new one.
    if (oldWidget.valueListenable != widget.valueListenable) {
      oldWidget.valueListenable.removeListener(_valueChanged);
      value = widget.valueListenable.value;
      widget.valueListenable.addListener(_valueChanged);
    }
  }

  @override
  void dispose() {
    // Remove the listener from the valueListenable.
    widget.valueListenable.removeListener(_valueChanged);

    // If cleanStateOnDispose is true and the valueListenable is a SingletonState,
    // reset the state to its default value.
    if (widget.cleanStateOnDispose) {
      if (widget.valueListenable is SingletonState<T>) {
        (widget.valueListenable as SingletonState<T>).resetState();
      }
    }
    debounceTimer?.cancel();
    super.dispose();
  }

  /// Callback method that is called whenever the value of the [valueListenable] changes.
  ///
  /// This method implements a debounce mechanism to limit the frequency of updates.
  /// When the [valueListenable] changes, any existing timer is cancelled, and a new
  /// timer is started. After the specified duration (100 milliseconds), the [setState]
  /// method is called to update the [value] and trigger a rebuild of the widget.
  ///
  /// The debounce mechanism helps to prevent excessive rebuilds when the value
  /// changes rapidly, which can improve performance and reduce unnecessary work.
  ///
  /// Example:
  /// ```dart
  /// debounceTimer?.cancel();
  /// debounceTimer = Timer(Duration(milliseconds: 100), () {
  ///   setState(() {
  ///     value = widget.valueListenable.value;
  ///   });
  /// });
  /// ```
  void _valueChanged() {
    // Cancel any existing timer to prevent multiple updates within the debounce period.
    debounceTimer?.cancel();

    // Start a new timer. After 100 milliseconds, update the state and rebuild the widget.
    debounceTimer = Timer(Duration(milliseconds: 100), () {
      setState(() {
        value = widget.valueListenable.value;
      });
    });
  }

  /// Builds the widget tree using the builder function provided.
  ///
  /// This method wraps the returned widget in a [RepaintBoundary] to isolate
  /// the repainting of this widget from its parent and siblings. This can help
  /// improve performance by reducing unnecessary repaints.
  ///
  /// The [RepaintBoundary] widget creates a separate display list for its child
  /// and prevents the child from being repainted when the parent is repainted,
  /// unless the child itself changes.
  ///
  /// The [widget.builder] function is called with the current [BuildContext] and
  /// the current value of the [ValueListenable]. The widget returned by the
  /// [widget.builder] function is wrapped in a [RepaintBoundary] and returned
  /// by this method.
  ///
  /// Example:
  /// ```dart
  /// ReactiveBuilder<String>(
  ///   valueListenable: myValueNotifier,
  ///   builder: (context, value) {
  ///     return Text(value);
  ///   },
  /// )
  /// ```
  @override
  Widget build(BuildContext context) {
    // Wrap the built widget in a RepaintBoundary to optimize performance.
    return RepaintBoundary(
      child: widget.builder(context, value),
    );
  }
}
