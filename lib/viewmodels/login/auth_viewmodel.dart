import 'dart:math';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:doctor_appointment_app/data/implementations/local/database_helper.dart';
import 'package:doctor_appointment_app/data/implementations/local/session_manager.dart';
import 'package:doctor_appointment_app/domain/entities/user.dart';
import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  static final AuthViewModel _instance = AuthViewModel._internal();
  factory AuthViewModel() => _instance;
  AuthViewModel._internal();

  final DatabaseHelper _db = DatabaseHelper.instance;
  final SessionManager _session = SessionManager.instance;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// User hiện tại — lấy từ SessionManager để đồng bộ toàn app.
  User? get currentUser => _session.currentUser;

  // ── Password Hashing ─────────────────────────────────────────────────

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // Dùng Random.secure() cho OTP bảo mật
  String _generateOtp() {
    final random = Random.secure();
    return List.generate(5, (_) => random.nextInt(10)).join();
  }

  // ── Validators ───────────────────────────────────────────────────────

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập email';
    final emailRegex = RegExp(r'^[\w\-.+]+@[\w\-]+\.\w{2,}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Email không hợp lệ';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (value.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập họ và tên';
    return null;
  }

  String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập lại mật khẩu';
    if (value != password) return 'Mật khẩu không khớp';
    return null;
  }

  String? validateOtp(String otp) {
    if (otp.length < 5) return 'Vui lòng nhập đầy đủ mã xác minh';
    return null;
  }

  // ── Actions ──────────────────────────────────────────────────────────

  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final hashedPassword = _hashPassword(password);
      final user = await _db.getUserByEmailAndPassword(
        email.trim().toLowerCase(),
        hashedPassword,
      );

      if (user == null) {
        _errorMessage = 'Email hoặc mật khẩu không đúng';
        _setLoading(false);
        return false;
      }

      // ✅ Lưu session khi đăng nhập thành công
      await _session.saveSession(user);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi hệ thống khi đăng nhập';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final exists = await _db.emailExists(normalizedEmail);
      if (exists) {
        _errorMessage = 'Email này đã được đăng ký';
        _setLoading(false);
        return false;
      }

      final hashedPassword = _hashPassword(password);
      final user = User(
        name: name.trim(),
        email: normalizedEmail,
        password: hashedPassword,
      );

      await _db.insertUser(user);

      // Lấy lại user từ DB để có đầy đủ thông tin (id, createdAt chính xác)
      final savedUser = await _db.getUserByEmail(normalizedEmail);
      if (savedUser != null) {
        // ✅ Lưu session khi đăng ký thành công
        await _session.saveSession(savedUser);
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi hệ thống khi đăng ký';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateProfile({
    required String email,
    String? name,
    String? phone,
    String? address,
    String? birthDate,
    String? gender,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final cleanName = (name != null && name.trim().isNotEmpty) ? name.trim() : null;
      final cleanPhone = (phone != null && phone.trim().isNotEmpty) ? phone.trim() : null;
      final cleanAddress = (address != null && address.trim().isNotEmpty) ? address.trim() : null;
      final cleanBirthDate = (birthDate != null && birthDate.trim().isNotEmpty) ? birthDate.trim() : null;

      await _db.updateUserProfile(
        email,
        name: cleanName,
        phone: cleanPhone,
        address: cleanAddress,
        birthDate: cleanBirthDate,
        gender: gender,
      );

      // Refresh session sau khi cập nhật profile
      final updatedUser = await _db.getUserByEmail(email);
      if (updatedUser != null) {
        await _session.updateSession(updatedUser);
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Cập nhật thất bại';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> sendResetCode({required String email}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final exists = await _db.emailExists(normalizedEmail);
      if (!exists) {
        _errorMessage = 'Email này chưa được đăng ký';
        _setLoading(false);
        return false;
      }
      final otp = _generateOtp();
      await _db.updateResetCode(normalizedEmail, otp);
      // Chỉ print trong debug mode. Thực tế cần tích hợp email service.
      debugPrint('⚠️ [DEV ONLY] OTP cho $normalizedEmail: $otp');
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Không thể gửi mã xác minh';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> verifyOtp({required String email, required String otp}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final user = await _db.getUserByEmail(email.trim().toLowerCase());
      if (user != null && user.resetCode != null && user.resetCode == otp) {
        _setLoading(false);
        return true;
      }
      _errorMessage = 'Mã xác minh không chính xác';
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Lỗi hệ thống khi xác minh';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    _errorMessage = null;

    if (password != confirmPassword) {
      _errorMessage = 'Mật khẩu không khớp';
      return false;
    }

    _setLoading(true);
    try {
      final normalizedEmail = email.trim().toLowerCase();

      // Kiểm tra resetCode phải tồn tại (đã qua verifyOtp) mới cho đổi mật khẩu
      final user = await _db.getUserByEmail(normalizedEmail);
      if (user == null || user.resetCode == null) {
        _errorMessage = 'Phiên xác minh không hợp lệ. Vui lòng thực hiện lại từ đầu.';
        _setLoading(false);
        return false;
      }

      final hashedPassword = _hashPassword(password);
      await _db.updatePassword(normalizedEmail, hashedPassword);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi khi đặt lại mật khẩu';
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Đăng xuất: xóa session và clear state.
  Future<void> logout() async {
    await _session.clearSession();
    notifyListeners();
  }
}
