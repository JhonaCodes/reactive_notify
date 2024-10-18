import 'package:flutter/foundation.dart';

@protected
abstract class NotifierImpl<T> extends ChangeNotifier {
  T _state;
  NotifierImpl(this._state);

  T get state => _state;

  void setState(T newState) {
    if (_state != newState) {
      _state = newState;

    }
    notifyListeners();
  }
}