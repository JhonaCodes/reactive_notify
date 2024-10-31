import 'dart:async';

import 'package:flutter/material.dart';
import 'package:reactive_notify/src/reactive_notify.dart';

class ReactiveStreamBuilder<T> extends StatefulWidget {
  final ReactiveNotify<Stream<T>> streamNotifier;
  final Widget Function(T data) buildData;
  final Widget Function()? buildLoading;
  final Widget Function(Object error)? buildError;
  final Widget Function()? buildEmpty;
  final Widget Function()? buildDone;

  const ReactiveStreamBuilder({
    super.key,
    required this.streamNotifier,
    required this.buildData,
    this.buildLoading,
    this.buildError,
    this.buildEmpty,
    this.buildDone,
  });

  @override
  State<ReactiveStreamBuilder<T>> createState() => _ReactiveStreamBuilderState<T>();
}

class _ReactiveStreamBuilderState<T> extends State<ReactiveStreamBuilder<T>> {
  StreamSubscription<T>? _subscription;
  StreamState<T> _state = StreamState<T>.initial();

  @override
  void initState() {
    super.initState();
    widget.streamNotifier.addListener(_onStreamChanged);
    _subscribe(widget.streamNotifier.value);
  }

  @override
  void dispose() {
    widget.streamNotifier.removeListener(_onStreamChanged);
    _unsubscribe();
    super.dispose();
  }

  void _onStreamChanged() {
    _unsubscribe();
    _subscribe(widget.streamNotifier.value);
  }

  void _subscribe(Stream<T> stream) {
    setState(() => _state = StreamState.loading());

    _subscription = stream.listen(
          (data) => setState(() => _state = StreamState.data(data)),
      onError: (error) => setState(() => _state = StreamState.error(error)),
      onDone: () => setState(() => _state = StreamState.done()),
    );
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  Widget build(BuildContext context) {
    return _state.when(
      initial: () => widget.buildEmpty?.call() ?? const SizedBox.shrink(),
      loading: () => widget.buildLoading?.call() ??
          const Center(child: CircularProgressIndicator.adaptive()),
      data: (data) => widget.buildData(data),
      error: (error) => widget.buildError?.call(error) ??
          Center(child: Text('Error: $error')),
      done: () => widget.buildDone?.call() ?? const SizedBox.shrink(),
    );
  }
}

sealed class StreamState<T> {
  const StreamState();

  const factory StreamState.initial() = _StreamStateInitial;
  const factory StreamState.loading() = _StreamStateLoading;
  const factory StreamState.data(T data) = _StreamStateData;
  const factory StreamState.error(Object error) = _StreamStateError;
  const factory StreamState.done() = _StreamStateDone;

  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) data,
    required R Function(Object error) error,
    required R Function() done,
  });
}

class _StreamStateInitial<T> extends StreamState<T> {
  const _StreamStateInitial();

  @override
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) data,
    required R Function(Object error) error,
    required R Function() done,
  }) => initial();
}

class _StreamStateLoading<T> extends StreamState<T> {
  const _StreamStateLoading();

  @override
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) data,
    required R Function(Object error) error,
    required R Function() done,
  }) => loading();
}

class _StreamStateData<T> extends StreamState<T> {
  final T data;
  const _StreamStateData(this.data);

  @override
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) data,
    required R Function(Object error) error,
    required R Function() done,
  }) => data(this.data);
}

class _StreamStateError<T> extends StreamState<T> {
  final Object error;
  const _StreamStateError(this.error);

  @override
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) data,
    required R Function(Object error) error,
    required R Function() done,
  }) => error(this.error);
}

class _StreamStateDone<T> extends StreamState<T> {
  const _StreamStateDone();

  @override
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) data,
    required R Function(Object error) error,
    required R Function() done,
  }) => done();
}