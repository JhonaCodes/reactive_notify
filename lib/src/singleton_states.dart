import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

/// [SingletonState] is an abstract class that extends `ValueNotifier` to provide a base for managing global state reactively.
/// It ensures that any subclass will implement the methods to set and reset the state.
/// This class is designed to be inherited by other classes that require singleton state management.
///
/// Example usage:
/// ```dart
/// class MyAppState extends SingletonState<int> {
///   MyAppState(int value) : super(value);
///
///   @override
///   void setState(int newValue) {
///     value = newValue;
///   }
///
///   @override
///   void resetState() {
///     value = 0;
///   }
/// }
///
/// final appState = MyAppState(10);
/// appState.setState(20);
/// print(appState.value); // Output: 20
/// appState.resetState();
/// print(appState.value); // Output: 0
/// ```
@protected
abstract class SingletonState<T> extends ValueNotifier<T> {
  /// Constructor for initializing the state with an initial value.
  SingletonState(super.value);

  /// Abstract method to set a new value to the state.
  ///
  /// Subclasses must implement this method to update the state value.
  ///
  /// Example:
  /// ```dart
  /// void setState(T newValue) {
  ///   value = newValue;
  /// }
  /// ```
  void setState(T newValue);

  /// Abstract method to reset the state to its default value.
  ///
  /// Subclasses must implement this method to reset the state value.
  ///
  /// Example:
  /// ```dart
  /// void resetState() {
  ///   value = defaultValue;
  /// }
  /// ```
  void resetState();

  /// Abstract method where you can execute callback on finish setState.
  ///
  /// Subclasses must implement this method to reset the state value.
  /// Example"
  /// ```dart
  /// void when(T newValue, void Function() onCompleteSetState){
  ///   value = newValue;
  ///   assert(value == newValue);
  ///   onCompleteSetState.call();
  /// }
  /// ```
  ///
  void when(BuildContext context,T newValue,
      {required void Function(BuildContext context) onCompleteSetState});
}
