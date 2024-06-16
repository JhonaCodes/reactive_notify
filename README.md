# Reactive State Management Library

[![Dart 3](https://img.shields.io/badge/Dart-3%2B-blue.svg)](https://dart.dev/)
[![Flutter 3.10](https://img.shields.io/badge/Flutter-3%2B-blue.svg)](https://flutter.dev/)
[![Pub Package](https://img.shields.io/pub/v/reactive.svg)](https://pub.dev/packages/info_label)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

![reactive_state](https://github.com/JhonaCodes/reactive/assets/53523825/0fe206c0-3d63-4fc0-9516-b76c320110a8)


A Flutter library for managing reactive state efficiently, supporting multiple independent instances with unique keys.

## Description

This library provides a flexible and efficient way to manage reactive state in Dart and Flutter applications. It supports multiple independent instances of state using unique keys, ensuring that each state instance is unique and does not interfere with others.

## Features

- **Reactive State Management**: Manage state reactively and efficiently.
- **Multiple Independent Instances**: Support for multiple instances of the same state type using unique keys.
- **Singleton State**: Ensure a single source of truth for each state instance.
- **Reset State**: Easily reset the state to its default value.

## Installation

Add the following dependency to your `pubspec.yaml` file:


```yaml
dependencies:
  reactive: ^1.0.0
```

## Usage

### Creating a Reactive State

```dart
import 'package:reactive_notify/reactive_notify.dart';

  ReactiveState<int> _state1 = ReactiveState<int>(() => 0);
  ReactiveState<int> _state2 = ReactiveState<int>(() => 1);

void main() {

  print(_state1.value); // Output: 0
  print(_state2.value); // Output: 1

  _state1.setState(5);
  print(_state1.value); // Output: 5
  print(_state2.value); // Output: 1
}
```

### Using Reactive Builder

Use `ReactiveBuilder` to build widgets that react to state changes.

```dart
import 'package:flutter/material.dart';
import 'package:reactive/reactive_notify.dart';

ReactiveState<int> state = ReactiveState<int>(() => 0);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Reactive State Example')),
        body: Column(
          children: [
            ReactiveBuilder<int>(
              valueListenable: state,
              builder: (context, value) {
                return Text('Value: $value');
              },
            ),
            ElevatedButton(
              onPressed: () {
                state.setState(state.value + 1);
              },
              child: Text('Increment'),
            ),
          ],
        ),
      ),
    );
  }
}
```

I recommend declaring your reactive states as global variables.
YOU DON'T NEED TO USE THEM IN THE BUILDER, if you want to use them only for one class,
use a hidden global variable, `ReactiveState<int> _myLocalVariable = ReactiveState<int>(0)`

### Resetting State

You can reset the state to its default value.

```dart
state.resetState();
print(state.value); // Output: initial value
```

## API Reference

### `ReactiveState`

#### Constructor

```dart
factory ReactiveState(T Function() initialValue)
```

Creates a new instance of `ReactiveState` with a unique key and an initial value.

#### Methods

- `setState(T newValue)`: Sets a new value to the state and notifies listeners.
- `resetState()`: Resets the state to its default value.

### `ReactiveBuilder`

A widget that listens to a `ValueListenable` and rebuilds itself when the value changes.

#### Constructor

```dart
ReactiveBuilder({
  required ValueListenable<T> valueListenable,
  required Widget Function(BuildContext context, T value) builder,
  bool cleanStateOnDispose = false,
})
```

- `valueListenable`: The state to listen to.
- `builder`: The builder function that takes the current context and state value.
- `cleanStateOnDispose`: Whether to reset the state when the widget is disposed.


## Use case, `Example`
A very simple use case, interacting between different reactive states and generating a separate render in the same widget.
```dart
import 'package:flutter/material.dart';
import 'package:reactive/reactive_notify.dart';

enum ConnectionState {
  connected,
  unconnected,
  connecting,
  error,
  uploading,
  waiting,
  signalOff,
  errorOnSynchronized,
  synchronizing,
  synchronized,
  waitingForSynchronization
}


/// Test for current state [ReactiveState].
final reactiveConnectionState = ReactiveState<ConnectionState>(() {
  /// You can put any code for initial value.
  return ConnectionState.signalOff;
});


/// Test for current state [ReactiveStateCallback].
final reactiveCallbackConnectionState = ReactiveStateCallback<ConnectionState>(
  ConnectionState.waiting,
  onStateChange: (value) {
    /// You can put any validation or use another Reactive functions.
    if (reactiveConnectionState.value == ConnectionState.unconnected) {
      value = ConnectionState.error;
    }

    return value;
  },
);


/// Test for current state [ReactiveStateInitializerCallback].
final reactiveStateInitializerCallback = ReactiveStateInitializerCallback<ConnectionState>(initializer: () {
  if (reactiveConnectionState.value == ConnectionState.signalOff ||
      reactiveCallbackConnectionState.value == ConnectionState.error) {
    return ConnectionState.errorOnSynchronized;
  }

  return ConnectionState.waitingForSynchronization;
}, onStateChange: (state) {
  if (reactiveConnectionState.value == ConnectionState.connected) {
    state = ConnectionState.synchronizing;
  }

  if (reactiveCallbackConnectionState.value == ConnectionState.error) {
    state = ConnectionState.errorOnSynchronized;
  }

  return state;
});




void main() {
  /// Ensure flutter initialized.
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
      MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (BuildContext context) => const MyApp(),
        },
      ),
  );

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ReactiveState'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 1. [ReactiveState] Current connection state
            ReactiveBuilder(
              valueListenable: reactiveConnectionState,
              builder: (context, state) {
                bool isConnected = state == ConnectionState.connected;
                return Chip(
                  label: Text(
                    state.name,
                  ),
                  avatar: Icon(
                    Icons.wifi,
                    color: isConnected ? Colors.green : Colors.red,
                  ),
                );
              },
            ),

            /// 2. Depend of connection for upload any file.
            ReactiveBuilder(
              valueListenable: reactiveCallbackConnectionState,
              builder: (context, state) {
                bool isConnected = state == ConnectionState.uploading;

                return Chip(
                  label: Text(
                    state.name,
                  ),
                  avatar: Icon(
                    Icons.cloud_download,
                    color: isConnected ? Colors.green : Colors.red,
                  ),
                );
              },
            ),

            /// 3. Depend of connection for upload any file.
            ReactiveBuilder(
              valueListenable: reactiveStateInitializerCallback,
              builder: (context, state) {
                bool isConnected = state != ConnectionState.errorOnSynchronized;
                return Chip(
                  label: Text(
                    "${state?.name}",
                  ),
                  avatar: Icon(
                    Icons.sync,
                    color: isConnected ? Colors.green : Colors.red,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: OutlinedButton(
        onPressed: () {
          /// Variation unconnected and connected.
          reactiveConnectionState.setState(reactiveConnectionState.value == ConnectionState.connected
              ? ConnectionState.unconnected
              : ConnectionState.connected);

          /// Try to connecting but the internal validation make error if reactiveConnectionState is unconnected.
          reactiveCallbackConnectionState.setState(ConnectionState.uploading);

          /// Try to synchronizing butt first make a internal validation
          reactiveStateInitializerCallback.setState(ConnectionState.synchronizing);
        },
        child: const Text('ReactiveState'),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
```

## Visual State

https://github.com/JhonaCodes/reactive/assets/53523825/d5052146-7b2c-40f2-97c3-1017fd716722


## Simple performance test.
It is possibly not the best test, but it generates a general idea.

https://github.com/JhonaCodes/reactive/assets/53523825/102f8d2a-d21b-4e40-b04f-c6313083ae57


This library is not intended to replace any state management solution. Instead, it aims to address certain challenges in managing reactive elements. It provides a simple, clean, lightweight, and quick solution for those situations where you need efficient state management without the need to learn the intricacies of a more robust library.


Contributions and comments are welcome 🤗.
