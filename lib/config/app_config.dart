/// Application configuration constants
class AppConfig {
  // Menu URL for QR Code and customer sharing
  // Change this to your actual menu website URL
  static const String menuUrl = 'https://Combo0445.github.io/AstroHouse/';

  // LINE Official Account ID for orders
  static const String lineOaId = '@158butwc';

  // Restaurant info
  static const String restaurantName = 'ASTRO GASTRONOMY';
  static const String restaurantPhone = '';
  static const String restaurantEmail = '';

  /// Get the full LINE order URL
  static String getLineOrderUrl(String message) {
    final encodedMessage = Uri.encodeComponent(message);
    return 'line://oaMessage/$lineOaId/?$encodedMessage';
  }

  /// Get the LINE web fallback URL
  static String getLineWebUrl(String message) {
    final encodedMessage = Uri.encodeComponent(message);
    return 'https://line.me/R/oaMessage/$lineOaId/?$encodedMessage';
  }
}
