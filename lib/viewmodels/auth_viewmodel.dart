import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/media_service.dart';

/// ViewModel untuk semua operasi autentikasi.
/// Digunakan via Provider di seluruh app.
class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Untuk menyimpan data sementara antar step registrasi
  String? _pendingUid; // uid setelah register, sebelum upload selfie

  // ================================================================
  // GETTERS
  // ================================================================
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get pendingUid => _pendingUid;

  // ================================================================
  // LOGIN
  // ================================================================

  /// Login user. Returns true jika berhasil.
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      _currentUser = await _authService.signIn(email, password);
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ================================================================
  // BIOMETRIC, LUPA PASSWORD & REMEMBER ME
  // ================================================================

  Future<void> saveRememberMe(String email, bool isRemembered) async {
    await _authService.saveRememberMe(email, isRemembered);
  }

  Future<Map<String, dynamic>> getRememberMe() async {
    return await _authService.getRememberMe();
  }

  /// Reset Password by Email
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();
    try {
      if (email.isEmpty) throw Exception("Email tidak boleh kosong");
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ================================================================
  // UPDATE PROFILE & PASSWORD
  // ================================================================

  /// Update data profil pengguna
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();
    try {
      if (_currentUser == null) throw Exception("Sesi pengguna tidak valid");
      
      await _authService.updateProfile(_currentUser!.uid, data);
      
      // Refresh current user data
      _currentUser = await _authService.getUserByUid(_currentUser!.uid);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update kata sandi pengguna
  Future<bool> updatePassword(String oldPassword, String newPassword) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.updatePassword(oldPassword, newPassword);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Cek status aktif biometrik
  Future<bool> isBiometricEnabled() async {
    return await _authService.isBiometricEnabled();
  }

  /// Mematikan fitur biometrik
  Future<void> disableBiometric() async {
    await _authService.disableBiometric();
    notifyListeners();
  }

  /// Menghidupkan fitur biometrik (Hanya dapat dipanggil jika user sdh Login & memasukkan sandi untuk konfirmasi)
  Future<bool> enableBiometricWithReauth(String password) async {
    _setLoading(true);
    _clearError();
    try {
      if (_currentUser == null) throw Exception("Tidak ada user aktif");
      await _authService.saveBiometricCredentials(_currentUser!.email, password);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Login via Biometric (FaceID/Fingerprint)
  Future<bool> loginBiometric() async {
    _setLoading(true);
    _clearError();
    try {
      _currentUser = await _authService.loginWithBiometric();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ================================================================
  // REGISTER — STEP 1: Simpan data KTP + buat akun Auth + upload KTP
  // ================================================================

  /// Registrasi warga baru. Upload foto KTP ke Cloudinary, simpan ke Firestore.
  /// Returns true jika berhasil, false jika gagal (cek errorMessage).
  Future<bool> registerStep1({
    required String email,
    required String password,
    required Map<String, String> ktpData,
    File? ktpImageFile,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final uid = await _authService.registerWarga(
        email: email,
        password: password,
        ktpData: ktpData,
        ktpImageFile: ktpImageFile,
      );
      _pendingUid = uid;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ================================================================
  // REGISTER — STEP 2: Upload selfie
  // ================================================================

  /// Upload selfie ke Cloudinary dan update Firestore.
  /// Returns true jika berhasil.
  Future<bool> registerStep2(File selfieFile) async {
    if (_pendingUid == null) {
      _errorMessage = 'Sesi registrasi tidak valid. Mulai ulang dari awal.';
      notifyListeners();
      return false;
    }
    _setLoading(true);
    _clearError();
    try {
      await _authService.uploadSelfieAndFinish(_pendingUid!, selfieFile);
      // Langsung logout agar user perlu login manual (keamanan)
      await _authService.signOut();
      _clearPendingData();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 🐛 DEBUG ONLY: Skip selfie upload, langsung finalize registrasi.
  Future<bool> registerStep2Skip() async {
    if (_pendingUid == null) {
      _errorMessage = 'Sesi registrasi tidak valid. Mulai ulang dari awal.';
      notifyListeners();
      return false;
    }
    _setLoading(true);
    _clearError();
    try {
      await _authService.signOut();
      _clearPendingData();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ================================================================
  // LOAD USER (dipanggil saat AuthGate detect login)
  // ================================================================

  Future<void> loadCurrentUser(String uid) async {
    try {
      _currentUser = await _authService.getUserById(uid);
      notifyListeners();
    } catch (e) {
      debugPrint('[AuthViewModel] Gagal load user: $e');
    }
  }

  // ================================================================
  // UPDATE FOTO PROFIL
  // ================================================================

  /// Pilih foto dari galeri atau kamera lalu upload ke Cloudinary.
  /// Menyimpan URL baru di Firestore dan memperbarui currentUser.
  /// [fromCamera] = true → kamera, false → galeri.
  /// Returns true jika berhasil.
  Future<bool> updateProfilePhoto({bool fromCamera = false}) async {
    if (_currentUser == null) {
      _errorMessage = 'Tidak ada pengguna aktif.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();
    try {
      final mediaService = MediaService();
      final XFile? xFile = fromCamera
          ? await mediaService.pickImageXFileFromCamera()
          : await mediaService.pickImageXFileFromGallery();

      if (xFile == null) {
        // User batal memilih gambar
        return false;
      }

      final updatedUser = await _authService.updateProfilePhoto(
        _currentUser!.uid,
        xFile,
      );
      _currentUser = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ================================================================
  // LOGOUT
  // ================================================================

  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // ================================================================
  // HELPERS
  // ================================================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _clearPendingData() {
    _pendingUid = null;
  }
}
