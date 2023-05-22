import 'package:flutter_test/flutter_test.dart';
import 'package:widget_perf_real_time/src/exception/performance_collection_exception.dart';

void main() {
  group('PerformanceCollectionException', () {
    test('should throw correct exception message', () {
      try {
        throw const PerformanceCollectionException('TestException');
      } catch (e) {
        expect(e.toString(), 'PerformanceCollectionException: TestException');
      }
    });
  });
}
