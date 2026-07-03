enum BiometricErrorCode {
  noBiometricHardware,  // Tidak ada sensor biometrik di perangkat
  notEnrolled,          // Sensor ada, tapi belum ada data sidik jari/wajah terdaftar
  temporaryLockout,     // Terkunci sementara (terlalu banyak percobaan gagal)
  biometricLockout,     // Terkunci permanen (butuh buka kunci perangkat dengan PIN dulu)
  userCanceled,         // User menekan tombol Batal
  systemCanceled,       // Sistem membatalkan (mis. ada telepon masuk)
  unknown,
}

class BiometricException implements Exception {
  final BiometricErrorCode code;
  final String message;
  final String userMessage;

  BiometricException({
    required this.code,
    this.message = '',
    required this.userMessage,
  });

  // Tampilkan tombol "Coba Lagi"?
  bool get isRetryable => 
      code == BiometricErrorCode.userCanceled ||
      code == BiometricErrorCode.systemCanceled ||
      code == BiometricErrorCode.unknown;

  // Tampilkan tombol "Buka Pengaturan"?
  bool get requiresSettings => code == BiometricErrorCode.notEnrolled;

  // Otomatis pindah ke form password?
  bool get requiresFallback => 
      code == BiometricErrorCode.noBiometricHardware ||
      code == BiometricErrorCode.biometricLockout;
}