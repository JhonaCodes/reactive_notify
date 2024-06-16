import 'package:reactive_notify/reactive_notify.dart';
import 'package:test/test.dart';

void main() {
  group('ReactiveNotify', () {
    test('should initialize with default value', () {
      final state = ReactiveNotify<int>(() => 0);
      expect(state.value, 0);
    });

    test('should maintain singleton instance', () {
      final state1 = ReactiveNotify<int>(() => 0);
      final state2 = ReactiveNotify<int>(() => 1);
      expect(state1.value, 0);
      expect(state2.value, 1);
    });

    test('should update value with setState', () {
      final state = ReactiveNotify<int>(() => 0);
      state.setState(10);
      expect(state.value, 10);
    });

    test('should reset value to default with resetState', () {
      final state = ReactiveNotify<int>(() => 0);
      state.setState(10);
      state.resetState();
      expect(state.value, 0);
    });
  });
}
