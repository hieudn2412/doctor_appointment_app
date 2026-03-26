import 'package:doctor_appointment_app/data/implementations/local/session_manager.dart';
import 'package:doctor_appointment_app/views/appointment/data/appointment_database.dart';
import 'package:doctor_appointment_app/views/appointment/models/appointment_booking.dart';
import 'package:doctor_appointment_app/views/appointment/models/doctor_review.dart';
import 'package:doctor_appointment_app/views/home/data/notification_store.dart';
import 'package:doctor_appointment_app/views/home/models/doctor_item.dart';
import 'package:doctor_appointment_app/views/home/models/user_notification.dart';
import 'package:flutter/foundation.dart';

class AppointmentBookingStore extends ChangeNotifier {
  AppointmentBookingStore._() {
    _loadingFuture = _loadBookingsForCurrentUser();
  }

  static final AppointmentBookingStore instance = AppointmentBookingStore._();

  final AppointmentDatabase _database = AppointmentDatabase.instance;
  final List<AppointmentBooking> _bookings = <AppointmentBooking>[];
  late Future<void> _loadingFuture;

  bool _isLoaded = false;
  int _idCounter = 0;
  int _reviewIdCounter = 0;
  int? _loadedUserId;

  bool get isLoaded => _isLoaded;

  List<AppointmentBooking> get upcomingBookings {
    final result =
        _bookings.where((b) => b.status == AppointmentStatus.upcoming).toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return List.unmodifiable(result);
  }

  List<AppointmentBooking> get completedBookings {
    final result =
        _bookings.where((b) => b.status == AppointmentStatus.completed).toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return List.unmodifiable(result);
  }

  Future<void> refreshForCurrentUser() async {
    _loadingFuture = _loadBookingsForCurrentUser();
    await _loadingFuture;
  }

  void clearCache() {
    _bookings.clear();
    _loadedUserId = null;
    _idCounter = 0;
    _isLoaded = false;
    notifyListeners();
  }

  Future<String> addBooking({
    required DoctorItem doctor,
    required DateTime dateTime,
  }) async {
    await _ensureReadyForCurrentUser();

    if (_loadedUserId == null) {
      throw Exception('Vui lòng đăng nhập để đặt lịch hẹn');
    }

    _idCounter += 1;
    final booking = AppointmentBooking(
      id: 'appt_${_idCounter.toString().padLeft(3, '0')}',
      userId: _loadedUserId!,
      doctorId: doctor.id,
      doctorName: doctor.name,
      specialty: doctor.specialty,
      hospital: doctor.hospitalName,
      imagePath: doctor.imageAssetPath ?? 'assets/images/doctor.png',
      dateTime: dateTime,
      status: AppointmentStatus.upcoming,
    );

    _bookings.add(booking);
    notifyListeners();

    try {
      await _database.insertBooking(booking);
      await _createNotification(
        type: UserNotificationType.success,
        title: 'Đặt lịch thành công',
        message:
            'Bạn đã đặt lịch hẹn thành công với bác sĩ ${booking.doctorName}',
      );
      return booking.id;
    } catch (e) {
      _bookings.removeWhere((b) => b.id == booking.id);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    await _ensureReadyForCurrentUser();

    if (_loadedUserId == null) {
      throw Exception('Vui lòng đăng nhập để thao tác lịch hẹn');
    }

    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index < 0) return;

    final removed = _bookings.removeAt(index);
    notifyListeners();

    try {
      final deletedRows = await _database.deleteBooking(
        bookingId,
        _loadedUserId!,
      );
      if (deletedRows <= 0) {
        throw Exception('Không tìm thấy lịch hẹn để hủy');
      }
      await _createNotification(
        type: UserNotificationType.danger,
        title: 'Đã hủy lịch hẹn',
        message:
            'Bạn đã hủy lịch hẹn thành công với bác sĩ ${removed.doctorName}',
      );
    } catch (e) {
      _bookings.insert(index, removed);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> rescheduleBooking(String bookingId, DateTime newDateTime) async {
    await _ensureReadyForCurrentUser();

    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index < 0) return;

    final previous = _bookings[index];
    final updated = previous.copyWith(
      dateTime: newDateTime,
      status: AppointmentStatus.upcoming,
    );
    _bookings[index] = updated;
    notifyListeners();

    try {
      final updatedRows = await _database.updateBooking(updated);
      if (updatedRows <= 0) {
        throw Exception('Không thể đổi lịch hẹn');
      }
      await _createNotification(
        type: UserNotificationType.neutral,
        title: 'Đã thay đổi lịch hẹn',
        message:
            'Bạn đã thay đổi lịch hẹn với bác sĩ ${updated.doctorName} thành công',
      );
    } catch (e) {
      _bookings[index] = previous;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> markBookingCompleted(String bookingId) async {
    await _ensureReadyForCurrentUser();

    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index < 0) return;

    final previous = _bookings[index];
    final updated = previous.copyWith(status: AppointmentStatus.completed);
    _bookings[index] = updated;
    notifyListeners();

    try {
      final updatedRows = await _database.updateBooking(updated);
      if (updatedRows <= 0) {
        throw Exception('Không thể cập nhật trạng thái lịch hẹn');
      }
      await _createNotification(
        type: UserNotificationType.neutral,
        title: 'Đã hoàn tất lịch hẹn',
        message:
            'Bạn đã xác nhận hoàn tất lịch hẹn với bác sĩ ${updated.doctorName}',
      );
    } catch (e) {
      _bookings[index] = previous;
      notifyListeners();
      rethrow;
    }
  }

  // --- Logic Review ---

  /// Upsert: nếu user đã review bác sĩ này thì cập nhật, nếu chưa thì thêm mới.
  Future<void> addReview({
    required String doctorId,
    required int rating,
    required String content,
  }) async {
    await _ensureReadyForCurrentUser();

    final currentUser = SessionManager.instance.currentUser;
    if (currentUser == null || currentUser.id == null) {
      throw Exception('Vui lòng đăng nhập để đánh giá bác sĩ');
    }

    final currentUserName = currentUser.name.trim().isNotEmpty
        ? currentUser.name
        : 'Người dùng';

    final existing = await _database.getMyReviewForDoctor(
      userId: currentUser.id!,
      doctorId: doctorId,
    );

    if (existing != null) {
      final updated = DoctorReview(
        id: existing.id,
        userId: existing.userId,
        doctorId: existing.doctorId,
        rating: rating,
        content: content,
        userName: currentUserName,
        createdAt: DateTime.now(),
      );
      final updatedRows = await _database.updateReview(updated);
      if (updatedRows <= 0) {
        throw Exception('Không thể cập nhật đánh giá');
      }
    } else {
      _reviewIdCounter += 1;
      final review = DoctorReview(
        id: 'rev_${DateTime.now().millisecondsSinceEpoch}_$_reviewIdCounter',
        userId: currentUser.id!,
        doctorId: doctorId,
        rating: rating,
        content: content,
        userName: currentUserName,
        createdAt: DateTime.now(),
      );
      await _database.insertReview(review);
    }

    notifyListeners();
  }

  Future<List<DoctorReview>> getReviewsForDoctor(String doctorId) async {
    return _database.getReviewsForDoctor(doctorId);
  }

  /// Lấy review hiện tại của user cho bác sĩ (dùng để pre-fill form).
  Future<DoctorReview?> getMyReviewForDoctor(String doctorId) async {
    final userId = SessionManager.instance.currentUser?.id;
    if (userId == null) return null;
    return _database.getMyReviewForDoctor(userId: userId, doctorId: doctorId);
  }

  // --- Hệ thống ---

  Future<void> _ensureReadyForCurrentUser() async {
    await _loadingFuture;

    final currentUserId = SessionManager.instance.currentUser?.id;
    if (currentUserId != _loadedUserId) {
      _loadingFuture = _loadBookingsForCurrentUser();
      await _loadingFuture;
    }
  }

  Future<void> _loadBookingsForCurrentUser() async {
    final userId = SessionManager.instance.currentUser?.id;

    if (userId == null) {
      _bookings.clear();
      _loadedUserId = null;
      _syncIdCounter();
      _isLoaded = true;
      notifyListeners();
      return;
    }

    try {
      final storedBookings = await _database
          .getBookingsForUser(userId)
          .timeout(const Duration(seconds: 5));
      _bookings
        ..clear()
        ..addAll(storedBookings);
      _loadedUserId = userId;
    } catch (_) {
      _bookings.clear();
      _loadedUserId = userId;
    } finally {
      _syncIdCounter();
      _isLoaded = true;
      notifyListeners();
    }
  }

  void _syncIdCounter() {
    _idCounter = 0;
    for (final booking in _bookings) {
      final parts = booking.id.split('_');
      if (parts.length != 2) continue;
      final parsed = int.tryParse(parts[1]);
      if (parsed != null && parsed > _idCounter) {
        _idCounter = parsed;
      }
    }
  }

  Future<void> _createNotification({
    required UserNotificationType type,
    required String title,
    required String message,
  }) async {
    try {
      await NotificationStore.instance.addNotification(
        type: type,
        title: title,
        message: message,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Create notification failed: $e');
      }
    }
  }
}
