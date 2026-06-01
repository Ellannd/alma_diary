
class AlmaNavigationRouter {
  static Function(String route)? onRoute;

  static void navigate(String route) {
    onRoute?.call(route);
  }
}