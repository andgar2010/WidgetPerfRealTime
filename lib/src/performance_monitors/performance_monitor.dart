import 'package:flutter/foundation.dart';

import '../model/widget_config.dart';

/// An interface for monitoring widget performance.
///
/// `PerformanceMonitor` outlines the methods required for implementing
/// performance monitoring for widgets. It provides methods for
/// enabling/disabling performance collection, setting traces,
/// and measuring duration of these traces. Different performance monitoring
/// tools, such as Firebase Performance Monitoring, can implement this
/// interface to provide specific monitoring capabilities.
///
/// By extending `ChangeNotifier`, it also allows widgets to rebuild when
/// changes occur to the performance data, enabling dynamic UI updates based on
/// performance metrics.
abstract class PerformanceMonitor implements ChangeNotifier {
  /// The configuration object containing widget and trace names, and the
  /// enabled flag.
  late WidgetConfig widgetConfig;

  /// The name of the performance monitor for log title purposes.
  String get logTitle;

  /// Enables or disables performance data collection.
  ///
  /// Depending on the provided [enabled] value, this method turns the
  /// performance data collection on or off. Note that this does not
  /// immediately stop the ongoing traces, but prevents new traces from being
  /// recorded.
  Future<void> setPerformanceCollectionEnabled(bool enabled);

  /// Checks if the performance data collection is currently enabled.
  ///
  /// Returns a [Future] that completes with `true` if the performance data
  /// collection is enabled, and `false` otherwise. This method can be used
  /// to conditionally start or stop traces based on the current state of
  /// performance monitoring.
  Future<bool> isPerformanceCollectionEnabled();

  /// Sets a trace for the performance monitoring.
  ///
  /// This method initializes a new trace for the provided [widgetName] or for
  /// the widget name specified in the `widgetConfig` if [widgetName] is not
  /// provided.
  /// Note that calling this method does not automatically start the trace;
  /// you need to call `startTrace()` to begin recording performance data.
  Object setTrace([String? widgetName]);

  /// Records the duration of an event in milliseconds.
  ///
  /// This method logs the [durationTotal] as an attribute and a metric to the
  /// current trace. This is typically used to record the time it takes to build
  /// a widget or to perform some other time-sensitive operation.
  void measuredDurationTrace(Duration durationTotal);

  /// Starts a performance trace.
  ///
  /// This method starts recording performance data for the trace set by
  /// `setTrace()`. If the trace is not set or is `null`, this method logs an
  /// error and throws a `PerformanceCollectionException`.
  /// The optional [widgetName] parameter can be provided to start a trace for
  /// a specific widget.
  Future<void> startTrace([String? widgetName]);

  /// Stops the current performance trace.
  ///
  /// This method stops recording performance data for the current trace. If the
  /// trace is not set or is `null`, this method logs an error and throws a
  /// `PerformanceCollectionException`.
  Future<void> stopTrace();

  /// Sets a metric with the given [metricName] and [value].
  ///
  /// This method sets a metric in the performance monitoring system, associating
  /// a specific value with the provided [metricName]. The [value] should be an
  /// integer representing the metric value.
  ///
  /// Example usage:
  /// ```dart
  /// setMetric('widget_build_count', 10);
  /// ```
  void setMetric(String metricName, int value);
}
