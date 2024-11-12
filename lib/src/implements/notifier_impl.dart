import 'package:flutter/foundation.dart';

@protected
abstract class NotifierImpl<T> extends ChangeNotifier
    implements ValueListenable<T> {
  T _value;
  NotifierImpl(this._value) {
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    }
  }

  @override
  T get value => _value;

  void setState(T newState) {
    if (_value == newState) {
      return;
    }

    _value = newState;
    notifyListeners();
  }

  void setValueNonState(T newState) {
    _value = newState;
  }

  @override
  String toString() => '${describeIdentity(this)}($value)';
}
