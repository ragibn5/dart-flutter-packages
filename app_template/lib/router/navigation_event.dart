enum NavigationType { push, replace, pop }

class NavigationEvent {
  final NavigationType type;
  final String? fromRoute;
  final String toRoute;

  const NavigationEvent({
    required this.type,
    this.fromRoute,
    required this.toRoute,
  });
}
