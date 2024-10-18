import 'package:flutter/material.dart';
import 'package:reactive_notify/src/handler/async_state.dart';

class ReactiveAsyncBuilder<T> extends StatelessWidget {
  final AsyncViewModel<T> viewModel;
  final Widget Function(T data) buildSuccess;
  final Widget Function()? buildLoading;
  final Widget Function(Object? error, StackTrace? stackTrace)? buildError;
  final Widget Function()? buildInitial;

  const ReactiveAsyncBuilder({
    super.key,
    required this.viewModel,
    required this.buildSuccess,
    this.buildLoading,
    this.buildError,
    this.buildInitial,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        return viewModel.state.when(
          initial: () => buildInitial?.call() ?? const SizedBox.shrink(),
          loading: () => buildLoading?.call() ?? const Center(child: CircularProgressIndicator()),
          success: (data) => buildSuccess(data),
          error: (error, stackTrace) => buildError?.call(error, stackTrace) ?? Center(child: Text('Error: $error')),
        );
      },
    );
  }
}

abstract class AsyncViewModel<T> extends ChangeNotifier {
  AsyncState<T> _state = AsyncState.initial();
  AsyncState<T> get state => _state;

  AsyncViewModel() {
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


