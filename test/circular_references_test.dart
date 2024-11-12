import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_notify/reactive_notify.dart';

void main() {
  group('ReactiveNotify Circular Reference Tests', () {
    tearDown(() {
      ReactiveNotify.cleanup();
    });

    test('Validates direct circular reference', () {
      // Arrange
      final stateA = ReactiveNotify<String>(() => 'A');

      // Act & Assert
      expect(
        () => ReactiveNotify<String>(
          () => 'B',
          related: [stateA],
          key: const Key('B'),
        ),
        returnsNormally,
        reason: 'Single reference should not cause circular dependency',
      );
    });

    test(
        'Detects circular reference when a state tries to reference its ancestor',
        () {
      // Arrange
      final stateA = ReactiveNotify<String>(
        () => 'A',
      );

      final stateB = ReactiveNotify<String>(
        () => 'B',
        related: [stateA], // B depende de A
      );

      // Act & Assert
      expect(
        () => ReactiveNotify<String>(
          () => 'C',
          related: [
            stateB,
            stateA
          ], // Intenta depender de B (que ya depende de A) y de A
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.toString(),
            'error message',
            allOf([
              contains('⚠️ Invalid Reference Structure Detected!'),
              contains('Current Notifier:'),
              contains('Type: String'),
              contains('Ancestor Notifier Being Referenced:'),
              contains('Problem:'),
              contains('Solution:'),
              contains('Debug Info:'),
            ]),
          ),
        ),
        reason:
            'Should detect and provide detailed error when attempting to reference an ancestor state',
      );
    });

    test('Detects circular reference during creation', () {
      // Arrange
      final List<ReactiveNotify> states = [];

      final stateA = ReactiveNotify<String>(() => 'A');
      states.add(stateA);

      // Act & Assert
      expect(
        () {
          final stateB = ReactiveNotify<String>(
            () => 'B',
            related: states,
          );
          states.add(stateB);

          // Intentar crear un estado que cierre el ciclo
          ReactiveNotify<String>(() => 'C', related: [stateB]);

          // Intentar actualizar las relaciones de A para crear el ciclo
          stateA.related?.addAll([stateB]);
        },
        throwsA(
          isA<StateError>().having(
            (e) => e.toString(),
            'error message',
            allOf([
              contains('⚠️ ReactiveNotify Creation Failed!'),
              contains('Related states configuration'),
              contains('Initial value creation'),
              contains('Type consistency'),
            ]),
          ),
        ),
        reason:
            'Should detect and provide detailed error when attempting to reference an ancestor state',
      );
    });

    test('Validates complex dependency chain without cycles', () {
      // Arrange & Act & Assert
      final stateA = ReactiveNotify<String>(() => 'A');

      /// This si bad, should be create a notifier with stateA and stateB
      final stateB = ReactiveNotify<String>(() => 'B', related: [stateA]);

      expect(
        () => ReactiveNotify<String>(
          () => 'C',
          related: [stateB],
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.toString(),
            'error message',
            allOf([
              contains('⚠️ Invalid Reference Structure Detected!'),
              contains('Current Notifier:'),
              contains('Type: String'),
              contains('Ancestor Notifier Being Referenced:'),
              contains('Problem:'),
              contains('Solution:'),
              contains('Debug Info:'),
            ]),
          ),
        ),
        reason:
            'Should detect and provide detailed error when attempting to reference an ancestor state',
      );
    });

    test('Detects complex circular reference chain', () {
      // Arrange
      final stateA = ReactiveNotify<String>(() => 'A', key: const Key('A'));

      // Act & Assert
      expect(
        () {
          final stateB = ReactiveNotify<String>(
            () => 'B',
            related: [stateA],
          );

          final stateC = ReactiveNotify<String>(
            () => 'C',
            related: [stateB],
          );

          final stateD = ReactiveNotify<String>(() => 'D', related: [stateC]);

          ReactiveNotify<String>(() => 'A', related: [stateD]);
        },
        throwsA(
          isA<StateError>().having(
            (e) => e.toString(),
            'error message',
            allOf([
              contains('⚠️ Invalid Reference Structure Detected!'),
              contains('Current Notifier:'),
              contains('Type: String'),
              contains('Ancestor Notifier Being Referenced:'),
              contains('Problem:'),
              contains('Solution:'),
              contains('Debug Info:'),
            ]),
          ),
        ),
        reason:
            'Should detect and provide detailed error when attempting to reference an ancestor state',
      );
    });

    test('Validates diamond-shaped dependency graph', () {
      // Arrange
      final stateA = ReactiveNotify<String>(() => 'A', key: const Key('A'));

      final stateB1 = ReactiveNotify<String>(
        () => 'B1',
        related: [stateA],
      );

      final stateB2 = ReactiveNotify<String>(
        () => 'B2',
        related: [stateA],
      );

      // Act & Assert
      expect(
        () => ReactiveNotify<String>(
          () => 'C',
          related: [stateB1, stateB2],
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.toString(),
            'error message',
            allOf([
              contains('⚠️ Invalid Reference Structure Detected!'),
              contains('Current Notifier:'),
              contains('Type: String'),
              contains('Ancestor Notifier Being Referenced:'),
              contains('Problem:'),
              contains('Solution:'),
              contains('Debug Info:'),
            ]),
          ),
        ),
        reason:
            'Should detect and provide detailed error when attempting to reference an ancestor state',
      );
    });

    test('Detects self-referential circular dependency', () {
      // Arrange
      final stateA = ReactiveNotify<String>(() => 'A', key: const Key('A'));
      // Act & Assert
      expect(
        () => ReactiveNotify<String>(
          () => 'A',
          related: [stateA],
          key: const Key('A'),
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.toString(),
            'error message',
            allOf([
              contains('⚠️ Invalid Reference Structure Detected!'),
              contains('Current Notifier:'),
              contains('Key:'),
              contains('Problem:'),
              contains('Solution:'),
            ]),
          ),
        ),
        reason:
            'Should detect and provide a detailed error when attempting to create a notifier with a duplicate or self-referential key',
      );
    });

    test('Validates parallel dependency chains', () {
      // Arrange
      final stateA1 = ReactiveNotify<String>(() => 'A1', key: const Key('A1'));
      final stateA2 = ReactiveNotify<String>(() => 'A2', key: const Key('A2'));

      final stateB1 = ReactiveNotify<String>(
        () => 'B1',
        related: [stateA1],
        key: const Key('B1'),
      );

      final stateB2 = ReactiveNotify<String>(
        () => 'B2',
        related: [stateA2],
        key: const Key('B2'),
      );

      // Act & Assert
      expect(
        () => ReactiveNotify<String>(
          () => 'C',
          related: [stateB1, stateB2],
          key: const Key('C'),
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.toString(),
            'error message',
            allOf([
              contains('⚠️ Invalid Reference Structure Detected!'),
              contains('Current Notifier:'),
              contains('Type: String'),
              contains('Ancestor Notifier Being Referenced:'),
              contains('Problem:'),
              contains('Solution:'),
              contains('Debug Info:'),
            ]),
          ),
        ),
        reason:
            'Should detect and provide detailed error when attempting to reference an ancestor state',
      );
    });

    test('Validates independent dependencies without nesting', () {
      final firstNotifier2 = ReactiveNotify<String>(
        () => 'Level -1',
        key: const Key('Level -1'),
      );

      // Arrange
      final firstNotifier = ReactiveNotify<String>(
        () => 'Level 0',
        key: const Key('Level 0'),
      );

      final secondNotifier = ReactiveNotify<String>(
        () => 'Level 1',
        related: [firstNotifier, firstNotifier2],
        key: const Key('Level 1'),
      );

      final thirdNotifier = ReactiveNotify<String>(
        () => 'Level 2',
        related: [firstNotifier], // Solo se relaciona con el primer notifier
        key: const Key('Level 2'),
      );

      // Assert
      expect(
        ReactiveNotify.instanceCount,
        equals(4),
        reason: 'Should create all instances without nesting',
      );

      expect(firstNotifier2.value, equals('Level -1'));
      expect(firstNotifier.value, equals('Level 0'));
      expect(secondNotifier.value, equals('Level 1'));
      expect(thirdNotifier.value, equals('Level 2'));
    });
  });
}
