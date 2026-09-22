class AppConfig {
  // ── Change only this one line to switch environments ──────────────
  static const String baseUrl = 'https://qiktalk-backend-1.onrender.com';

  // ── Everything else is derived — never touch these ─────────────────
  static const String apiUrl = '$baseUrl/api/v1/';
  static const String socketUrl = 'wss://qiktalk-backend-1.onrender.com';
  static const String imageUrl = '$baseUrl/';
}
