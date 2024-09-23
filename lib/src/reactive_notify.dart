import 'dart:developer';

import 'package:flutter/material.dart';

import 'implements/notifier_impl.dart';

class ReactiveNotify<T> extends NotifierImpl<T> {

  static final Map<UniqueKey, dynamic> _instances = {};

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

    UniqueKey key = UniqueKey();

    if (_instances[key] == null) {
      _instances[key] = ReactiveNotify<T>.state(initialValue());
    }

    log('ReactiveNotifier.factory instances = $_instances');

    return _instances[key] as ReactiveNotify<T>;
  }

  /// Sets a new value to the state and notifies listeners.
  ///
  /// Example:
  /// ```dart
  /// connectionState.setState(ConnectionElement.error);
  /// print(connectionState.value); // Output: ConnectionElement.error
  /// ```

  void setState(T newValue) {
    value = newValue;
    notifyListeners();
  }

  /// Resets the state to its default value.
  ///
  /// Example:
  /// ```dart
  /// connectionState.resetState();
  /// print(connectionState.value); // Output: ConnectionElement.connected
  /// ```

  void resetState() {
    value = _defaultValue;
    notifyListeners();
  }



  @override
  void dispose() {
    super.dispose();
    log('Instance ${value.runtimeType} disposed');
  }


  void cleanup(){

    _instances.clear();

    log('_instances = $_instances');
  }


}
