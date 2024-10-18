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
    _setState(AsyncState.loading());
    try {
      final result = await fetchData();
      _setState(AsyncState.success(result));
    } catch (e) {
      _setState(AsyncState.error(e));
    }
  }

  void _setState(AsyncState<T> newState) {
    _state = newState;
    notifyListeners();
  }

  Future<T> fetchData();
}


