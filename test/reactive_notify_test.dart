import 'package:reactive_notify/reactive_notify.dart';
import 'package:test/test.dart';

void main() {
  group('ReactiveNotify', () {
    final instance1 = ReactiveNotify<int>(() => 0);
    final instance2 = ReactiveNotify<int>(() => 0);
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

    test('should reset state to default value', () {
      final notify = ReactiveNotify<int>(() => 0);
      notify.setState(5);
      notify.resetState();

      expect(notify.value, equals(0));
    });

    test('should update state and notify listeners', () {
      final notify = ReactiveNotify<int>(() => 0);
      int? notifiedValue;

      notify.addListener(() {
        notifiedValue = notify.value;
      });

      notify.setState(5);

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

      notify.setState(10);

      expect(listener1Value, equals(10));
      expect(listener2Value, equals(10));
    });


  });
}
