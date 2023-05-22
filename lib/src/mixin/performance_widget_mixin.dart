import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../model/widget_config.dart';
import '../performance_monitors/performance_monitor.dart';

/// `PerformanceWidget` is a mixin designed to be used with any type of widget
/// (including [StatefulWidget]s and [StatelessWidget]s) that needs to monitor
/// `PerformanceWidgetMixin` is a mixin designed to be used with any type of
///  widget (including [StatefulWidget]s and [StatelessWidget]s) that needs to
/// monitor their build performance.
///
/// It automatically starts and stops a trace around the widget's build method,
/// and logs the total build duration as an attribute and a metric in the trace.
///
/// Widgets using this mixin should provide a [WidgetConfig] that includes the
/// widget and trace names and a flag indicating whether performance monitoring
/// is enabled.
///
/// #### Example usage with StatelessWidget:
/// ```dart
/// class MyWidget extends StatelessWidget with PerformanceWidgetMixin {
///   @override
///   WidgetConfig get widgetConfig => WidgetConfig(
///     traceName: 'my_widget_trace',
///     widgetName: 'MyWidget',
///     enabledPerformance: true,
///   );
///
///   @override
///   Widget buildMeasured(BuildContext context) {
///     // Your widget build logic here.
///   }
/// }
/// ```
///
/// #### Example usage with StateFulWidget:
///
/// ```dart
/// class MyStatefulWidget extends StatefulWidget {
///   @override
///   _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
/// }
///
/// class _MyStatefulWidgetState extends State<MyStatefulWidget>
///     with PerformanceWidgetMixin {
///   @override
///   WidgetConfig get widgetConfig => WidgetConfig(
///         traceName: 'my_stateful_widget_trace',
///         widgetName: 'MyStatefulWidget',
///         enabledPerformance: true,
///       );
///
///   @override
///   Widget buildMeasured(BuildContext context) {
///     // Replace with your widget build logic.
///     return Container();
///   }
/// }
/// ```
///
mixin PerformanceWidgetMixin {
  /// The configuration object containing widget and trace names, and the
  /// enabled flag.
  WidgetConfig get widgetConfig;

  /// Returns the value of `isEnabledPerformance` from the widget configuration.
  ///
  /// The value indicates whether performance collection is enabled or not.
  /// If it returns `true`, performance collection will be enabled.
  /// If it returns `false`, performance collection will be disabled.
  bool get isEnabledPerformance => widgetConfig.enabledPerformance!;

  /// The name of the widget, using snake_case, ordering the words that
  /// describe its function from generic to specific, from left to right.
  /// For example, `build_page_stateful_counter`.
  String get nameTrace => widgetConfig.traceName;

  /// Returns the widget name from the widget configuration.
  ///
  /// The value represents the name of the widget for display purposes
  /// or for use in performance traces.
  String get nameWidget => widgetConfig.widgetName;

  /// Builds the widget with performance measurement.
  ///
  /// This function replaces the standard `build()` function for building
  /// widgets in subclasses of [MeasuredStateWidget]. It takes a
  /// [BuildContext] as its argument and returns a widget.
  /// It is called `buildMeasured` to suggest that it involves some kind of
  /// performance measurement during widget construction.
  ///
  /// The specifics of how measurements are taken are up to the implementation
  /// of the function. However, `buildMeasured()` provides an easy way for
  /// developers to integrate performance measurement into their widget code.
  Widget buildMeasured(BuildContext context);

  String get logTitle => 'PerformanceWidgetMixin - ${widgetConfig.traceName}';

  Widget build(BuildContext context) {
    try {
      final Stopwatch stopwatch = Stopwatch()..start();
      final element = buildMeasured(context);
      stopwatch.stop();

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          PerformanceMonitor performanceMonitor =
              Provider.of<PerformanceMonitor>(context, listen: false);
          final bool isPerformanceEnabled = widgetConfig.enabledPerformance ??
              await performanceMonitor.isPerformanceCollectionEnabled();
          performanceMonitor.widgetConfig = widgetConfig;

          if (isPerformanceEnabled) {
            final Duration durationTotal = stopwatch.elapsed;
            performanceMonitor
              ..startTrace()
              ..measuredDurationTrace(durationTotal)
              ..stopTrace();
          }
        } catch (e) {
          log(
            'Failed to record performance data: $e',
            name: logTitle,
          );
        }
      });
      return element;
    } catch (e) {
      log(e.toString(), name: widgetConfig.traceName);
      rethrow;
    }
  }
}
