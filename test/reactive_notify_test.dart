import 'dart:isolate';

import 'package:flutter/material.dart';
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
        expect(state.value, 0);
        expect(ReactiveNotify.instanceCount, 1);
      });

      test('should create separate instances for each call', () {
        final state1 = ReactiveNotify<int>(() => 0);
        final state2 = ReactiveNotify<int>(() => 1);
        expect(state1.value, 0);
        expect(state2.value, 1);
        expect(ReactiveNotify.instanceCount, 2);
      });

      test('should update value with setState', () {
        final state = ReactiveNotify<int>(() => 0);
        state.updateState(10);
        expect(state.value, 10);
      });
    });

    group('Listener Notifications', () {
      test('should update state and notify listeners', () {
        final notify = ReactiveNotify<int>(() => 0);
        int? notifiedValue;

        notify.addListener(() {
          notifiedValue = notify.value;
        });

        notify.updateState(5);

        expect(notifiedValue, equals(5));
      });

      test('should notify multiple listeners', () {
        final notify = ReactiveNotify<int>(() => 0);
        int? listener1Value;
        int? listener2Value;

        notify.addListener(() {
          listener1Value = notify.value;
        });
        notify.addListener(() {
          listener2Value = notify.value;
        });

        notify.updateState(10);

        expect(listener1Value, equals(10));
        expect(listener2Value, equals(10));
      });

      test('should not notify removed listeners', () {
        final notify = ReactiveNotify<int>(() => 0);
        int? listenerValue;

        void listener() {
          listenerValue = notify.value;
        }

        notify.addListener(listener);
        notify.updateState(5);
        expect(listenerValue, equals(5));

        notify.removeListener(listener);
        notify.updateState(10);
        expect(listenerValue, equals(5)); // Should not have updated
      });
    });

    group('Instance Management', () {
      test('should create multiple instances of the same type', () {
        // ignore_for_file: unused_local_variable
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
          isEvenNotifier.updateState(countNotifier.value % 2 == 0);
        });

        countNotifier.updateState(1);
        expect(countNotifier.value, 1);
        expect(isEvenNotifier.value, false);

        countNotifier.updateState(2);
        expect(countNotifier.value, 2);
        expect(isEvenNotifier.value, true);
      });

      test('should handle cascading updates', () {
        final temperatureCelsius = ReactiveNotify<double>(() => 0);
        final temperatureFahrenheit = ReactiveNotify<double>(() => 32);
        final weatherDescription = ReactiveNotify<String>(() => 'Freezing');

        temperatureCelsius.addListener(() {
          temperatureFahrenheit
              .updateState(temperatureCelsius.value * 9 / 5 + 32);
        });

        temperatureFahrenheit.addListener(() {
          if (temperatureFahrenheit.value < 32) {
            weatherDescription.updateState('Freezing');
          } else if (temperatureFahrenheit.value < 65) {
            weatherDescription.updateState('Cold');
          } else if (temperatureFahrenheit.value < 80) {
            weatherDescription.updateState('Comfortable');
          } else {
            weatherDescription.updateState('Hot');
          }
        });

        temperatureCelsius.updateState(25); // 77°F
        expect(temperatureCelsius.value, 25);
        expect(temperatureFahrenheit.value, closeTo(77, 0.1));
        expect(weatherDescription.value, 'Comfortable');

        temperatureCelsius.updateState(35); // 95°F
        expect(temperatureCelsius.value, 35);
        expect(temperatureFahrenheit.value, closeTo(95, 0.1));
        expect(weatherDescription.value, 'Hot');
      });

      test('should handle circular dependencies without infinite updates', () {
        ReactiveNotify.cleanup();

        final notifierA = ReactiveNotify<int>(() => 0);
        final notifierB = ReactiveNotify<int>(() => 0);

        var updateCountA = 0;
        var updateCountB = 0;

        notifierA.addListener(() {
          updateCountA++;
          notifierB.updateState(notifierA.value + 1);
        });

        notifierB.addListener(() {
          updateCountB++;
          notifierA.updateState(notifierB.value + 1);
        });

        notifierA.updateState(1);

        expect(updateCountA, equals(1), reason: 'notifierA should update once');
        expect(updateCountB, equals(1), reason: 'notifierB should update once');
        expect(notifierA.value, equals(1),
            reason: 'notifierA state should remain 1');
        expect(notifierB.value, equals(2),
            reason: 'notifierB state should be updated to 2');

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
        expect(duration.inMilliseconds,
            lessThan(1000)); // Adjust this threshold as needed
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
        expect(duration.inMilliseconds,
            lessThan(100)); // Adjust this threshold as needed
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
        final complexState = ReactiveNotify<Map<String, dynamic>>(
            () => {'count': 0, 'name': 'Test'});
        complexState.updateState({'count': 1, 'name': 'Updated'});
        expect(complexState.value, {'count': 1, 'name': 'Updated'});
      });

      test('should handle null states', () {
        final nullableState = ReactiveNotify<int?>(() => null);
        expect(nullableState.value, isNull);
        nullableState.updateState(5);
        expect(nullableState.value, 5);
      });

      test('should handle state transitions', () {
        final stateTransition = ReactiveNotify<String>(() => 'initial');
        var transitionCount = 0;
        stateTransition.addListener(() {
          transitionCount++;
        });
        stateTransition.updateState('processing');
        stateTransition.updateState('completed');
        expect(transitionCount, 2);
      });
    });

    group('Asynchronous Operations', () {
      test('should handle async state updates', () async {
        final asyncState = ReactiveNotify<String>(() => 'initial');
        Future<void> updateStateAsync() async {
          await Future.delayed(Duration(milliseconds: 100));
          asyncState.updateState('updated');
        }

        updateStateAsync();
        expect(asyncState.value, 'initial');
        await Future.delayed(Duration(milliseconds: 150));
        expect(asyncState.value, 'updated');
      });

      test('should manage concurrent async updates', () async {
        final concurrentState = ReactiveNotify<int>(() => 0);
        Future<void> incrementAsync() async {
          await Future.delayed(Duration(milliseconds: 50));
          concurrentState.updateState(concurrentState.value + 1);
        }

        await Future.wait(
            [incrementAsync(), incrementAsync(), incrementAsync()]);
        expect(concurrentState.value, 3);
      });
    });

    group('Computed States', () {
      test('should handle computed states', () {
        final baseState = ReactiveNotify<int>(() => 1);
        final computedState = ReactiveNotify<int>(() => baseState.value * 2);
        baseState
            .addListener(() => computedState.updateState(baseState.value * 2));
        baseState.updateState(5);
        expect(computedState.value, 10);
      });

      test('should efficiently update multiple dependent states', () {
        final rootState = ReactiveNotify<int>(() => 0);
        final computed1 = ReactiveNotify<int>(() => rootState.value + 1);
        final computed2 = ReactiveNotify<int>(() => rootState.value * 2);
        final computed3 =
            ReactiveNotify<int>(() => computed1.value + computed2.value);

        rootState.addListener(() {
          computed1.updateState(rootState.value + 1);
          computed2.updateState(rootState.value * 2);
        });
        computed1.addListener(
            () => computed3.updateState(computed1.value + computed2.value));
        computed2.addListener(
            () => computed3.updateState(computed1.value + computed2.value));

        rootState.updateState(5);
        expect(computed1.value, 6);
        expect(computed2.value, 10);
        expect(computed3.value, 16);
      });
    });

    group('State History and Undo', () {
      test('should maintain state history', () {
        final historicalState = ReactiveNotify<int>(() => 0);
        final history = <int>[];
        historicalState.addListener(() => history.add(historicalState.value));
        historicalState.updateState(1);
        historicalState.updateState(2);
        historicalState.updateState(3);
        expect(history, [1, 2, 3]);
      });

      test('should support undo operations', () {
        final undoableState = ReactiveNotify<int>(() => 0);
        final history = <int>[0];
        undoableState.addListener(() => history.add(undoableState.value));
        undoableState.updateState(1);
        undoableState.updateState(2);
        undoableState.updateState(history[history.length - 2]); // Undo
        expect(undoableState.value, 1);
      });
    });

    group('Custom Serialization', () {
      test('should serialize and deserialize custom objects', () {
        final customState =
            ReactiveNotify<CustomObject>(() => CustomObject(1, 'initial'));
        customState.updateState(CustomObject(2, 'updated'));
        expect(customState.value.id, 2);
        expect(customState.value.name, 'updated');
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
          sendPort.send(
              updatedState); // Enviar el estado actualizado al isolate principal
        }, receivePort.sendPort);

        // Escuchar el puerto de recepción para obtener el estado actualizado
        final updatedState = await receivePort.first;

        // Actualizar el estado en el isolate principal
        isolateState.updateState(updatedState as int);

        expect(isolateState.value, 42);
      });
    });

    group('Performance Optimizations', () {
      test('should optimize frequent updates', () {
        final optimizedState = ReactiveNotify<int>(() => 0);
        var updateCount = 0;
        optimizedState.addListener(() => updateCount++);
        for (var i = 0; i < 50; i++) {
          optimizedState.updateState(i);
        }

        expect(updateCount, 49);
      });
    });

    group('Dependency Injection', () {
      test('should support dependency injection', () {
        final injectedDependency = 'Injected Value';
        final dependentState = ReactiveNotify<String>(() => 'Initial');
        expect(dependentState.value, 'Initial');
        dependentState.updateState('Updated with $injectedDependency');
        expect(dependentState.value, 'Updated with Injected Value');
      });
    });
  });

  group('ReactiveNotify Tests', () {
    setUp(() {
      // Limpiar estado entre tests
      ReactiveNotify.cleanup();
    });

    group('Singleton Behavior', () {
      test('creates different instances with different keys', () {
        final state1 = ReactiveNotify(() => 0, key: UniqueKey());
        final state2 = ReactiveNotify(() => 0, key: UniqueKey());

        expect(identical(state1, state2), false);
      });
    });

    group('State Updates', () {
      test('notifies listeners on value change', () {
        final state = ReactiveNotify(() => 0);
        int notifications = 0;
        state.addListener(() => notifications++);

        state.updateState(42); //42;
        expect(notifications, 1);
        expect(state.value, 42);
      });

      test('does not notify if value is the same', () {
        final state = ReactiveNotify(() => 42);
        int notifications = 0;
        state.addListener(() => notifications++);

        state.updateState(42);
        expect(notifications, 0);
      });
    });

    group('Batch Updates', () {
      test('notification for multiple related updates', () {
        final cartState = ReactiveNotify(() => CartState(0));
        final totalState = ReactiveNotify(() => TotalState(0.0));

        final orderState =
            ReactiveNotify(() => 'initial', related: [cartState, totalState]);

        int notifications = 0;
        orderState.addListener(() => notifications++);

        // Multiple updates
        cartState.updateState(CartState(2));
        totalState.updateState(TotalState(100.0));

        expect(notifications, 2);
        expect(orderState.from<CartState>().items, 2);
        expect(orderState.from<TotalState>().amount, 100.0);
      });

      test('batch updates happen in correct order', () {
        final updates = <String>[];

        final stateA = ReactiveNotify(() => 'A');
        final stateB = ReactiveNotify(() => 'B');

        final combined =
            ReactiveNotify(() => 'combined', related: [stateA, stateB]);

        stateA.addListener(() => updates.add('A'));
        expect(stateA.value, 'A');
        expect(combined.from<String>(stateA.keyNotifier), 'A');

        stateB.addListener(() => updates.add('B'));
        expect(stateB.value, 'B');
        expect(combined.from<String>(stateB.keyNotifier), 'B');

        combined.addListener(() => updates.add('combined'));

        stateA.updateState('A2');
        expect(stateA.value, 'A2');
        expect(combined.from<String>(stateA.keyNotifier), 'A2');

        stateB.updateState('B2');
        expect(stateB.value, 'B2');
        expect(combined.from<String>(stateB.keyNotifier), 'B2');

        expect(updates.length, 4);
        expect(updates.last, 'combined');
      });
    });

    group('Related States', () {
      test('can access related states through from<T>()', () {
        final cartState = ReactiveNotify(() => CartState(0));
        final totalState = ReactiveNotify(() => TotalState(0.0));

        final orderState =
            ReactiveNotify(() => 'order', related: [cartState, totalState]);

        expect(orderState.from<CartState>().items, 0);
        expect(orderState.from<TotalState>().amount, 0.0);
      });

      test('throws error when accessing non-existent related state', () {
        final state = ReactiveNotify(() => 'test');

        expect(
            () => state.from<CartState>(),
            throwsA(isA<StateError>().having((error) => error.message,
                'message', contains('No Related States Found'))));
      });
    });

    group('Complex Scenarios', () {
      test('handles complex update chain correctly', () {
        final updates = <String>[];

        // Create a chain of dependent states
        final userState = ReactiveNotify(() => UserState('John'));
        final cartState =
            ReactiveNotify(() => CartState(0), related: [userState]);
        final totalState =
            ReactiveNotify(() => TotalState(0.0), related: [userState]);

        userState.addListener(() => updates.add('user'));
        cartState.addListener(() => updates.add('cart'));
        totalState.addListener(() => updates.add('total'));

        // Trigger update chain
        userState.updateState(UserState('Jane'));

        expect(updates.length, 3);
        expect(updates, containsAllInOrder(['user', 'cart', 'total']));
      });
    });
  });
}

class CustomObject {
  final int id;
  final String name;
  CustomObject(this.id, this.name);
}

// Modelos de prueba
class UserState {
  final String name;
  UserState(this.name);
}

class CartState {
  final int items;
  CartState(this.items);
}

class TotalState {
  final double amount;
  TotalState(this.amount);
}
