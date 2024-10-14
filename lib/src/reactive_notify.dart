import 'package:flutter/material.dart';

import 'implements/notifier_impl.dart';

import 'package:flutter/foundation.dart';


class ReactiveNotify<T> extends NotifierImpl<T> {
  static final Map<Key, dynamic> _instances = {};
  static final Set<ReactiveNotify> _updatingNotifiers = {};

  ReactiveNotify._(super.initialState);

  factory ReactiveNotify(T Function() initialValue, {Key? keys}) {
    Key key = keys ?? UniqueKey();
    if (_instances[key] == null) {
      _instances[key] = ReactiveNotify._(initialValue());
    }
    return _instances[key] as ReactiveNotify<T>;
  }

  @override
  void setState(T newState) {
    if (state != newState && !_updatingNotifiers.contains(this)) {
      _updatingNotifiers.add(this);
      try {
        super.setState(newState);
      } finally {
        _updatingNotifiers.remove(this);
      }
    }
  }

  static void cleanup() {
    _instances.clear();
    _updatingNotifiers.clear();
  }

  static int get instanceCount => _instances.length;

  static int instanceCountByType<S>() {
    return _instances.values.whereType<ReactiveNotify<S>>().length;
  }
}