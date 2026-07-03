import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/network/dio_client.dart';
import '../../core/services/secure_storage.dart';
import 'package:dio/dio.dart';

class AuthProvider with ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  // 1. REGISTER EMAIL & PASSWORD VIA FIREBASE
  Future<bool> register(String email, String password, String name) async {
    _setLoading(true);
    try {
      // 1. Register to Firebase
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Update display name
      await userCredential.user?.updateDisplayName(name);

      // 3. Kirim email verifikasi
      await userCredential.user?.sendEmailVerification();

      // 4. Logout (karena belum diverifikasi)
      await FirebaseAuth.instance.signOut();

      _setLoading(false);
      return true;
      
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Gagal registrasi di Firebase';
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan tidak terduga: $e';
      _setLoading(false);
      return false;
    }
  }

  // 2. LOGIN EMAIL & PASSWORD VIA FIREBASE
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      // 1. Login via Firebase
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 1.5. Cek verifikasi email (KITA DISABLE SEMENTARA AGAR MUDAH TESTING)
      // if (userCredential.user != null && !userCredential.user!.emailVerified) {
      //   _errorMessage = 'Email belum diverifikasi. Silakan cek inbox email Anda.';
      //   await FirebaseAuth.instance.signOut();
      //   _setLoading(false);
      //   return false;
      // }

      // 2. Get Firebase ID Token
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        _errorMessage = 'Gagal mendapatkan token Firebase';
        _setLoading(false);
        return false;
      }

      // 3. Send token to Go Backend
      final response = await DioClient.instance.post(
        '/auth/verify-token',
        data: {
          'firebase_token': idToken,
        },
      );

      if (response.statusCode == 200) {
        final token = response.data['data']?['access_token'];
        if (token != null) {
          await SecureStorageService.saveToken(token);
          _isAuthenticated = true;
          _errorMessage = null;
          _setLoading(false);
          notifyListeners();
          return true;
        }
      }
      
      _errorMessage = 'Token tidak ditemukan dalam respons backend';
      _setLoading(false);
      return false;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Email atau password salah';
      _setLoading(false);
      return false;
    } on DioException catch (e) {
      _errorMessage = e.response?.data?['message'] ?? 'Koneksi ke backend gagal: ${e.message}';
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan tidak terduga';
      _setLoading(false);
      return false;
    }
  }

  // 3. LOGIN GOOGLE VIA FIREBASE
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

      // Login to Firebase with Google Credential
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        _errorMessage = 'Token Firebase tidak ditemukan';
        _setLoading(false);
        return false;
      }

      // Kirim idToken ke Go backend untuk diverifikasi
      final response = await DioClient.instance.post(
        '/auth/verify-token',
        data: {
          'firebase_token': idToken,
        },
      );

      if (response.statusCode == 200) {
        final token = response.data['data']?['access_token'];
        if (token != null) {
          await SecureStorageService.saveToken(token);
          _isAuthenticated = true;
          _errorMessage = null;
          _setLoading(false);
          notifyListeners();
          return true;
        }
      }
      
      _setLoading(false);
      return false;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Gagal login dengan Google di Firebase';
      _setLoading(false);
      return false;
    } on DioException catch (e) {
      _errorMessage = e.response?.data?['message'] ?? 'Gagal login dengan Google di server backend';
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan tidak terduga';
      _setLoading(false);
      return false;
    }
  }

  // 4. LOGOUT
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await _googleSignIn.signOut();
    await SecureStorageService.clearAll();
    _isAuthenticated = false;
    notifyListeners();
  }

  // 5. CEK STATUS LOGIN SAAT BUKA APLIKASI
  Future<void> checkAuthStatus() async {
    final token = await SecureStorageService.getToken();
    
    if (token != null) {
      // Anda juga bisa melakukan validasi token ke backend di sini jika perlu
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