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
final ReactiveNotify<ConnectionState> reactiveConnectionState =
    ReactiveNotify<ConnectionState>(() {
  /// You can put any code for initial value.
  return ConnectionState.signalOff;
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
              builder: (context, state, keep) {
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
        },
        child: const Text('ReactiveNotify'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
