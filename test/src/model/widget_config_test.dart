import 'package:flutter_test/flutter_test.dart';
import 'package:widget_perf_real_time/widget_perf_real_time.dart';

void main() {
  group('WidgetConfig', () {
    test('should assign correct values when all arguments are provided', () {
      const WidgetConfig config = WidgetConfig(
        widgetName: 'custom_test_widget',
        enabledPerformance: true,
        traceName: 'custom_test_trace_name',
      );

      expect(config.widgetName, 'custom_test_widget');
      expect(config.enabledPerformance, true);
      expect(config.traceName, 'custom_test_trace_name');
    });
    test('should assign correct values when only widgetName is provided', () {
      const WidgetConfig config =
          WidgetConfig(widgetName: 'Custom_test_widget');

      expect(config.widgetName, 'Custom_test_widget');
      expect(config.enabledPerformance, null);
      expect(config.traceName, 'trace_perf_render_build_Custom_test_widget');
    });
    test('should assign null to enabledPerformance if not provided', () {
      const WidgetConfig config = WidgetConfig(
        widgetName: 'custom_test_widget',
        traceName: 'custom_test_trace_name',
      );

      expect(config.widgetName, 'custom_test_widget');
      expect(config.enabledPerformance, null);
      expect(config.traceName, 'custom_test_trace_name');
    });
    test('should assign default traceName if not provided', () {
      const WidgetConfig config = WidgetConfig(
        widgetName: 'custom_test_widget',
        enabledPerformance: true,
      );

      expect(config.widgetName, 'custom_test_widget');
      expect(config.enabledPerformance, true);
      expect(config.traceName, 'trace_perf_render_build_custom_test_widget');
    });
    test('should create a WidgetConfig object with default traceName', () {
      const WidgetConfig config = WidgetConfig(
        widgetName: 'custom_test_widget',
        enabledPerformance: false,
      );

      expect(config.widgetName, 'custom_test_widget');
      expect(config.enabledPerformance, false);
      expect(config.traceName, 'trace_perf_render_build_custom_test_widget');
    });

    test('should assign default traceName if traceName is null', () {
      const WidgetConfig config = WidgetConfig(
        widgetName: 'custom_test_widget',
        enabledPerformance: false,
        traceName: null,
      );

      expect(config.widgetName, 'custom_test_widget');
      expect(config.enabledPerformance, false);
      expect(config.traceName, 'trace_perf_render_build_custom_test_widget');
    });

    test('should assign default traceName if traceName is empty string', () {
      const WidgetConfig config = WidgetConfig(
        widgetName: 'custom_test_widget',
        enabledPerformance: false,
        traceName: '',
      );

      expect(config.widgetName, 'custom_test_widget');
      expect(config.enabledPerformance, false);
      expect(config.traceName, 'trace_perf_render_build_custom_test_widget');
    });
  });
}
