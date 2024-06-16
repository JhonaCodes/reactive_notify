/// A library for managing reactive state in Flutter applications.
///
/// This library provides classes and widgets to manage state reactively,
/// ensuring a single instance of state per type and allowing for state
/// changes to trigger UI updates efficiently.

library reactive;

/// Export the base [ReactiveState] class which provides basic state management functionality.
export 'src/reactive_notify.dart';

/// Export the [ReactiveStateCallback] class which extends `ReactiveState` to include
/// a callback function that gets executed whenever the state changes.
export 'src/reactive_states_callback.dart';

/// Export the [ReactiveStateInitializerCallback] class which extends `ReactiveState`
/// to include an initializer function and a callback function for state changes.
export 'src/reactive_states_initializer_callback.dart';

/// Export the [ReactiveBuilder] widget which listens to a [ReactiveState] and rebuilds
/// itself whenever the value changes.
export 'src/reactive_states_builder.dart';
