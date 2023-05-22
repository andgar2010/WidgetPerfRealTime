import 'dart:developer';

import 'package:firebase_performance/firebase_performance.dart';

import 'package:flutter/foundation.dart';
import '../../exception/performance_collection_exception.dart';
import '../performance_monitor.dart';

/// An implementation of the `PerformanceMonitor` interface using Firebase
/// Performance Monitoring.
///
/// This class interacts with the Firebase Performance Monitoring SDK to
/// manage performance collection and traces. It also implements the necessary
/// methods for starting, stopping, and measuring duration of traces.
class FirebasePerformanceMonitor extends PerformanceMonitor
    with ChangeNotifier {
  FirebasePerformanceMonitor({
    required FirebasePerformance instance,
    this.enablePerformanceMonitoring,
  }) : _firebasePerformance = instance;

  /// Indicates the status of performance collection. If `true`, performance
  /// metrics are being collected.
  /// If `false`, the collection of performance metrics is disabled.
  bool? enablePerformanceMonitoring;

  /// An instance of `FirebasePerformance` used to interact with the Firebase
  /// Performance Monitoring SDK. It is responsible for tasks such as
  /// enabling/disabling performance collection and managing traces.
  final FirebasePerformance _firebasePerformance;

  /// Represents the trace object used within Firebase performance monitoring.
  /// This object is used to record performance metrics from specific sections
  /// of the app code.
  late Trace _trace;

  /// Checks whether performance collection is currently enabled.
  ///
  /// This function first checks if the [enablePerformanceMonitoring] flag is
  /// set.
  /// If it is not, it attempts to retrieve the state of the performance
  /// collection from the FirebasePerformance instance.
  ///
  /// If retrieving the state fails, it logs an error message and returns false.
  ///
  /// Returns: a [Future] that completes with true if performance collection is
  /// enabled and false otherwise.
  ///
  /// Example usage:
  /// ```
  /// final isEnabled = await monitor.isPerformanceCollectionEnabled();
  /// if (isEnabled) {
  ///   // Continue with performance-sensitive operation
  /// } else {
  ///   // Maybe alert the user, or change behavior
  /// }
  /// ```
  @override
  Future<bool> isPerformanceCollectionEnabled() async {
    try {
      enablePerformanceMonitoring = enablePerformanceMonitoring ??
          await _firebasePerformance.isPerformanceCollectionEnabled();
      return enablePerformanceMonitoring!;
    } catch (e) {
      log(
        'Failed to retrieve performance collection state: $e',
        name: logTitle,
      );
      return false;
    }
  }

  /// Returns the title for logging purposes, including the name of the trace.
  ///
  /// This property returns a formatted string that represents the title for
  /// logging purposes. It includes the name of the trace from the
  /// [widgetConfig].
  @override
  String get logTitle =>
      'FirebasePerformanceMonitor - ${widgetConfig.traceName}';

  /// Measures the total build duration and logs it as an attribute and
  /// a metric in the performance trace.
  ///
  /// This function is called after the widget is built in the _measureBuild()
  /// function. It expects a [Duration] argument which should represent
  /// the total time it took to build the widget.
  ///
  /// The [durationTotal] is then logged in milliseconds as an attribute and
  /// metric in a [Trace] object.
  ///
  /// If the trace instance is null, it logs an error and throws a
  /// [PerformanceCollectionException].
  ///
  /// Throws: [PerformanceCollectionException] if the trace instance is null.
  ///
  /// Example usage:
  /// ```
  /// try {
  ///   monitor.measuredDurationTrace(Duration(milliseconds: 100));
  /// } catch (e) {
  ///   if (e is PerformanceCollectionException) {
  ///     // Handle the exception here
  ///   }
  /// }
  /// ```
  @override
  void measuredDurationTrace(Duration durationTotal) {
    final int durationMilliseconds = durationTotal.inMilliseconds;

    try {
      _trace
        ..putAttribute(
          'duration_milliseconds_PA_state',
          durationMilliseconds.toString(),
        )
        ..setMetric(
          'build duration milliseconds',
          durationMilliseconds,
        );
      log('Build duration $durationTotal', name: widgetConfig.traceName);
    } catch (e) {
      log(
        ' Failed to record duration because trace is null with the name: '
        '${widgetConfig.traceName}. Error: $e',
        name: logTitle,
      );
      throw const PerformanceCollectionException(
        'Failed to record duration because trace have error',
      );
    }
  }

  /// Sets a custom metric for the current trace.
  ///
  /// This method sets a custom metric with the provided [metricName] and [value]
  /// for the current trace. If the trace is null, the metric is not set.
  ///
  /// It is useful for recording custom performance metrics specific to your application.
  ///
  /// Example usage:
  /// ```dart
  /// monitor.setMetric('custom_metric', 42);
  /// ```
  @override
  void setMetric(String metricName, int value) {
    try {
      _trace.setMetric(metricName, value);
    } catch (e) {
      log(
        'Failed to set metric because trace required first step setTrace(), '
        'after setMetric(). Error: $e',
        name: logTitle,
      );
      throw PerformanceCollectionException(
        'Failed to set metric because trace required first step setTrace(), '
        'after setMetric(). Error: $e',
      );
    }
  }

  /// Sets the performance collection state to [enabled].
  ///
  /// This function will attempt to enable or disable the performance collection
  /// state of the Firebase Performance instance based on the provided
  /// [enabled] flag.
  ///
  /// If there is an error during the process, it logs the error message and
  /// throws a [PerformanceCollectionException] with a description of the
  /// failure.
  ///
  /// Throws: [PerformanceCollectionException] if unable to set the performance
  /// collection state.
  ///
  /// Example usage:
  /// ```
  /// try {
  ///   monitor.setPerformanceCollectionEnabled(true);
  /// } catch (e) {
  ///   if (e is PerformanceCollectionException) {
  ///     // Handle the exception here
  ///   }
  /// }
  /// ```
  @override
  Future<void> setPerformanceCollectionEnabled(bool enabled) async {
    try {
      await _firebasePerformance.setPerformanceCollectionEnabled(enabled);
    } catch (e) {
      log(
        'Failed to set performance collection state: $e',
        name: logTitle,
      );
      throw const PerformanceCollectionException(
        'Failed to set performance collection state',
      );
    }
  }

  /// Creates a new trace object with the given [widgetName] or
  /// the default widget name from the [widgetConfig].
  ///
  /// If no [widgetName] is provided, the function will use the widget name
  /// specified in the [widgetConfig].
  ///
  /// Throws: [PerformanceCollectionException] if failed to create new trace.
  ///
  /// Example usage:
  /// ```
  /// try {
  ///   monitor.setTrace('MyWidgetName');
  /// } catch (e) {
  ///   if (e is PerformanceCollectionException) {
  ///     // Handle the exception here
  ///   }
  /// }
  /// ```
  @override
  Trace setTrace([String? widgetName]) {
    try {
      return _firebasePerformance
          .newTrace(widgetName ?? widgetConfig.traceName);
    } catch (e) {
      log(
        'Failed to create a new trace with the name: ${widgetName ?? widgetConfig.traceName}. $e',
        name: logTitle,
      );
      throw PerformanceCollectionException(
        'Failed to create a new trace: $e',
      );
    }
  }

  /// Starts a trace for the specified widget.
  ///
  /// If [widgetName] is provided, it will be used as the name of the trace.
  /// If not, the name of the trace will be retrieved from the widget
  /// configuration.
  ///
  /// Before starting the trace, this function calls [setTrace] to ensure a
  /// trace is set up.
  /// If the trace is null, it logs an error message and throws a
  /// [PerformanceCollectionException].
  ///
  /// If the trace is not null, it starts the trace. If starting the trace
  /// fails, the error is rethrown.
  ///
  /// Throws: [PerformanceCollectionException] if the trace is null.
  ///
  /// Example usage:
  /// ```
  /// try {
  ///   monitor.startTrace('MyWidget');
  /// } catch (e) {
  ///   if (e is PerformanceCollectionException) {
  ///     // Handle the exception here
  ///   }
  /// }
  /// ```
  @override
  Future<void> startTrace([String? widgetName]) async {
    _trace = setTrace(widgetName);
    try {
      await _trace.start();
    } catch (e) {
      rethrow;
    }
  }

  /// Call this method after the widget build process is completed or when
  /// the widget is disposed.

  /// Stops the current performance trace if a trace instance exists and sets
  /// it to null.
  ///
  /// If the trace instance is null, logs an error and throws a
  /// [PerformanceCollectionException].
  ///
  /// Throws: [PerformanceCollectionException]
  /// if the trace instance is null.
  ///
  /// Example usage:
  /// ```
  /// try {
  ///   await monitor.stopTrace();
  /// } catch (e) {
  ///   if (e is PerformanceCollectionException) {
  ///     // Handle the exception here
  ///   }
  /// }
  /// ```
  @override
  Future<void> stopTrace() async {
    try {
      await _trace.stop();
    } catch (e) {
      rethrow;
    }
  }
}
