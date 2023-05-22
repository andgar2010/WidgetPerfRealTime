import 'package:firebase_performance/firebase_performance.dart';
import 'package:mocktail/mocktail.dart';
import 'package:widget_perf_real_time/widget_perf_real_time.dart';

class MockPerformanceMonitor extends Mock implements PerformanceMonitor {}

class MockFirebasePerformance extends Mock implements FirebasePerformance {}

class MockFirebasePerformanceMonitor extends Mock
    implements FirebasePerformanceMonitor {}

class MockTrace extends Mock implements Trace {}
