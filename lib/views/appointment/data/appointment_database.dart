import 'package:doctor_appointment_app/data/implementations/local/database_helper.dart';
import 'package:doctor_appointment_app/views/appointment/models/appointment_booking.dart';
import 'package:doctor_appointment_app/views/appointment/models/doctor_review.dart';
import 'package:sqflite/sqflite.dart';

class AppointmentDatabase {
  AppointmentDatabase._() {
    _initFuture = _createTableIfNeeded();
  }

  static final AppointmentDatabase instance = AppointmentDatabase._();

  static const String _tableName = 'appointments';
  static const String _reviewTable = 'doctor_reviews';

  late final Future<void> _initFuture;

  Future<void> _createTableIfNeeded() async {
    final db = await DatabaseHelper.instance.database;
    // Bảng appointments
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id TEXT PRIMARY KEY,
        doctor_id TEXT,
        doctor_name TEXT NOT NULL,
        specialty TEXT NOT NULL,
        hospital TEXT NOT NULL,
        image_path TEXT NOT NULL,
        date_time_ms INTEGER NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    // Bảng reviews
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_reviewTable (
        id TEXT PRIMARY KEY,
        doctor_id TEXT NOT NULL,
        rating INTEGER NOT NULL,
        content TEXT NOT NULL,
        user_name TEXT NOT NULL,
        created_at_ms INTEGER NOT NULL
      )
    ''');
  }

  // --- Logic Appointments ---

  Future<List<AppointmentBooking>> getAllBookings() async {
    await _initFuture;
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(_tableName, orderBy: 'date_time_ms ASC');
    return rows.map(AppointmentBooking.fromMap).toList();
  }

  Future<void> insertBooking(AppointmentBooking booking) async {
    await _initFuture;
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      _tableName,
      booking.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteBooking(String bookingId) async {
    await _initFuture;
    final db = await DatabaseHelper.instance.database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [bookingId]);
  }

  Future<void> updateBooking(AppointmentBooking booking) async {
    await _initFuture;
    final db = await DatabaseHelper.instance.database;
    await db.update(
      _tableName,
      booking.toMap(),
      where: 'id = ?',
      whereArgs: [booking.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // --- Logic Reviews ---

  Future<void> insertReview(DoctorReview review) async {
    await _initFuture;
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      _reviewTable,
      review.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DoctorReview>> getReviewsForDoctor(String doctorId) async {
    await _initFuture;
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      _reviewTable,
      where: 'doctor_id = ?',
      whereArgs: [doctorId],
      orderBy: 'created_at_ms DESC',
    );
    return rows.map(DoctorReview.fromMap).toList();
  }

  /// Trả về review duy nhất của user cho bác sĩ (nếu có).
  Future<DoctorReview?> getMyReviewForDoctor(String doctorId) async {
    await _initFuture;
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      _reviewTable,
      where: 'doctor_id = ?',
      whereArgs: [doctorId],
      orderBy: 'created_at_ms ASC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DoctorReview.fromMap(rows.first);
  }

  Future<void> updateReview(DoctorReview review) async {
    await _initFuture;
    final db = await DatabaseHelper.instance.database;
    await db.update(
      _reviewTable,
      review.toMap(),
      where: 'id = ?',
      whereArgs: [review.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
