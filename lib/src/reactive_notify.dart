import 'package:flutter/cupertino.dart';
import 'package:reactive_notify/src/singleton_states.dart';
import 'package:reactive_notify/src/u_key.dart';

/// [ReactiveNotify] is a class that extends `SingletonState` to manage global state reactively.
/// It ensures that only a single instance of state per key exists, providing methods to set and reset the state.
///
/// Example usage:
/// ```dart
/// final connectionState = ReactiveNotify<ConnectionElement>(() => ConnectionElement.connected);
///
/// // Access and modify the state
/// connectionState.setState(ConnectionElement.error);
/// print(connectionState.value); // Output: ConnectionElement.error
/// ```
class ReactiveNotify<T> extends SingletonState<T> {
  static final Map<UKey, dynamic> _instances = {};

  /// The default value of the state, initialized at the time of instance creation.
  final T _defaultValue;

  /// Private constructor to initialize the default value of the state.
  ReactiveNotify.state(this._defaultValue) : super(_defaultValue);

  /// Factory constructor to create and manage a single instance of `ReactiveNotify` per key.
  ///
  /// This constructor takes a function that returns the initial value of the state.
  /// If an instance for the given key already exists, it returns the existing instance.
  /// Otherwise, it creates a new instance with the initial value.
  ///
  /// Example:
  /// ```dart
  /// final connectionState = ReactiveNotify<ConnectionElement>(() => ConnectionElement.connected);
  /// ```
  factory ReactiveNotify(T Function() initialValue) {
    UKey key = UKey();
    if (_instances[key] == null) {
      _instances[key] = ReactiveNotify<T>.state(initialValue());
    }
    return _instances[key] as ReactiveNotify<T>;
  }

  /// Sets a new value to the state and notifies listeners.
  ///
  /// Example:
  /// ```dart
  /// connectionState.setState(ConnectionElement.error);
  /// print(connectionState.value); // Output: ConnectionElement.error
  /// ```
  @override
  void setState(T newValue) {
    value = newValue;
    assert(value == newValue, "Was impossible to change previous state");
    notifyListeners();
  }

  /// Resets the state to its default value.
  ///
  /// Example:
  /// ```dart
  /// connectionState.resetState();
  /// print(connectionState.value); // Output: ConnectionElement.connected
  /// ```
  @override
  void resetState() {
    value = _defaultValue;

    /// Ensure current value was reset.
    assert(value == _defaultValue, "Was impossible to reset current state");

    notifyListeners();
  }


  @override
  void when(BuildContext context,T newValue,
      {required void Function(BuildContext context) onCompleteSetState}) {

    /// Contain validation if value was changed
    setState(newValue);

    assert(context.mounted, "The context is not mounted, verify any async process\nThe context should be mounted then you can continue");
    /// Ensure the context is mounted for execute callback [onCompleteSetState]
    onCompleteSetState.call(context);

  }
}
