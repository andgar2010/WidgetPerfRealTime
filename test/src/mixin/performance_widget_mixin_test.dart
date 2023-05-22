import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:widget_perf_real_time/widget_perf_real_time.dart';

import '../mocks/mock.dart';

class TestWidget extends StatelessWidget with PerformanceWidgetMixin {
  const TestWidget({required this.widgetConfig_, super.key});

  final WidgetConfig widgetConfig_;

  @override
  Widget buildMeasured(BuildContext context) => const SizedBox.shrink();

  @override
  WidgetConfig get widgetConfig => widgetConfig_;
}

void main() {
  Provider.debugCheckInvalidValueType = null;
  late MockPerformanceMonitor mockPerformanceMonitor;
  WidgetConfig widgetConfig;
  late TestWidget testWidget;

  setUp(() {
    mockPerformanceMonitor = MockPerformanceMonitor();
    widgetConfig = const WidgetConfig(widgetName: 'TestWidget');
    testWidget = TestWidget(widgetConfig_: widgetConfig);

    when(() => mockPerformanceMonitor.isPerformanceCollectionEnabled())
        .thenAnswer((_) async => true);
    when(() => mockPerformanceMonitor.startTrace()).thenAnswer((_) async {});
    when(() => mockPerformanceMonitor.stopTrace()).thenAnswer((_) async {});
  });

  group('PerformanceWidget', () {
    testWidgets('build should start and stop trace',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        Provider<PerformanceMonitor>.value(
          value: mockPerformanceMonitor,
          child: testWidget,
        ),
      );

      verify(() => mockPerformanceMonitor.startTrace()).called(1);
      verify(() => mockPerformanceMonitor.stopTrace()).called(1);
    });
    testWidgets(
        'build should start and stop trace with'
        ' widgetConfig enabledPerformance false', (WidgetTester tester) async {
      widgetConfig = const WidgetConfig(
        widgetName: 'TestWidget',
        enabledPerformance: false,
      );
      testWidget = TestWidget(widgetConfig_: widgetConfig);

      await tester.pumpWidget(
        Provider<PerformanceMonitor>.value(
          value: mockPerformanceMonitor,
          child: testWidget,
        ),
      );

      expect(testWidget.isEnabledPerformance, isFalse);
      expect(testWidget.nameTrace, 'trace_perf_render_build_TestWidget');
      expect(testWidget.nameWidget, 'TestWidget');
      expect(
        testWidget.logTitle,
        'PerformanceWidgetMixin - trace_perf_render_build_TestWidget',
      );
      verifyNever(() => mockPerformanceMonitor.startTrace());
      verifyNever(() => mockPerformanceMonitor.stopTrace());
    });

    testWidgets('throw after build', (WidgetTester tester) async {
      when(() => mockPerformanceMonitor.isPerformanceCollectionEnabled())
          .thenThrow(Exception());

      await tester.pumpWidget(
        Provider<PerformanceMonitor>.value(
          value: mockPerformanceMonitor,
          child: testWidget,
        ),
      );

      verifyNever(() => mockPerformanceMonitor.startTrace());
      verifyNever(() => mockPerformanceMonitor.stopTrace());
    });
  });
}
