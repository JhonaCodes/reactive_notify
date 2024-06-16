/// A library for managing reactive state in Flutter applications.
///
/// This library provides classes and widgets to manage state reactively,
/// ensuring a single instance of state per type and allowing for state
/// changes to trigger UI updates efficiently.

library reactive;

/// Export the base [ReactiveNotify] class which provides basic state management functionality.
export 'src/reactive_notify.dart';

/// Export the [ReactiveNotifyCallback] class which extends `ReactiveNotify` to include
/// a callback function that gets executed whenever the state changes.
export 'src/reactive_notify_callback.dart';

/// Export the [ReactiveNotifyInitializerCallback] class which extends `ReactiveNotify`
/// to include an initializer function and a callback function for state changes.
export 'src/reactive_notify_initializer_callback.dart';

/// Export the [ReactiveBuilder] widget which listens to a [ReactiveNotify] and rebuilds
/// itself whenever the value changes.
export 'src/reactive_notify_builder.dart';
