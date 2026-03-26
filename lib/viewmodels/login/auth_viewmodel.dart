import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:doctor_appointment_app/config/app_env.dart';
import 'package:crypto/crypto.dart';
import 'package:doctor_appointment_app/data/implementations/local/database_helper.dart';
import 'package:doctor_appointment_app/data/implementations/local/session_manager.dart';
import 'package:doctor_appointment_app/domain/entities/user.dart';
import 'package:doctor_appointment_app/services/email_js_service.dart';
import 'package:doctor_appointment_app/views/appointment/data/appointment_booking_store.dart';
import 'package:doctor_appointment_app/views/home/data/notification_store.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AuthViewModel extends ChangeNotifier {
  static final AuthViewModel _instance = AuthViewModel._internal();
  factory AuthViewModel() => _instance;
  AuthViewModel._internal();

  final DatabaseHelper _db = DatabaseHelper.instance;
  final SessionManager _session = SessionManager.instance;

  EmailOtpService _emailOtpService = EmailJsService();
  bool _googleInitialized = false;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// User hiện tại — lấy từ SessionManager để đồng bộ toàn app.
  User? get currentUser => _session.currentUser;
  String? get currentUserEmail => _session.currentUser?.email;
  bool get isCurrentUserAdmin => _session.currentUser?.role == 'admin';

  @visibleForTesting
  void setEmailOtpServiceForTesting(EmailOtpService service) {
    _emailOtpService = service;
  }

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
    if (!RegExp(r'^\d{5}$').hasMatch(otp)) return 'Mã xác minh không hợp lệ';
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

      await _saveLoginSession(user);
      _setLoading(false);
      return true;
    } catch (_) {
      _errorMessage = 'Lỗi hệ thống khi đăng nhập';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final configError = await _validateGoogleOauthConfig();
      if (configError != null) {
        _errorMessage = configError;
        return false;
      }

      final gsi = GoogleSignIn.instance;
      await _initializeGoogleSignIn(gsi);
      final account = await gsi.authenticate();

      final success = await _completeGoogleLogin(account);
      return success;
    } on GoogleSignInException catch (e) {
      _errorMessage = _mapGoogleSignInException(e);
      if (kDebugMode) {
        debugPrint(
          'Google Sign-In Exception: code=${e.code.name}, description=${e.description}, details=${e.details}',
        );
      }
      return false;
    } catch (e) {
      _errorMessage = 'Đăng nhập Google thất bại';
      if (kDebugMode) {
        debugPrint('Google Sign-In error: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> _completeGoogleLogin(GoogleSignInAccount account) async {
    final googleId = account.id.trim();
    final email = account.email.trim().toLowerCase();
    final displayName = (account.displayName ?? '').trim();
    final avatarUrl = account.photoUrl?.trim();

    final userByGoogleId = await _db.getUserByGoogleId(googleId);
    final existingUser = userByGoogleId ?? await _db.getUserByEmail(email);
    late final User user;

    if (existingUser == null) {
      final createdUser = User(
        name: displayName.isEmpty ? email.split('@').first : displayName,
        email: email,
        password: _hashPassword(
          'google_${DateTime.now().millisecondsSinceEpoch}',
        ),
        role: 'user',
        googleId: googleId,
        authProvider: 'google',
        avatarUrl: avatarUrl,
      );

      final id = await _db.insertUser(createdUser);
      user = createdUser.copyWith(id: id);
    } else {
      final nextName = displayName.isEmpty ? existingUser.name : displayName;
      final nextAvatar = (avatarUrl != null && avatarUrl.isNotEmpty)
          ? avatarUrl
          : existingUser.avatarUrl;

      final existingId = existingUser.id;
      if (existingId == null) {
        _errorMessage = 'Tài khoản Google không hợp lệ';
        return false;
      }

      await _db.updateUserGoogleIdentity(
        existingId,
        googleId: googleId,
        email: email,
        name: nextName,
        avatarUrl: nextAvatar,
      );
      user = existingUser.copyWith(
        email: email,
        name: nextName,
        googleId: googleId,
        avatarUrl: nextAvatar,
        authProvider: 'google',
      );
    }

    await _saveLoginSession(user);
    return true;
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

      final user = User(
        name: name.trim(),
        email: normalizedEmail,
        password: _hashPassword(password),
        role: 'user',
        authProvider: 'local',
      );

      await _db.insertUser(user);

      final savedUser = await _db.getUserByEmail(normalizedEmail);
      if (savedUser == null) {
        _errorMessage = 'Không thể tạo tài khoản';
        _setLoading(false);
        return false;
      }

      await _saveLoginSession(savedUser);

      _setLoading(false);
      return true;
    } catch (_) {
      _errorMessage = 'Lỗi hệ thống khi đăng ký';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateProfile({
    String? email,
    String? name,
    String? phone,
    String? address,
    String? birthDate,
    String? gender,
    String? avatarUrl,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final targetEmail = (email ?? currentUserEmail)?.trim().toLowerCase();
      if (targetEmail == null || targetEmail.isEmpty) {
        _errorMessage = 'Không tìm thấy email người dùng hiện tại';
        _setLoading(false);
        return false;
      }

      final cleanName = (name != null && name.trim().isNotEmpty)
          ? name.trim()
          : null;
      final cleanPhone = (phone != null && phone.trim().isNotEmpty)
          ? phone.trim()
          : null;
      final cleanAddress = (address != null && address.trim().isNotEmpty)
          ? address.trim()
          : null;
      final cleanBirthDate = (birthDate != null && birthDate.trim().isNotEmpty)
          ? birthDate.trim()
          : null;
      final cleanAvatarUrl = (avatarUrl != null && avatarUrl.trim().isNotEmpty)
          ? avatarUrl.trim()
          : null;

      final updatedRows = await _db.updateUserProfile(
        targetEmail,
        name: cleanName,
        phone: cleanPhone,
        address: cleanAddress,
        birthDate: cleanBirthDate,
        gender: gender,
        avatarUrl: cleanAvatarUrl,
      );

      if (updatedRows <= 0) {
        _errorMessage = 'Không có dữ liệu nào được cập nhật';
        _setLoading(false);
        return false;
      }

      final updatedUser = await _db.getUserByEmail(targetEmail);
      if (updatedUser != null) {
        await _session.updateSession(updatedUser);
      }

      _setLoading(false);
      return true;
    } catch (_) {
      _errorMessage = 'Cập nhật thất bại';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> sendResetCode({required String email}) async {
    _setLoading(true);
    _errorMessage = null;
    final normalizedEmail = email.trim().toLowerCase();

    try {
      final user = await _db.getUserByEmail(normalizedEmail);
      if (user == null) {
        _errorMessage = 'Email này chưa được đăng ký';
        _setLoading(false);
        return false;
      }

      final otp = _generateOtp();
      final expiresAt = DateTime.now().add(const Duration(minutes: 10));

      final updatedRows = await _db.updateResetCode(
        normalizedEmail,
        resetCode: otp,
        expiresAt: expiresAt,
      );

      if (updatedRows <= 0) {
        _errorMessage = 'Không thể tạo mã xác minh';
        _setLoading(false);
        return false;
      }

      await _emailOtpService.sendResetOtp(
        toEmail: normalizedEmail,
        otpCode: otp,
        expiresAt: expiresAt,
      );

      if (kDebugMode) {
        debugPrint('OTP cho $normalizedEmail: $otp (hết hạn: $expiresAt)');
      }

      _setLoading(false);
      return true;
    } on EmailOtpException catch (e) {
      await _db.clearResetPasswordState(normalizedEmail);
      _errorMessage = e.message;
      if (kDebugMode) {
        debugPrint('Send OTP EmailJS error: ${e.message}');
      }
      _setLoading(false);
      return false;
    } catch (e) {
      await _db.clearResetPasswordState(normalizedEmail);
      _errorMessage = 'Không thể gửi mã xác minh qua email';
      if (kDebugMode) {
        debugPrint('Send OTP error: $e');
      }
      _setLoading(false);
      return false;
    }
  }

  Future<bool> verifyOtp({required String email, required String otp}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final user = await _db.getUserByEmail(email.trim().toLowerCase());
      if (user == null || user.resetCode == null) {
        _errorMessage = 'Mã xác minh không tồn tại';
        _setLoading(false);
        return false;
      }

      if (user.resetCode != otp) {
        _errorMessage = 'Mã xác minh không chính xác';
        _setLoading(false);
        return false;
      }

      final expiresAt = user.resetCodeExpiresAt;
      if (expiresAt == null || DateTime.now().isAfter(expiresAt)) {
        _errorMessage = 'Mã xác minh đã hết hạn';
        _setLoading(false);
        return false;
      }

      final updatedRows = await _db.markResetCodeVerified(email);
      if (updatedRows <= 0) {
        _errorMessage = 'Không thể xác minh mã OTP';
        _setLoading(false);
        return false;
      }

      _setLoading(false);
      return true;
    } catch (_) {
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
      final user = await _db.getUserByEmail(normalizedEmail);

      if (user == null) {
        _errorMessage = 'Email không tồn tại';
        _setLoading(false);
        return false;
      }

      final expiresAt = user.resetCodeExpiresAt;
      if (!user.resetCodeVerified ||
          expiresAt == null ||
          DateTime.now().isAfter(expiresAt)) {
        _errorMessage =
            'Phiên xác minh không hợp lệ hoặc đã hết hạn. Vui lòng thực hiện lại.';
        _setLoading(false);
        return false;
      }

      final updatedRows = await _db.updatePassword(
        normalizedEmail,
        _hashPassword(password),
      );
      if (updatedRows <= 0) {
        _errorMessage = 'Không thể đặt lại mật khẩu';
        _setLoading(false);
        return false;
      }

      _setLoading(false);
      return true;
    } catch (_) {
      _errorMessage = 'Lỗi khi đặt lại mật khẩu';
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _saveLoginSession(User user) async {
    await _session.saveSession(user);
    unawaited(_refreshAppointmentCacheSafe());
    unawaited(_refreshNotificationCacheSafe());
  }

  Future<void> _refreshAppointmentCacheSafe() async {
    try {
      await AppointmentBookingStore.instance.refreshForCurrentUser();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Refresh appointments after login failed: $e');
      }
    }
  }

  Future<void> _refreshNotificationCacheSafe() async {
    try {
      await NotificationStore.instance.refreshForCurrentUser();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Refresh notifications after login failed: $e');
      }
    }
  }

  /// Reload user hiện tại từ SQLite theo email đang đăng nhập.
  /// Trả về `null` nếu chưa có session.
  Future<User?> reloadCurrentUserByEmail() async {
    final email = currentUserEmail?.trim().toLowerCase();
    if (email == null || email.isEmpty) return null;

    final freshUser = await _db.getUserByEmail(email);
    if (freshUser != null) {
      await _session.updateSession(freshUser);
      notifyListeners();
      return freshUser;
    }

    return currentUser;
  }

  /// Đăng xuất: xóa session và clear state.
  Future<void> logout() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Ignore Google signOut errors in local app.
    }

    await _session.clearSession();
    AppointmentBookingStore.instance.clearCache();
    NotificationStore.instance.clearCache();
    notifyListeners();
  }

  String _mapGoogleSignInException(GoogleSignInException e) {
    switch (e.code) {
      case GoogleSignInExceptionCode.clientConfigurationError:
        return 'Google Sign-In cấu hình chưa đúng. Hãy kiểm tra đủ 4 biến GOOGLE_OAUTH_* trong .env.';
      case GoogleSignInExceptionCode.canceled:
        return 'Bạn đã hủy đăng nhập Google';
      default:
        final description = e.description?.trim();
        if (description != null && description.isNotEmpty) {
          return 'Đăng nhập Google thất bại: $description';
        }
        return 'Đăng nhập Google thất bại';
    }
  }

  Future<void> _initializeGoogleSignIn(GoogleSignIn gsi) async {
    if (_googleInitialized) return;
    await gsi.initialize(
      clientId: AppEnv.googleOauthAndroidClientId,
      serverClientId: AppEnv.googleOauthWebClientId,
    );
    _googleInitialized = true;
  }

  Future<String?> _validateGoogleOauthConfig() async {
    final missing = <String>[];
    if (AppEnv.googleOauthWebClientId.isEmpty) {
      missing.add('GOOGLE_OAUTH_WEB_CLIENT_ID');
    }
    if (AppEnv.googleOauthAndroidClientId.isEmpty) {
      missing.add('GOOGLE_OAUTH_ANDROID_CLIENT_ID');
    }
    if (AppEnv.googleOauthAndroidPackageName.isEmpty) {
      missing.add('GOOGLE_OAUTH_ANDROID_PACKAGE_NAME');
    }
    if (AppEnv.googleOauthAndroidSha1.isEmpty) {
      missing.add('GOOGLE_OAUTH_ANDROID_SHA1');
    }

    if (missing.isNotEmpty) {
      return 'Thiếu cấu hình Google OAuth: ${missing.join(', ')}';
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final appPackage = packageInfo.packageName.trim();
    if (appPackage != AppEnv.googleOauthAndroidPackageName.trim()) {
      return 'Package name không khớp. App đang chạy "$appPackage" nhưng .env là "${AppEnv.googleOauthAndroidPackageName}".';
    }

    if (kDebugMode) {
      debugPrint(
        'Google OAuth config loaded: web=${AppEnv.googleOauthWebClientId}, android=${AppEnv.googleOauthAndroidClientId}, package=${AppEnv.googleOauthAndroidPackageName}, sha1=${AppEnv.googleOauthAndroidSha1}',
      );
    }
    return null;
  }
}
