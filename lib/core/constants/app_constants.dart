abstract class AppConstants {
  static const String appName = 'TV Remote';
  static const String appVersion = '1.0.0';

  // Discovery
  static const Duration discoveryTimeout = Duration(seconds: 10);
  static const Duration connectionTimeout = Duration(seconds: 5);

  // Rating
  static const int minUsesBeforeRating = 5;
  static const String ratingDeclinedKey = 'rating_declined_count';
  static const String usageCountKey = 'remote_usage_count';
  static const String hasRatedKey = 'has_rated_app';

  // Donation Links
  static const String kofiUrl = 'https://ko-fi.com/codyblharrl';
  static const String buyMeACoffeeUrl = 'https://buymeacoffee.com/codyblharrl';
  static const String githubUrl = 'https://github.com/codyblharrl/tv-remote';

  // TV Ports
  static const int samsungPort = 8001;
  static const int samsungSecurePort = 8002;
  static const int lgPort = 3000;
  static const int lgSecurePort = 3001;
  static const int rokuPort = 8060;
  static const int androidTvPort = 6466;
  static const int fireTvPort = 5555;
  static const int vizioPort = 7345;
  static const int vizioSecurePort = 9000;
  static const int sonyPort = 80;

  // Haptic
  static const Duration hapticDuration = Duration(milliseconds: 10);
}

abstract class StorageKeys {
  static const String lastConnectedDevice = 'last_connected_device';
  static const String savedDevices = 'saved_devices';
  static const String themeMode = 'theme_mode';
  static const String hapticEnabled = 'haptic_enabled';
  static const String quickActions = 'quick_actions';
  static const String hasSeenOnboarding = 'has_seen_onboarding';
}
