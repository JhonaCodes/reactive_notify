import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:reactive_notify/src/handler/async_state.dart';
import 'package:reactive_notify/src/implements/repository_impl.dart';
import 'package:reactive_notify/src/tracker/state_tracker.dart';

import 'notifier_impl.dart';

abstract class ViewModelAsyncImpl<T> extends NotifierImpl<AsyncState<T>> {
  final String? _id;
  final String? _location;
  final RepositoryImpl _repository;

  ViewModelAsyncImpl(this._repository, super._data, this._id, this._location) {
    _initialization();
    if (!kReleaseMode && (_id != null && _location != null)) {
      StateTracker.setLocation(_id, _location);
    }
  }

  Future<T> init();

  bool _initialized = false;
  Future<void> _initialization() async {
    if (!_initialized) {
      log('ViewmodelAsyncI.asyncInit');

      await init();

      _initialized = true;
    }
  }
}
