/// [WidgetConfig] is a configuration object for widget performance
/// measurement.
///
/// This class holds the necessary information to create performance traces
/// for widgets and helps manage performance measurement settings.
/// It can be used to enable/disable performance measurement and set custom
/// trace names.
///
/// To use this class, create an instance of it and provide the necessary
/// parameters. The resulting object can then be passed to a
/// `MeasuredStatelessWidget` subclass.
///
/// [widgetName] is the name of the widget being measured.
///
/// [enabledPerformance] determines if performance measurement is enabled or not.
///
/// [traceName] is an optional parameter that defaults to a generated trace name
/// based on the [widgetName] if not provided. Default:
/// `'trace_perf_render_build_$widgetName'`
///
/// Example usage:
/// ```dart
/// final WidgetConfig _widgetConfig = WidgetConfig(
///   widgetName: 'my_widget',
///   enabledPerformance: true,
///   traceName: 'custom_trace_name',
/// );
///
/// class MyWidget extends MeasuredStatelessWidget {
///   MyWidget(): super(widgetConfig: _widgetConfig);
///
///   @override
///   Widget measuredBuild(BuildContext context) {
///     // Your widget building logic here
///   }
/// }
/// ```
class WidgetConfig {
  const WidgetConfig({
    required this.widgetName,
    this.enabledPerformance,
    String? traceName,
  }) : traceName = (traceName != null && traceName != '')
            ? traceName
            : 'trace_perf_render_build_$widgetName';

  final bool? enabledPerformance;
  final String traceName;
  final String widgetName;
}
