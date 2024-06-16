import 'package:reactive_notify/reactive_notify.dart';
import 'package:test/test.dart';

void main() {
  group('ReactiveStateInitializerCallback', () {
    test('should initialize with initializer function', () {
      final state = ReactiveNotifyInitializerCallback<int>(
        initializer: () => 0,
        onStateChange: (newValue) => newValue,
      );
      expect(state.value, 0);
    });

    test('should maintain singleton instance', () {
      final state1 = ReactiveNotifyInitializerCallback<int>(
        initializer: () => 0,
        onStateChange: (newValue) => newValue,
      );
      final state2 = ReactiveNotifyInitializerCallback<int>(
        initializer: () => 1,
        onStateChange: (newValue) => newValue,
      );
      expect(state1.value, 0);
      expect(state2.value, 1);
    });

    test('should update value and execute callback with setState', () {
      int callbackValue = 0;
      final state = ReactiveNotifyInitializerCallback<int>(
        initializer: () => 0,
        onStateChange: (newValue) {
          callbackValue = newValue;
          return newValue;
        },
      );
      state.setState(10);
      expect(state.value, 10);
      expect(callbackValue, 10);
    });

    test('should reset value to default with resetState', () {
      final state = ReactiveNotifyInitializerCallback<int>(
        initializer: () => 0,
        onStateChange: (newValue) => newValue,
      );
      state.setState(10);
      state.resetState();
      expect(state.value, 0);
    });

    test('should execute callback with current state value on update', () {
      int callbackValue = 0;
      final state = ReactiveNotifyInitializerCallback<int>(
        initializer: () => 0,
        onStateChange: (newValue) {
          callbackValue = newValue;
          return newValue;
        },
      );
      state.setState(10);
      state.update();
      expect(callbackValue, 10);
    });
  });
}
