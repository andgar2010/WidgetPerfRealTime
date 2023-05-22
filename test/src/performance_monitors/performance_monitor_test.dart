import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:widget_perf_real_time/widget_perf_real_time.dart';

import '../mocks/mock.dart';

void main() {
  late MockPerformanceMonitor mockPerformanceMonitor;

  setUp(() {
    mockPerformanceMonitor = MockPerformanceMonitor();
  });

  group('PerformanceMonitor', () {
    test('setPerformanceCollectionEnabled', () async {
      when(() => mockPerformanceMonitor.setPerformanceCollectionEnabled(true))
          .thenAnswer((_) async {});

      await mockPerformanceMonitor.setPerformanceCollectionEnabled(true);

      verify(() => mockPerformanceMonitor.setPerformanceCollectionEnabled(true))
          .called(1);
    });
    test('setPerformanceCollectionEnabled throws exception', () async {
      when(() => mockPerformanceMonitor.setPerformanceCollectionEnabled(true))
          .thenThrow(
        const PerformanceCollectionException(
          'Failed to set performance collection state',
        ),
      );

      expect(
        () async =>
            await mockPerformanceMonitor.setPerformanceCollectionEnabled(true),
        throwsA(isA<PerformanceCollectionException>()),
      );
    });

    test('isPerformanceCollectionEnabled', () async {
      when(mockPerformanceMonitor.isPerformanceCollectionEnabled)
          .thenAnswer((_) async => true);

      final result =
          await mockPerformanceMonitor.isPerformanceCollectionEnabled();

      expect(result, isTrue);
      verify(() => mockPerformanceMonitor.isPerformanceCollectionEnabled())
          .called(1);
    });

    test('setTrace', () {
      when(() => mockPerformanceMonitor.setTrace('traceName'))
          .thenReturn(Object());

      mockPerformanceMonitor.setTrace('traceName');

      verify(() => mockPerformanceMonitor.setTrace('traceName')).called(1);
    });
  });
}
