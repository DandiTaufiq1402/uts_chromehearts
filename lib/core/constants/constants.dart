import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  // PENTING:
  // - Kalau pakai Emulator Android, gunakan: http://10.0.2.2:8087/v1
  // - Kalau pakai Web / Chrome, gunakan: http://localhost:8087/v1
  // - Kalau pakai HP Asli, ganti dengan IP Laptop kamu.
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8087/v1';
    } else if (Platform.isAndroid) {
      // Gunakan IP Laptop dengan Port 8087 (Backend E-Commerce)
      return 'http://192.168.100.140:8087/v1';
    } else {
      return 'http://192.168.100.140:8087/v1';
    }
  }
}
