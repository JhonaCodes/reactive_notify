import 'package:flutter/material.dart';
import 'package:reactive_notify/reactive_notify.dart';

/// NOTE: The package name has been updated in favor of `reactive_notifier`.
/// For more details, check out the official package page:
/// https://pub.dev/packages/reactive_notifier


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
            ReactiveBuilder<ConnectionState>(
              valueListenable: reactiveConnectionState,
              builder: (context, state, keep) {
                bool isConnected = state == ConnectionState.connected;
                return Column(
                  children: [
                    /// Prevents the widget from rebuilding.
                    /// Useful when you want to reuse it in another ReactiveBuilder.
                    keep(Text("No state update")),

                    Chip(
                      label: Text(
                        state.name,
                      ),
                      deleteIcon: Icon(Icons.remove_circle),
                      avatar: Icon(
                        Icons.wifi,
                        color: isConnected ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: OutlinedButton(
        onPressed: () {
          /// Variation unconnected and connected.
          reactiveConnectionState.updateState(
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
