import 'dart:convert';
import 'package:doctor_appointment_app/domain/entities/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Quản lý session người dùng bằng SharedPreferences.
/// 
/// Khi đăng nhập thành công, thông tin user sẽ được lưu lại.
/// Các màn hình khác có thể gọi [SessionManager.instance.currentUser]
/// để lấy thông tin user hiện tại mà không cần truyền qua constructor.
class SessionManager {
  SessionManager._internal();

  static final SessionManager instance = SessionManager._internal();

  static const String _keyUserSession = 'user_session';
  static const String _keyIsLoggedIn = 'is_logged_in';

  User? _currentUser;

  /// User hiện tại đang đăng nhập. Null nếu chưa đăng nhập.
  User? get currentUser => _currentUser;

  /// Kiểm tra nhanh xem có session hợp lệ không.
  bool get isLoggedIn => _currentUser != null;

  // ── Lưu session khi đăng nhập/đăng ký thành công ──────────────────────

  /// Lưu thông tin user vào SharedPreferences và giữ trong RAM.
  Future<void> saveSession(User user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toMap());
    await prefs.setString(_keyUserSession, userJson);
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  // ── Khôi phục session khi mở app ──────────────────────────────────────

  /// Gọi ở SplashScreen hoặc main.dart để khôi phục session.
  /// Trả về `true` nếu có session hợp lệ.
  Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    if (!isLoggedIn) return false;

    final userJson = prefs.getString(_keyUserSession);
    if (userJson == null) return false;

    try {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      _currentUser = User.fromMap(map);
      return true;
    } catch (e) {
      // JSON hỏng → xóa session
      await clearSession();
      return false;
    }
  }

  // ── Cập nhật session (khi user sửa hồ sơ) ────────────────────────────

  /// Cập nhật lại thông tin user trong session (ví dụ sau khi updateProfile).
  Future<void> updateSession(User user) async {
    await saveSession(user);
  }

  // ── Xóa session khi đăng xuất ─────────────────────────────────────────

  /// Xóa toàn bộ session. Gọi khi đăng xuất.
  Future<void> clearSession() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserSession);
    await prefs.setBool(_keyIsLoggedIn, false);
  }
}
