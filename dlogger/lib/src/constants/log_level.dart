enum LogLevel {
  DEBUG(1),
  INFO(2),
  WARNING(3),
  ERROR(4);

  final int priority;

  const LogLevel(this.priority);
}
