import 'package:doctor_appointment_app/views/appointment/data/appointment_database.dart';
import 'package:doctor_appointment_app/views/appointment/models/appointment_booking.dart';
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

  Future<void> addBooking({
    required DoctorItem doctor,
    required DateTime dateTime,
  }) async {
    await _loadingFuture;

    _idCounter += 1;
    final booking = AppointmentBooking(
      id: 'appt_${_idCounter.toString().padLeft(3, '0')}',
      doctorName: doctor.name,
      specialty: doctor.specialty,
      hospital: doctor.hospitalName,
      imagePath: doctor.imageAssetPath ?? 'assets/images/doctor.png',
      dateTime: dateTime,
    );
    _bookings.add(booking);
    notifyListeners();

    try {
      await _database.insertBooking(booking);
    } catch (_) {
      // Keep in-memory booking even if persistence is unavailable.
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    await _loadingFuture;

    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index < 0) {
      return;
    }
    final removed = _bookings.removeAt(index);
    notifyListeners();

    try {
      await _database.deleteBooking(bookingId);
    } catch (_) {
      // Roll back local change if DB delete fails.
      _bookings.insert(index, removed);
      notifyListeners();
    }
  }

  Future<void> rescheduleBooking(String bookingId, DateTime newDateTime) async {
    await _loadingFuture;

    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index < 0) {
      return;
    }

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
    if (index < 0) {
      return;
    }

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

  Future<void> rebookFrom({
    required AppointmentBooking source,
    required DateTime dateTime,
  }) async {
    await _loadingFuture;

    _idCounter += 1;
    final booking = AppointmentBooking(
      id: 'appt_${_idCounter.toString().padLeft(3, '0')}',
      doctorName: source.doctorName,
      specialty: source.specialty,
      hospital: source.hospital,
      imagePath: source.imagePath,
      dateTime: dateTime,
      status: AppointmentStatus.upcoming,
    );
    _bookings.add(booking);
    notifyListeners();

    try {
      await _database.insertBooking(booking);
    } catch (_) {
      _bookings.removeWhere((b) => b.id == booking.id);
      notifyListeners();
    }
  }

  Future<void> _loadBookings() async {
    try {
      final storedBookings = await _database.getAllBookings().timeout(
        const Duration(seconds: 5),
      );
      if (storedBookings.isEmpty) {
        final seeds = _seedBookings;
        _bookings
          ..clear()
          ..addAll(seeds);
        await _database.insertMany(seeds);
      } else {
        _bookings
          ..clear()
          ..addAll(storedBookings);
      }
    } catch (_) {
      // Fallback for unsupported platforms or init failures.
      _bookings
        ..clear()
        ..addAll(_seedBookings);
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
      if (parts.length != 2) {
        continue;
      }
      final parsed = int.tryParse(parts[1]);
      if (parsed != null && parsed > _idCounter) {
        _idCounter = parsed;
      }
    }
  }
}

final List<AppointmentBooking> _seedBookings = <AppointmentBooking>[
  AppointmentBooking(
    id: 'appt_001',
    doctorName: 'Nguyễn Văn C',
    specialty: 'Chuyên khoa Da liễu',
    hospital: 'Phòng Khám Da Liễu Hồng Đức',
    imagePath: 'assets/images/doctor.png',
    dateTime: DateTime(2026, 3, 22, 10, 0),
    status: AppointmentStatus.upcoming,
  ),
  AppointmentBooking(
    id: 'appt_002',
    doctorName: 'Nguyễn Văn D',
    specialty: 'Chuyên khoa Tim mạch',
    hospital: 'Bệnh viện Quốc tế DoLife',
    imagePath: 'assets/images/doctor.png',
    dateTime: DateTime(2026, 3, 25, 10, 0),
    status: AppointmentStatus.upcoming,
  ),
  AppointmentBooking(
    id: 'appt_003',
    doctorName: 'Nguyễn Văn E',
    specialty: 'Chuyên khoa Da liễu',
    hospital: 'Phòng Khám Da Liễu Hồng Đức',
    imagePath: 'assets/images/doctor.png',
    dateTime: DateTime(2026, 3, 10, 9, 30),
    status: AppointmentStatus.completed,
  ),
];
