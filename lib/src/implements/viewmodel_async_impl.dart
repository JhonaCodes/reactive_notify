import 'dart:developer';


import 'package:reactive_notify/src/handler/async_state.dart';
import 'package:reactive_notify/src/implements/repository_impl.dart';

import 'notifier_impl.dart';

abstract class ViewModelAsyncImpl<T> extends NotifierImpl<AsyncState<T>> {
  final RepositoryImpl _repository;

  ViewModelAsyncImpl(this._repository) : super(AsyncState<T>.loading()) {
    _initialization();
  }

  Future<T> fetchData();

  bool _initialized = false;

  Future<void> _initialization() async {
    if (!_initialized) {
      log('ViewmodelAsyncImpl.asyncInit');
      await refresh();
      _initialized = true;
    }
  }

  Future<void> refresh() async {
    try {
      state = AsyncState<T>.refreshing();

      final result = await fetchData();

      state = AsyncState<T>.success(result);

    } catch (e, stackTrace) {
      state = AsyncState<T>.error(e, stackTrace);

    }

  }

  Future<void> invalidate() async {
    _initialized = false;
    await _initialization();
  }

  R when<R>({
    required R Function(T data) data,
    required R Function(Object error, StackTrace? stackTrace) error,
    required R Function() loading,
    R Function()? refreshing,
  }) {
    return state.when(
      data: data,
      error: error,
      loading: loading,
      refreshing: refreshing,
    );
  }
}
