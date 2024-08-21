import 'package:reactive_notify/src/singleton_states.dart';
import 'package:reactive_notify/src/u_key.dart';

/// [ReactiveNotifyInitializerCallback] is a class that extends `SingletonState` to manage global state reactively,
/// with both an initializer function and a callback function that gets executed whenever the state changes.
/// It ensures that only a single instance of state per key exists, providing methods to set and reset the state.
///
/// Example usage:
/// ```dart
/// final connectionState = ReactiveNotifyInitializerCallback<ConnectionElement>(
///   initializer: () => ConnectionElement.connected,
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
class ReactiveNotifyInitializerCallback<T> extends SingletonState<T> {
  static final Map<UKey, ReactiveNotifyInitializerCallback> _instances = {};

  /// A function that initializes the state when it is first created.
  final T Function() _initializer;

  /// A callback function that gets executed whenever the state changes.
  final T Function(T newState)? _onStateChange;

  /// Private constructor to initialize the state with an initializer function and a callback function.
  ReactiveNotifyInitializerCallback.state(
      this._initializer, this._onStateChange)
      : super(_initializer()) {
    _initialize();
  }

  /// Factory constructor to create and manage a single instance of `ReactiveNotifyInitializerCallback` per key.
  ///
  /// This constructor takes an initializer function and a callback function that gets executed whenever the state changes.
  /// If an instance for the given type already exists, it returns the existing instance.
  /// Otherwise, it creates a new instance with the initializer and callback functions.
  ///
  /// Example:
  /// ```dart
  /// final connectionState = ReactiveNotifyInitializerCallback<ConnectionElement>(
  ///   initializer: () => ConnectionElement.connected,
  ///   onStateChange: (newState) {
  ///     print("State changed to $newState");
  ///     return newState;
  ///   },
  /// );
  /// ```
  factory ReactiveNotifyInitializerCallback(
      {required T Function() initializer,
      required T Function(T newState) onStateChange}) {
    UKey key = UKey();
    if (_instances[key] == null) {
      _instances[key] = ReactiveNotifyInitializerCallback<T>.state(
          initializer, onStateChange);
    }
    return _instances[key] as ReactiveNotifyInitializerCallback<T>;
  }

  /// Initializes the state using the initializer function if it has not been initialized yet.
  void _initialize() => value ??= _initializer();

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

  /// Resets the state to its default value using the initializer function.
  ///
  /// Example:
  /// ```dart
  /// connectionState.resetState();
  /// print(connectionState.value); // Output: ConnectionElement.connected
  /// ```
  @override
  void resetState() {
    value = _initializer();
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
  }

  @override
  void when(
      {required T Function() newState,
      required void Function(T data) onCompleteState,
      void Function(Object error, StackTrace stackTrace)? onError}) {

    setState(newState());

    try {
      onCompleteState.call(value);
      notifyListeners();
    } catch (error, stackTrace) {
      if (onError != null) {
        onError(error, stackTrace);
      }
    }
  }
}
