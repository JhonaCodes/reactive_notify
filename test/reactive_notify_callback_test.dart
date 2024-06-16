import 'package:reactive_notify/reactive_notify.dart';
import 'package:test/test.dart';

void main() {
  group('ReactiveNotifyCallback', () {
    test('should update value and execute callback with setState', () {
      int callbackValue = 0;
      final state3 = ReactiveNotifyCallback<int>(0, onStateChange: (newValue) {
        callbackValue = newValue;
        return newValue;
      });
      state3.setState(10);
      expect(state3.value, 10);
      expect(callbackValue, 10);
    });

    test('should maintain singleton instance', () {
      final state1 = ReactiveNotifyCallback<int>(0);
      final state2 = ReactiveNotifyCallback<int>(1);
      expect(state1.value, 0);
      expect(state2.value, 1);
    });

    test('should reset value to default with resetState', () {
      final state = ReactiveNotifyCallback<int>(0);
      state.setState(10);
      state.resetState();
      expect(state.value, 0);
    });

    test('should initialize with default value', () {
      final state = ReactiveNotifyCallback<int>(0);
      expect(state.value, 0);
    });
  });
}
