import 'dart:async';
import 'dart:developer';


/// State of asynd ata, example, success, error, etc
/// this async state shouldbe inside of asynNotifier for value of type AsyncState.
enum AsyncStatus { loading, error, success, refreshing }

class AsyncState<T> {
  final AsyncStatus status;
  final T? data;
  final Object? error;
  final StackTrace? stackTrace;

  AsyncState.error(this.error, this.stackTrace)
      : status = AsyncStatus.error,
        data = null;

  AsyncState.success(this.data)
      : status = AsyncStatus.success,
        error = null,
        stackTrace = null;

  AsyncState.loading()
      : status = AsyncStatus.loading,
        data = null,
        error = null,
        stackTrace = null;

  AsyncState.refreshing()
      : status = AsyncStatus.refreshing,
        data = null,
        error = null,
        stackTrace = null;

  R when<R>({
    required R Function(T data) data,
    required R Function(Object error, StackTrace? stackTrace) error,
    required R Function() loading,
    R Function()? refreshing,
  }) {
    switch (status) {
      case AsyncStatus.success:
        return data(this.data as T);
      case AsyncStatus.error:
        return error(this.error!, this.stackTrace);
      case AsyncStatus.loading:
        return loading();
      case AsyncStatus.refreshing:
        return refreshing?.call() ?? loading();
    }
  }
}
