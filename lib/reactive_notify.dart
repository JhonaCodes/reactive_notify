/// A library for managing reactive state in Flutter applications.
///
/// This library provides classes and widgets to manage state reactively,
/// ensuring a single instance of state per type and allowing for state
/// changes to trigger UI updates efficiently.

library reactive;

/// Export the base [ReactiveNotify] class which provides basic state management functionality.
export 'src/reactive_notify.dart';

/// Export the [ReactiveBuilder] widget which listens to a [ReactiveNotify] and rebuilds
/// itself whenever the value changes.
export 'src/builder/reactive_builder.dart';

/// Export the [AsyncState]
export 'src/handler/async_state.dart';

/// Export [ReactiveAsyncBuilder] and [ReactiveStreamBuilder]
export 'src/builder/reactive_async_builder.dart';
export 'src/builder/reactive_stream_builder_impl.dart';

/// Export ViewModelImpl
export 'src/viewmodel/viewmodel_impl.dart';
export 'src/viewmodel/async_viewmodel_impl.dart';

/// Export RepositoryImpl
export 'src/implements/repository_impl.dart';

/// Export ServiceImpl
export 'src/implements/service_impl.dart';
