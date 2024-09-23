import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ReactiveBuilder<T> extends StatefulWidget {
  final ValueListenable<T> valueListenable;
  final Widget Function(BuildContext context, T value, Widget Function(Widget  child) keep) builder;

  const ReactiveBuilder({
    super.key,
    required this.valueListenable,
    required this.builder,
  });

  @override
  State<ReactiveBuilder<T>> createState() => _ReactiveBuilderState<T>();
}

class _ReactiveBuilderState<T> extends State<ReactiveBuilder<T>> {
  late T value;
  final Map<String, _NoRebuildWrapper> _noRebuildWidgets = {};
  Timer? debounceTimer;

  @override
  void initState() {
    super.initState();
    value = widget.valueListenable.value;
    widget.valueListenable.addListener(_valueChanged);
  }

  @override
  void didUpdateWidget(ReactiveBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.valueListenable != widget.valueListenable) {
      oldWidget.valueListenable.removeListener(_valueChanged);
      value = widget.valueListenable.value;
      widget.valueListenable.addListener(_valueChanged);
    }
  }

  @override
  void dispose() {
    widget.valueListenable.removeListener(_valueChanged);
    debounceTimer?.cancel();
    super.dispose();
  }

  void _valueChanged() {
    // Cancel any existing timer to prevent multiple updates within the debounce period.
    debounceTimer?.cancel();

    // Start a new timer. After 100 milliseconds, update the state and rebuild the widget.
    if(isTesting) {
      debounceTimer = Timer(Duration(milliseconds: 100), () {
        setState(() {
          value = widget.valueListenable.value;
        });
      });
    }
  }

  Widget _noRebuild(Widget builder) {
    final key = builder.hashCode.toString();
    if (!_noRebuildWidgets.containsKey(key)) {
      _noRebuildWidgets[key] = _NoRebuildWrapper(builder: builder);
    }
    return _noRebuildWidgets[key]!;
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, value, _noRebuild);
  }
}


class _NoRebuildWrapper extends StatefulWidget {
  final Widget  builder;

  const _NoRebuildWrapper({required this.builder});

  @override
  _NoRebuildWrapperState createState() => _NoRebuildWrapperState();
}

class _NoRebuildWrapperState extends State<_NoRebuildWrapper> {
  late Widget child;

  @override
  void initState() {
    super.initState();
    child = widget.builder;
  }

  @override
  Widget build(BuildContext context) => child;
}


bool get isTesting {
  return const bool.fromEnvironment('dart.vm.product') == false;
}