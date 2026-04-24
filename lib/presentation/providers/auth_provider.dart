import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/services/secure_storage.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  // 1. REGISTER EMAIL & PASSWORD
  Future<bool> register(String email, String password, String name) async {
    _setLoading(true);
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update nama user di Firebase
      await userCredential.user?.updateDisplayName(name);

      // Wajib kirim email verifikasi
      await userCredential.user?.sendEmailVerification();

      _setLoading(false);
      return true; // Sukses daftar, arahkan ke halaman verifikasi
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    }
  }

  // 2. LOGIN EMAIL & PASSWORD
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Cek apakah email sudah diverifikasi
      if (!userCredential.user!.emailVerified) {
        _errorMessage = 'Email belum diverifikasi. Silakan cek inbox Anda.';
        _setLoading(false);
        return false;
      }

      // Ambil Firebase Token dan kirim ke Golang
      String? firebaseToken = await userCredential.user?.getIdToken();
      if (firebaseToken != null) {
        return await _verifyTokenToBackend(firebaseToken);
      }
      
      _setLoading(false);
      return false;
    } on FirebaseAuthException catch (_) {
      _errorMessage = 'Email atau password salah';
      _setLoading(false);
      return false;
    }
  }

  // 3. LOGIN GOOGLE
  Future<bool> loginWithGoogle() async {
    _setLoading(true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _setLoading(false);
        return false; // User membatalkan login
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Ambil Firebase Token dan kirim ke Golang
      String? firebaseToken = await userCredential.user?.getIdToken();
      if (firebaseToken != null) {
        return await _verifyTokenToBackend(firebaseToken);
      }
      
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Gagal login dengan Google: $e';
      _setLoading(false);
      return false;
    }
  }

  // 4. JEMBATAN KE BACKEND GOLANG
  Future<bool> _verifyTokenToBackend(String firebaseToken) async {
    try {
      // Nembak API Golang yang tadi udah kita bikin
      final response = await DioClient.instance.post(
        '/auth/verify-token',
        data: {'firebase_token': firebaseToken},
      );

      if (response.statusCode == 200 && response.data['success']) {
        // Simpan JWT dari Golang ke Secure Storage yang aman
        final backendToken = response.data['data']['access_token'];
        await SecureStorageService.saveToken(backendToken);

        _isAuthenticated = true;
        _errorMessage = null;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Gagal verifikasi di server Golang';
        _setLoading(false);
        return false;
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? 'Tidak dapat terhubung ke server backend';
      _setLoading(false);
      return false;
    }
  }

  // 5. LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    await SecureStorageService.clearAll();
    _isAuthenticated = false;
    notifyListeners();
  }

  // 6. CEK STATUS LOGIN SAAT BUKA APLIKASI
  Future<void> checkAuthStatus() async {
    final token = await SecureStorageService.getToken();
    if (token != null) {
      _isAuthenticated = true;
    } else {
      _isAuthenticated = false;
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}