
class AlmaAuthSession {
  static bool _authenticated = true; // Siempre autenticado en desarrollo

  static Future<bool> ensureAuthenticated() async {
    return true;
  }

  static void reset() {
    _authenticated = true;
  }
}
