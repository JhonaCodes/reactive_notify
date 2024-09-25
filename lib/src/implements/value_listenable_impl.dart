import 'package:flutter/foundation.dart';

@protected
abstract class ValueListenableImpl<T> extends Listenable {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const ValueListenableImpl();

  /// The current value of the object. When the value changes, the callbacks
  /// registered with [addListener] will be invoked.
  T get model;
}
