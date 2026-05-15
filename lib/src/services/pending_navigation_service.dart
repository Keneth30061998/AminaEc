class PendingNavigationService {
  static Map<String, dynamic>? _pendingRoute;

  static void setPendingRoute({
    required String route,
    Map<String, dynamic>? arguments,
  }) {
    _pendingRoute = {
      'route': route,
      'arguments': arguments ?? {},
    };
  }

  static Map<String, dynamic>? consumePendingRoute() {
    final route = _pendingRoute;
    _pendingRoute = null;
    return route;
  }

  static bool get hasPendingRoute => _pendingRoute != null;
}