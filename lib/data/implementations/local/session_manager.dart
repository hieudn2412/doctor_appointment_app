import 'package:doctor_appointment_app/domain/entities/user.dart';
import 'package:doctor_appointment_app/data/implementations/local/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Quản lý session người dùng bằng SharedPreferences.
/// 
/// Khi đăng nhập thành công, thông tin user sẽ được lưu lại.
/// Các màn hình khác có thể gọi [SessionManager.instance.currentUser]
/// để lấy thông tin user hiện tại mà không cần truyền qua constructor.
class SessionManager {
  SessionManager._internal();

  static final SessionManager instance = SessionManager._internal();

  static const String _keyCurrentUserId = 'current_user_id';
  static const String _keyIsLoggedIn = 'is_logged_in';

  User? _currentUser;

  /// User hiện tại đang đăng nhập. Null nếu chưa đăng nhập.
  User? get currentUser => _currentUser;

  /// Kiểm tra nhanh xem có session hợp lệ không.
  bool get isLoggedIn => _currentUser != null;

  // ── Lưu session khi đăng nhập/đăng ký thành công ──────────────────────

  /// Lưu thông tin user vào SharedPreferences và giữ trong RAM.
  Future<void> saveSession(User user) async {
    if (user.id == null) {
      throw Exception('Không thể lưu session khi user chưa có id');
    }
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCurrentUserId, user.id!);
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  // ── Khôi phục session khi mở app ──────────────────────────────────────

  /// Gọi ở SplashScreen hoặc main.dart để khôi phục session.
  /// Trả về `true` nếu có session hợp lệ.
  Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    if (!isLoggedIn) return false;

    final userId = prefs.getInt(_keyCurrentUserId);
    if (userId == null) {
      await clearSession();
      return false;
    }

    try {
      final user = await DatabaseHelper.instance.getUserById(userId);
      if (user == null) {
        await clearSession();
        return false;
      }
      _currentUser = user;
      return true;
    } catch (_) {
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
    await prefs.remove(_keyCurrentUserId);
    await prefs.setBool(_keyIsLoggedIn, false);
  }
}
