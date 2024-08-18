import 'package:reactive_notify/src/singleton_states.dart';
import 'package:reactive_notify/src/u_key.dart';

/// [ReactiveNotifyCallback] is a class that extends `SingletonState` to manage global state reactively,
/// with an additional callback function that gets executed whenever the state changes.
/// It ensures that only a single instance of state per type exists, providing methods to set and reset the state.
///
/// Example usage:
/// ```dart
/// final connectionState = ReactiveNotifyCallback<ConnectionElement>(
///   ConnectionElement.connected,
///   onStateChange: (newState) {
///     print("State changed to $newState");
///     return newState; // You can modify the state here if needed
///   },
/// );
///
/// // Access and modify the state
/// connectionState.setState(ConnectionElement.error);
/// print(connectionState.value); // Output: ConnectionElement.error
/// ```
class ReactiveNotifyCallback<T> extends SingletonState<T> {
  static final Map<UKey, ReactiveNotifyCallback> _instances = {};

  /// The default value of the state, initialized at the time of instance creation.
  final T _defaultValue;

  /// A callback function that gets executed whenever the state changes.
  final T Function(T newState)? _onStateChange;

  /// Private constructor to initialize the default value of the state and the callback function.
  ReactiveNotifyCallback.state(this._defaultValue, this._onStateChange)
      : super(_defaultValue);

  /// Factory constructor to create and manage a single instance of `ReactiveNotifyCallback` per type.
  ///
  /// This constructor takes an initial value and an optional callback function that gets executed whenever the state changes.
  /// If an instance for the given type already exists, it returns the existing instance.
  /// Otherwise, it creates a new instance with the initial value and callback function.
  ///
  /// Example:
  /// ```dart
  /// final connectionState = ReactiveNotifyCallback<ConnectionElement>(
  ///   ConnectionElement.connected,
  ///   onStateChange: (newState) {
  ///     print("State changed to $newState");
  ///     return newState;
  ///   },
  /// );
  /// ```
  ///
  factory ReactiveNotifyCallback(T initialValue,
      {T Function(T newState)? onStateChange}) {
    UKey key = UKey();
    if (_instances[key] == null) {
      _instances[key] =
          ReactiveNotifyCallback<T>.state(initialValue, onStateChange);
    }
    return _instances[key] as ReactiveNotifyCallback<T>;
  }

  /// Sets a new value to the state, executes the callback function if provided, and notifies listeners.
  ///
  /// Example:
  /// ```dart
  /// connectionState.setState(ConnectionElement.error);
  /// print(connectionState.value); // Output: ConnectionElement.error
  /// ```
  @override
  void setState(T newValue) {
    value = newValue;
    if (_onStateChange != null) {
      value = _onStateChange.call(newValue);
    }

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
    notifyListeners();
  }

  /// Manually triggers the callback function with the current state value.
  ///
  /// This can be useful for forcing an update or re-executing the state change logic without actually changing the state.
  ///
  /// Example:
  /// ```dart
  /// connectionState.update();
  /// ```
  void update() {
    if (value != null) {
      _onStateChange?.call(value);
    }
    notifyListeners();
  }

  @override
  void when(
      {required T Function() newState,
      required void Function() onCompleteState,
      void Function(Object error, StackTrace stackTrace)? onError}) {
    /// Contain validation if value was changed
    setState(newState());

    try {
      onCompleteState.call();
    } catch (error, stackTrace) {
      if (onError != null) {
        onError(error, stackTrace);
      }
    }
  }
}
