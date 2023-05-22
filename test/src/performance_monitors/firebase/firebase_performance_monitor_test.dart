import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:widget_perf_real_time/widget_perf_real_time.dart';

import '../../mocks/mock.dart';

void main() {
  late FirebasePerformanceMonitor monitorPerformance;
  late FirebasePerformance mockFirebasePerformance;
  late Trace mockTrace;
  const WidgetConfig widgetConfig = WidgetConfig(
    widgetName: 'testWidget',
    enabledPerformance: true,
    traceName: 'testTrace',
  );

  setUp(() {
    mockFirebasePerformance = MockFirebasePerformance();
    monitorPerformance =
        FirebasePerformanceMonitor(instance: mockFirebasePerformance)
          ..widgetConfig = widgetConfig;
    mockTrace = MockTrace();
    when(() => mockFirebasePerformance.newTrace(any())).thenReturn(mockTrace);
    when(() => mockTrace.start()).thenAnswer((_) async => {});
    when(() => mockTrace.stop()).thenAnswer((_) async => {});
  });

  group('FirebasePerformanceMonitor', () {
    group('isPerformanceCollectionEnabled', () {
      test('default should return correct value', () async {
        // Arrange
        final monitorPerformance =
            FirebasePerformanceMonitor(instance: mockFirebasePerformance);
        when(() => mockFirebasePerformance.isPerformanceCollectionEnabled())
            .thenAnswer((_) async => true);

        // Act
        final result =
            await monitorPerformance.isPerformanceCollectionEnabled();

        // Assert
        expect(result, true);
        verify(() => mockFirebasePerformance.isPerformanceCollectionEnabled())
            .called(1);
      });
      test('should return correct value', () async {
        // Arrange
        monitorPerformance = FirebasePerformanceMonitor(
          instance: mockFirebasePerformance,
          enablePerformanceMonitoring: true,
        );
        // Act
        final result =
            await monitorPerformance.isPerformanceCollectionEnabled();

        // Assert
        expect(result, true);
        verifyNever(
          () => mockFirebasePerformance.isPerformanceCollectionEnabled(),
        );
      });
      test('throws exception', () async {
        // Act
        when(() => mockFirebasePerformance.isPerformanceCollectionEnabled())
            .thenThrow(false);

        // Assert
        expect(
          await monitorPerformance.isPerformanceCollectionEnabled(),
          isFalse,
        );
        verify(
          () => mockFirebasePerformance.isPerformanceCollectionEnabled(),
        ).called(1);
      });
    });
    group('setPerformanceCollectionEnabled', () {
      test('should call correct method', () async {
        // Arrange
        when(
          () => mockFirebasePerformance.setPerformanceCollectionEnabled(any()),
        ).thenAnswer((_) async {});

        // Act
        await monitorPerformance.setPerformanceCollectionEnabled(true);

        // Assert
        verify(
          () => mockFirebasePerformance.setPerformanceCollectionEnabled(true),
        ).called(1);
      });

      test('throws exception', () async {
        // Act
        when(
          () => mockFirebasePerformance.setPerformanceCollectionEnabled(any()),
        ).thenThrow(
          const PerformanceCollectionException(
            'Failed to set performance collection state',
          ),
        );

        // Assert
        expect(
          () async =>
              await monitorPerformance.setPerformanceCollectionEnabled(true),
          throwsA(isA<PerformanceCollectionException>()),
        );
        verify(
          () => mockFirebasePerformance.setPerformanceCollectionEnabled(any()),
        ).called(1);
      });
    });

    group('setTrace', () {
      test('should call correct method', () async {
        // Act
        monitorPerformance.setTrace('widgetName');

        // Assert
        verify(() => mockFirebasePerformance.newTrace('widgetName')).called(1);
      });
      test('throws exception', () async {
        // Arrange
        when(() => mockFirebasePerformance.newTrace(any())).thenThrow(
          const PerformanceCollectionException(
            'Failed to set performance collection state',
          ),
        );

        // Assert
        expect(
          () async => monitorPerformance.setTrace('custom_widget_trace'),
          throwsA(isA<PerformanceCollectionException>()),
        );
        verify(
          () => mockFirebasePerformance.newTrace(any()),
        ).called(1);
      });
    });
    group('startTrace', () {
      test('should call correct method', () async {
        // Act
        await monitorPerformance.startTrace('widgetName');

        // Assert
        verify(() => mockTrace.start()).called(1);
      });
      test('throws exception', () async {
        // Arrange
        when(() => mockTrace.start()).thenThrow(
          const PerformanceCollectionException(
            'Failed to set performance collection state',
          ),
        );

        // Assert
        expect(
          () async => monitorPerformance.startTrace('custom_widget_trace'),
          throwsA(isA<PerformanceCollectionException>()),
        );
        verify(() => mockTrace.start()).called(1);
      });
    });

    group('stopTrace', () {
      test('should call correct method', () async {
        // Act
        await monitorPerformance.startTrace('widgetName');
        await monitorPerformance.stopTrace();

        // Assert
        verify(() => mockTrace.stop()).called(1);
      });
      test('throws exception', () async {
        // Arrange
        when(() => mockTrace.stop()).thenThrow(
          const PerformanceCollectionException(
            'Failed to set performance collection state',
          ),
        );

        // Act
        await monitorPerformance.startTrace();

        // Assert
        expect(
          () async => await monitorPerformance.stopTrace(),
          throwsA(isA<PerformanceCollectionException>()),
        );
        verify(() => mockTrace.stop()).called(1);
      });
    });
    group('setMetric', () {
      test('should call correct method', () async {
        // Act
        await monitorPerformance.startTrace('widgetName');
        monitorPerformance.setMetric('metricName', 1);

        // Assert
        verify(() => mockTrace.setMetric('metricName', 1)).called(1);
      });
      test('throws exception', () async {
        // Arrange
        when(() => mockTrace.setMetric(any(), any())).thenThrow(
          const PerformanceCollectionException(
            'Failed to set performance collection state',
          ),
        );

        // Act
        await monitorPerformance.startTrace();

        // Assert
        expect(
          () => monitorPerformance.setMetric('metricName', 1),
          throwsA(isA<PerformanceCollectionException>()),
        );
        verify(() => mockTrace.setMetric(any(), any())).called(1);
      });
    });
    group('measuredDurationTrace', () {
      test('should call correct method', () async {
        // Arrange
        const Duration duration = Duration.zero;
        final int durationInt = duration.inMilliseconds;

        // Act
        await monitorPerformance.startTrace('widgetName');
        monitorPerformance.measuredDurationTrace(duration);

        // Assert
        verify(() => mockTrace.start()).called(1);
        verify(
          () => mockTrace.putAttribute(
            'duration_milliseconds_PA_state',
            durationInt.toString(),
          ),
        ).called(1);
        verify(
          () => mockTrace.setMetric('build duration milliseconds', durationInt),
        ).called(1);
      });
      test('throws exception', () async {
        // Arrange
        when(() => mockTrace.putAttribute(any(), any())).thenThrow(
          const PerformanceCollectionException(
            'Failed to record duration because trace have error',
          ),
        );

        // Act
        await monitorPerformance.startTrace();

        // Assert
        expect(
          () => monitorPerformance.measuredDurationTrace(Duration.zero),
          throwsA(isA<PerformanceCollectionException>()),
        );
        verify(() => mockTrace.putAttribute(any(), any())).called(1);
      });
    });
  });
}
