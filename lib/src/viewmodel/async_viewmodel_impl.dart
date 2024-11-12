import 'package:flutter/material.dart';
import 'package:reactive_notify/src/handler/async_state.dart';

abstract class AsyncViewModelImpl<T> extends ChangeNotifier {
  AsyncState<T> _state = AsyncState.initial();
  AsyncState<T> get state => _state;

  AsyncViewModelImpl() {
    _initialize();
  }

  Future<void> _initialize() async {
    await reload();
  }

  Future<void> reload() async {
    setStateLoading();
    try {
      final result = await fetchData();
      setStateSuccess(result);
    } catch (e) {
      setStateError(e);
    }
  }

  // Change state methods
  @protected
  void setStateInitial() {
    _setState(AsyncState.initial());
  }

  @protected
  void setStateLoading() {
    _setState(AsyncState.loading());
  }

  @protected
  void setStateSuccess(T data) {
    _setState(AsyncState.success(data));
  }

  @protected
  void setStateError(Object error) {
    _setState(AsyncState.error(error));
  }

  void _setState(AsyncState<T> newState) {
    _state = newState;
    notifyListeners();
  }

  Future<T> fetchData();
}
