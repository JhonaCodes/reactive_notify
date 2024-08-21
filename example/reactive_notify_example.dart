import 'package:flutter/material.dart';
import 'package:reactive_notify/reactive_notify.dart';

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

/// Test for current state [ReactiveNotify].
final reactiveConnectionState = ReactiveNotify<ConnectionState>(() {
  /// You can put any code for initial value.
  return ConnectionState.signalOff;
});

/// Test for current state [ReactiveNotifyCallback].
final reactiveCallbackConnectionState = ReactiveNotifyCallback<ConnectionState>(
  ConnectionState.waiting,
  onStateChange: (value) {
    /// You can put any validation or use another Reactive functions.
    if (reactiveConnectionState.value == ConnectionState.unconnected) {
      value = ConnectionState.error;
    }

    return value;
  },
);

/// Test for current state [ReactiveNotifyInitializerCallback].
final reactiveStateInitializerCallback =
    ReactiveNotifyInitializerCallback<ConnectionState>(initializer: () {
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
        title: const Text('ReactiveNotify'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 1. [ReactiveNotify] Current connection state
            ReactiveBuilder(
              valueListenable: reactiveConnectionState,
              builder: (state) {
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
              builder: (state) {
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
              setState: (set) {
                /// Update state using setState from Stateful widget.
                set(() {});
              },
              builder: (state) {
                bool isConnected = state != ConnectionState.errorOnSynchronized;
                return Chip(
                  label: Text(
                    state.name,
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
          reactiveConnectionState.setState(
              reactiveConnectionState.value == ConnectionState.connected
                  ? ConnectionState.unconnected
                  : ConnectionState.connected);

          /// Try to connecting but the internal validation make error if reactiveConnectionState is unconnected.
          reactiveCallbackConnectionState.setState(ConnectionState.uploading);

          /// Try to synchronizing butt first make a internal validation
          reactiveStateInitializerCallback
              .setState(ConnectionState.synchronizing);
        },
        child: const Text('ReactiveNotify'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
