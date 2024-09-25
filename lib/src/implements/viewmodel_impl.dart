import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:reactive_notify/src/tracker/state_tracker.dart';
import 'repository_impl.dart';

import 'notifier_impl.dart';

abstract class ViewModelImpl<T> extends NotifierImpl<T> {
  final String? _id;
  final String? _location;

  final RepositoryImpl _repository;

  ViewModelImpl(this._repository, super._data, this._id, this._location) {
    _initialization();

    if (!kReleaseMode && (_id != null && _location != null)) {
      StateTracker.setLocation(_id, _location);
    }
  }

  void init();

  bool _initialized = false;

  void _initialization() {
    if (!_initialized) {
      log('ViewModelI.init');

      init();
      _initialized = true;
    }
  }

  @override
  set value(T newValue) {
    super.value = newValue;
    if (!kReleaseMode && _id != null) {
      StateTracker.trackStateChange(_id);
    }
  }

  void addDependencyTracker(String notifyId, String dependentId) {
    if (!kReleaseMode) {
      StateTracker.addDependency(notifyId, dependentId);
    }
  }

  void currentTracker() {
    if (!kReleaseMode && _id != null) {
      StateTracker.trackStateChange(_id);
    }
  }
}
