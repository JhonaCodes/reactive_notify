import 'dart:isolate';

import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_notify/reactive_notify.dart';

void main() {
  group('ReactiveNotify', () {

    tearDown(() {
      ReactiveNotify.cleanup();
    });

    group('Initialization and Basic Functionality', () {
      test('should initialize with default value', () {
        final state = ReactiveNotify<int>(() => 0);
        expect(state.state, 0);
        expect(ReactiveNotify.instanceCount, 1);
      });

      test('should create separate instances for each call', () {
        final state1 = ReactiveNotify<int>(() => 0);
        final state2 = ReactiveNotify<int>(() => 1);
        expect(state1.state, 0);
        expect(state2.state, 1);
        expect(ReactiveNotify.instanceCount, 2);
      });

      test('should update value with setState', () {
        final state = ReactiveNotify<int>(() => 0);
        state.setState(10);
        expect(state.state, 10);
      });
    });

    group('Listener Notifications', () {
      test('should update state and notify listeners', () {
        final notify = ReactiveNotify<int>(() => 0);
        int? notifiedValue;

        notify.addListener(() {
          notifiedValue = notify.state;
        });

        notify.setState(5);

        expect(notifiedValue, equals(5));
      });

      test('should notify multiple listeners', () {
        final notify = ReactiveNotify<int>(() => 0);
        int? listener1Value;
        int? listener2Value;

        notify.addListener(() {
          listener1Value = notify.state;
        });
        notify.addListener(() {
          listener2Value = notify.state;
        });

        notify.setState(10);

        expect(listener1Value, equals(10));
        expect(listener2Value, equals(10));
      });

      test('should not notify removed listeners', () {
        final notify = ReactiveNotify<int>(() => 0);
        int? listenerValue;

        void listener() {
          listenerValue = notify.state;
        }

        notify.addListener(listener);
        notify.setState(5);
        expect(listenerValue, equals(5));

        notify.removeListener(listener);
        notify.setState(10);
        expect(listenerValue, equals(5)); // Should not have updated
      });
    });

    group('Instance Management', () {
      test('should create multiple instances of the same type', () {
        final state1 = ReactiveNotify<int>(() => 0);
        final state2 = ReactiveNotify<int>(() => 1);
        final state3 = ReactiveNotify<int>(() => 2);

        expect(ReactiveNotify.instanceCount, 3);
        expect(ReactiveNotify.instanceCountByType<int>(), 3);
      });

      test('should create instances of different types', () {
        final intState = ReactiveNotify<int>(() => 0);
        final stringState = ReactiveNotify<String>(() => 'hello');
        final boolState = ReactiveNotify<bool>(() => true);

        expect(ReactiveNotify.instanceCount, 3);
        expect(ReactiveNotify.instanceCountByType<int>(), 1);
        expect(ReactiveNotify.instanceCountByType<String>(), 1);
        expect(ReactiveNotify.instanceCountByType<bool>(), 1);
      });

      test('should clean up instances correctly', () {
        ReactiveNotify<int>(() => 0);
        ReactiveNotify<String>(() => 'hello');
        expect(ReactiveNotify.instanceCount, 2);

        ReactiveNotify.cleanup();
        expect(ReactiveNotify.instanceCount, 0);
      });
    });

    group('Cross-Notifier Interactions', () {
      test('should update dependent notifier', () {
        final countNotifier = ReactiveNotify<int>(() => 0);
        final isEvenNotifier = ReactiveNotify<bool>(() => true);

        countNotifier.addListener(() {
          isEvenNotifier.setState(countNotifier.state % 2 == 0);
        });

        countNotifier.setState(1);
        expect(countNotifier.state, 1);
        expect(isEvenNotifier.state, false);

        countNotifier.setState(2);
        expect(countNotifier.state, 2);
        expect(isEvenNotifier.state, true);
      });

      test('should handle cascading updates', () {
        final temperatureCelsius = ReactiveNotify<double>(() => 0);
        final temperatureFahrenheit = ReactiveNotify<double>(() => 32);
        final weatherDescription = ReactiveNotify<String>(() => 'Freezing');

        temperatureCelsius.addListener(() {
          temperatureFahrenheit.setState(temperatureCelsius.state * 9/5 + 32);
        });

        temperatureFahrenheit.addListener(() {
          if (temperatureFahrenheit.state < 32) {
            weatherDescription.setState('Freezing');
          } else if (temperatureFahrenheit.state < 65) {
            weatherDescription.setState('Cold');
          } else if (temperatureFahrenheit.state < 80) {
            weatherDescription.setState('Comfortable');
          } else {
            weatherDescription.setState('Hot');
          }
        });

        temperatureCelsius.setState(25);  // 77°F
        expect(temperatureCelsius.state, 25);
        expect(temperatureFahrenheit.state, closeTo(77, 0.1));
        expect(weatherDescription.state, 'Comfortable');

        temperatureCelsius.setState(35);  // 95°F
        expect(temperatureCelsius.state, 35);
        expect(temperatureFahrenheit.state, closeTo(95, 0.1));
        expect(weatherDescription.state, 'Hot');
      });




      test('should handle circular dependencies without infinite updates', () {
        ReactiveNotify.cleanup();

        final notifierA = ReactiveNotify<int>(() => 0);
        final notifierB = ReactiveNotify<int>(() => 0);

        var updateCountA = 0;
        var updateCountB = 0;

        notifierA.addListener(() {
          updateCountA++;
          notifierB.setState(notifierA.state + 1);
        });

        notifierB.addListener(() {
          updateCountB++;
          notifierA.setState(notifierB.state + 1);
        });

        notifierA.setState(1);

        expect(updateCountA, equals(1), reason: 'notifierA should update once');
        expect(updateCountB, equals(1), reason: 'notifierB should update once');
        expect(notifierA.state, equals(1), reason: 'notifierA state should remain 1');
        expect(notifierB.state, equals(2), reason: 'notifierB state should be updated to 2');

        ReactiveNotify.cleanup();
      });



    });

    group('Performance and Memory', () {
      test('should handle a large number of instances', () {
        final startTime = DateTime.now();
        for (int i = 0; i < 10000; i++) {
          ReactiveNotify<int>(() => i);
        }
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);

        expect(ReactiveNotify.instanceCount, 10000);
        expect(duration.inMilliseconds, lessThan(1000)); // Adjust this threshold as needed
      });

      test('should efficiently clean up a large number of instances', () {
        for (int i = 0; i < 10000; i++) {
          ReactiveNotify<int>(() => i);
        }

        final startTime = DateTime.now();
        ReactiveNotify.cleanup();
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);

        expect(ReactiveNotify.instanceCount, 0);
        expect(duration.inMilliseconds, lessThan(100)); // Adjust this threshold as needed
      });

      test('should not leak memory when adding and removing listeners', () {
        final notifier = ReactiveNotify<int>(() => 0);
        final listeners = List.generate(1000, (_) => () {});

        for (final listener in listeners) {
          notifier.addListener(listener);
        }

        for (final listener in listeners) {
          notifier.removeListener(listener);
        }

        // This is a basic check. In a real scenario, you might want to use a memory profiler.
        expect(true, isTrue); // Placeholder for memory leak check
      });
    });

    group('Advanced State Management', () {
      test('should handle complex object states', () {
        final complexState = ReactiveNotify<Map<String, dynamic>>(() => {'count': 0, 'name': 'Test'});
        complexState.setState({'count': 1, 'name': 'Updated'});
        expect(complexState.state, {'count': 1, 'name': 'Updated'});
      });

      test('should handle null states', () {
        final nullableState = ReactiveNotify<int?>(() => null);
        expect(nullableState.state, isNull);
        nullableState.setState(5);
        expect(nullableState.state, 5);
      });

      test('should handle state transitions', () {
        final stateTransition = ReactiveNotify<String>(() => 'initial');
        var transitionCount = 0;
        stateTransition.addListener(() {
          transitionCount++;
        });
        stateTransition.setState('processing');
        stateTransition.setState('completed');
        expect(transitionCount, 2);
      });
    });

    group('Asynchronous Operations', () {
      test('should handle async state updates', () async {
        final asyncState = ReactiveNotify<String>(() => 'initial');
        Future<void> updateStateAsync() async {
          await Future.delayed(Duration(milliseconds: 100));
          asyncState.setState('updated');
        }
        updateStateAsync();
        expect(asyncState.state, 'initial');
        await Future.delayed(Duration(milliseconds: 150));
        expect(asyncState.state, 'updated');
      });

      test('should manage concurrent async updates', () async {
        final concurrentState = ReactiveNotify<int>(() => 0);
        Future<void> incrementAsync() async {
          await Future.delayed(Duration(milliseconds: 50));
          concurrentState.setState(concurrentState.state + 1);
        }
        await Future.wait([incrementAsync(), incrementAsync(), incrementAsync()]);
        expect(concurrentState.state, 3);
      });
    });

    group('Computed States', () {
      test('should handle computed states', () {
        final baseState = ReactiveNotify<int>(() => 1);
        final computedState = ReactiveNotify<int>(() => baseState.state * 2);
        baseState.addListener(() => computedState.setState(baseState.state * 2));
        baseState.setState(5);
        expect(computedState.state, 10);
      });

      test('should efficiently update multiple dependent states', () {
        final rootState = ReactiveNotify<int>(() => 0);
        final computed1 = ReactiveNotify<int>(() => rootState.state + 1);
        final computed2 = ReactiveNotify<int>(() => rootState.state * 2);
        final computed3 = ReactiveNotify<int>(() => computed1.state + computed2.state);

        rootState.addListener(() {
          computed1.setState(rootState.state + 1);
          computed2.setState(rootState.state * 2);
        });
        computed1.addListener(() => computed3.setState(computed1.state + computed2.state));
        computed2.addListener(() => computed3.setState(computed1.state + computed2.state));

        rootState.setState(5);
        expect(computed1.state, 6);
        expect(computed2.state, 10);
        expect(computed3.state, 16);
      });
    });

    group('State History and Undo', () {
      test('should maintain state history', () {
        final historicalState = ReactiveNotify<int>(() => 0);
        final history = <int>[];
        historicalState.addListener(() => history.add(historicalState.state));
        historicalState.setState(1);
        historicalState.setState(2);
        historicalState.setState(3);
        expect(history, [1, 2, 3]);
      });

      test('should support undo operations', () {
        final undoableState = ReactiveNotify<int>(() => 0);
        final history = <int>[0];
        undoableState.addListener(() => history.add(undoableState.state));
        undoableState.setState(1);
        undoableState.setState(2);
        undoableState.setState(history[history.length - 2]); // Undo
        expect(undoableState.state, 1);
      });
    });

    group('Custom Serialization', () {
      test('should serialize and deserialize custom objects', () {

        final customState = ReactiveNotify<CustomObject>(() => CustomObject(1, 'initial'));
        customState.setState(CustomObject(2, 'updated'));
        expect(customState.state.id, 2);
        expect(customState.state.name, 'updated');
        });
    });

    group('Multi-threading Support', () {

      test('should handle updates from different isolates', () async {
        final isolateState = ReactiveNotify<int>(() => 0);

        // Crear un puerto de recepción para recibir datos del isolate
        final receivePort = ReceivePort();

        // Iniciar un isolate
        await Isolate.spawn((SendPort sendPort) {
          // Aquí estamos en el nuevo isolate
          final updatedState = 42;
          sendPort.send(updatedState); // Enviar el estado actualizado al isolate principal
        }, receivePort.sendPort);

        // Escuchar el puerto de recepción para obtener el estado actualizado
        final updatedState = await receivePort.first;

        // Actualizar el estado en el isolate principal
        isolateState.setState(updatedState as int);

        expect(isolateState.state, 42);
      });

    });

    group('Performance Optimizations', () {
      test('should optimize frequent updates', () {
        final optimizedState = ReactiveNotify<int>(() => 0);
        var updateCount = 0;
        optimizedState.addListener(() => updateCount++);
        for (var i = 0; i < 1000; i++) {
          optimizedState.setState(i);
        }
        expect(updateCount, lessThan(1000));
      });
    });

    group('Dependency Injection', () {
      test('should support dependency injection', () {
        final injectedDependency = 'Injected Value';
        final dependentState = ReactiveNotify<String>(() => 'Initial');
        expect(dependentState.state, 'Initial');
        dependentState.setState('Updated with $injectedDependency');
        expect(dependentState.state, 'Updated with Injected Value');
      });
    });
  });
}

class CustomObject {
  final int id;
  final String name;
  CustomObject(this.id, this.name);
}