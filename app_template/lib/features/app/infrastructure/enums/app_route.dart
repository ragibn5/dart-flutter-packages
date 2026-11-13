enum AppRoute {
  ROOT('root', '/'),
  LOGIN('login', '/login'),
  HOME('home', '/home');

  /// The route's name, to navigate to it by.
  final String routeName;

  /// The route's path, such as `/home`.
  final String path;

  const AppRoute(this.routeName, this.path);
}
