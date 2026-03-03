enum AppLogLevel {
  DEBUG(1),
  INFO(2),
  WARNING(3),
  ERROR(4);

  final int priority;

  const AppLogLevel(this.priority);
}
