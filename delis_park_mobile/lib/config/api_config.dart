import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Isi dengan `--dart-define=API_BASE_URL=http://<IP>:5000`
  /// untuk HP fisik / jaringan LAN. Jika kosong, base URL dideteksi otomatis.
  static const String _explicit = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_explicit.isNotEmpty) return _explicit;
    if (kIsWeb) return 'http://localhost:5000';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Emulator Android memetakan host PC ke 10.0.2.2
        return 'http://10.0.2.2:5000';
      default:
        return 'http://localhost:5000';
    }
  }

  static String url(String path) => path.startsWith('http') ? path : '$baseUrl$path';
}
