import 'dart:async';
import 'dart:developer';

/// Type of async data
enum AsyncStatus {loading, error, success, refreshing}

/// State of asynd ata, example, success, error, etc
/// this async state shouldbe inside of asynNotifier for value of type AsyncState.
class AsyncState<T> {

  AsyncStatus? status;
  T? data;
  AsyncError? error;

  AsyncState.error(this.error) :
        data = null,
        status =  AsyncStatus.error;

  AsyncState.success(this.data) :
        error = null,
        status = AsyncStatus.success;

  AsyncState.loading() :
        status = AsyncStatus.loading,
        error = null,
        data = null;

  AsyncState.refreshing() :
        status = AsyncStatus.refreshing,
        error = null,
        data = null;

  R on<R>({
    required R Function(T? data, AsyncStatus? status) data,
    required R Function(AsyncError error) error,
    required R Function() loading
  }){

    try{

      if(status == AsyncStatus.success) return data(this.data, null);
      if(status == AsyncStatus.refreshing) return data( null, this.status);

      return loading();

    }catch(err, stackTrace){

      log("Error on data from async state");

      return error(AsyncError(err, stackTrace));

    }

  }

}