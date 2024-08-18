import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_notify/reactive_notify.dart';

ReactiveNotify<int> state = ReactiveNotify<int>(() => 0);

void main() {
  group('ReactiveBuilder Golden Tests', () {
    goldenTest(
      'ReactiveBuilder should default value',
      fileName: 'golden_reactive_builder_default_test',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 600),
        children: [
          GoldenTestScenario(
            name: 'Change value 0',
            child: ReactiveBuilder<int>(
                valueListenable: state,
                builder: (value) {
                  if (value == 200) {
                    state.setState(0);
                  }

                  return ListTile(
                    title: Text('ReactiveNotify.value = $value'),
                  );
                }),
          ),
        ],
      ),
    );

    goldenTest(
      'ReactiveBuilder should rebuild to new value',
      fileName: 'golden_reactive_builder_test',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 600),
        children: [
          GoldenTestScenario(
            name: 'Change value 200',
            child: ReactiveBuilder<int>(
                valueListenable: state,
                builder: (value) {
                  if (value == 0) {
                    state.setState(200);
                  }
                  return ListTile(
                    title: Text('ReactiveNotify.value = $value'),
                  );
                }),
          ),
        ],
      ),
    );
  });
}
