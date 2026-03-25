import 'package:doctor_appointment_app/data/implementations/local/session_manager.dart';
import 'package:doctor_appointment_app/views/appointment/data/appointment_database.dart';
import 'package:doctor_appointment_app/views/appointment/models/appointment_booking.dart';
import 'package:doctor_appointment_app/views/appointment/models/doctor_review.dart';
import 'package:doctor_appointment_app/views/home/models/doctor_item.dart';
import 'package:flutter/foundation.dart';

class AppointmentBookingStore extends ChangeNotifier {
  AppointmentBookingStore._() {
    _loadingFuture = _loadBookings();
  }

  static final AppointmentBookingStore instance = AppointmentBookingStore._();

  final AppointmentDatabase _database = AppointmentDatabase.instance;
  final List<AppointmentBooking> _bookings = <AppointmentBooking>[];
  late final Future<void> _loadingFuture;

  bool _isLoaded = false;
  int _idCounter = 0;
  int _reviewIdCounter = 0;

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

  Future<String> addBooking({
    required DoctorItem doctor,
    required DateTime dateTime,
  }) async {
    await _loadingFuture;

    _idCounter += 1;
    final booking = AppointmentBooking(
      id: 'appt_${_idCounter.toString().padLeft(3, '0')}',
      doctorId: doctor.id.toString(),
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
    } catch (_) {
    }

    return booking.id;
  }

  Future<void> cancelBooking(String bookingId) async {
    await _loadingFuture;

    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index < 0) return;
    
    final removed = _bookings.removeAt(index);
    notifyListeners();

    try {
      await _database.deleteBooking(bookingId);
    } catch (_) {
      _bookings.insert(index, removed);
      notifyListeners();
    }
  }

  Future<void> rescheduleBooking(String bookingId, DateTime newDateTime) async {
    await _loadingFuture;

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
      await _database.updateBooking(updated);
    } catch (_) {
      _bookings[index] = previous;
      notifyListeners();
    }
  }

  Future<void> markBookingCompleted(String bookingId) async {
    await _loadingFuture;

    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index < 0) return;

    final previous = _bookings[index];
    final updated = previous.copyWith(status: AppointmentStatus.completed);
    _bookings[index] = updated;
    notifyListeners();

    try {
      await _database.updateBooking(updated);
    } catch (_) {
      _bookings[index] = previous;
      notifyListeners();
    }
  }

  // --- Logic Review ---

  /// Upsert: nếu bác sĩ này đã có review thì cập nhật, nếu chưa thìm mới.
  Future<void> addReview({
    required String doctorId,
    required int rating,
    required String content,
  }) async {
    await _loadingFuture;

    // Lấy tên hiện tại của người dùng từ Session
    final currentUserName =
        SessionManager.instance.currentUser?.name?.trim().isNotEmpty == true
            ? SessionManager.instance.currentUser!.name!
            : 'Người dùng';

    // Kiểm tra xem đã có review cho bác sĩ này chưa
    final existing = await _database.getMyReviewForDoctor(doctorId);

    try {
      if (existing != null) {
        // Cập nhật review cũ (update cả tên nếu họ đã đổi tên)
        final updated = DoctorReview(
          id: existing.id,
          doctorId: existing.doctorId,
          rating: rating,
          content: content,
          userName: currentUserName,
          createdAt: DateTime.now(),
        );
        await _database.updateReview(updated);
      } else {
        // Tạo review mới
        _reviewIdCounter += 1;
        final review = DoctorReview(
          id: 'rev_${DateTime.now().millisecondsSinceEpoch}_$_reviewIdCounter',
          doctorId: doctorId,
          rating: rating,
          content: content,
          userName: currentUserName,
          createdAt: DateTime.now(),
        );
        await _database.insertReview(review);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving review: $e');
      rethrow;
    }
  }

  Future<List<DoctorReview>> getReviewsForDoctor(String doctorId) async {
    return await _database.getReviewsForDoctor(doctorId);
  }

  /// Lấy review hiện tại của user cho bác sĩ (dùng để pre-fill form).
  Future<DoctorReview?> getMyReviewForDoctor(String doctorId) async {
    return await _database.getMyReviewForDoctor(doctorId);
  }

  // --- Hệ thống ---

  Future<void> _loadBookings() async {
    try {
      final storedBookings = await _database.getAllBookings().timeout(
        const Duration(seconds: 5),
      );
      _bookings
        ..clear()
        ..addAll(storedBookings);
    } catch (_) {
      _bookings.clear();
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
}
