class PerformanceCollectionException implements Exception {
  const PerformanceCollectionException(this.message);
  final String message;

  @override
  String toString() => 'PerformanceCollectionException: $message';
}
