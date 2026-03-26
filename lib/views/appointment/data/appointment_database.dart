import 'package:doctor_appointment_app/data/implementations/local/database_helper.dart';
import 'package:doctor_appointment_app/views/appointment/models/appointment_booking.dart';
import 'package:doctor_appointment_app/views/appointment/models/doctor_review.dart';
import 'package:sqflite/sqflite.dart';

class AppointmentDatabase {
  AppointmentDatabase._();

  static final AppointmentDatabase instance = AppointmentDatabase._();

  static const String _tableName = 'appointments';
  static const String _reviewTable = 'doctor_reviews';

  Future<void> _createTableIfNeeded() async {
    final db = await DatabaseHelper.instance.database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id TEXT PRIMARY KEY,
        user_id INTEGER NOT NULL,
        doctor_id TEXT,
        doctor_name TEXT NOT NULL,
        specialty TEXT NOT NULL,
        hospital TEXT NOT NULL,
        image_path TEXT NOT NULL,
        date_time_ms INTEGER NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_reviewTable (
        id TEXT PRIMARY KEY,
        user_id INTEGER NOT NULL,
        doctor_id TEXT NOT NULL,
        rating INTEGER NOT NULL,
        content TEXT NOT NULL,
        user_name TEXT NOT NULL,
        created_at_ms INTEGER NOT NULL
      )
    ''');

    await _addColumnIfNotExists(db, _tableName, 'user_id', 'INTEGER NOT NULL DEFAULT 0');
    await _addColumnIfNotExists(db, _reviewTable, 'user_id', 'INTEGER NOT NULL DEFAULT 0');

    await db.execute('CREATE INDEX IF NOT EXISTS idx_appointments_user_id ON $_tableName(user_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_reviews_doctor_id ON $_reviewTable(doctor_id)');

    // Unique constraint cho dữ liệu mới user_id > 0.
    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_reviews_user_doctor_unique '
      'ON $_reviewTable(user_id, doctor_id) WHERE user_id > 0',
    );
  }

  Future<void> _addColumnIfNotExists(
    Database db,
    String table,
    String column,
    String definition,
  ) async {
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    final exists = columns.any((c) => c['name'] == column);
    if (!exists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $definition');
    }
  }

  // --- Logic Appointments ---

  Future<List<AppointmentBooking>> getBookingsForUser(int userId) async {
    await _createTableIfNeeded();
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      _tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date_time_ms ASC',
    );
    return rows.map(AppointmentBooking.fromMap).toList();
  }

  Future<void> insertBooking(AppointmentBooking booking) async {
    await _createTableIfNeeded();
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      _tableName,
      booking.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteBooking(String bookingId, int userId) async {
    await _createTableIfNeeded();
    final db = await DatabaseHelper.instance.database;
    return db.delete(
      _tableName,
      where: 'id = ? AND user_id = ?',
      whereArgs: [bookingId, userId],
    );
  }

  Future<int> updateBooking(AppointmentBooking booking) async {
    await _createTableIfNeeded();
    final db = await DatabaseHelper.instance.database;
    return db.update(
      _tableName,
      booking.toMap(),
      where: 'id = ? AND user_id = ?',
      whereArgs: [booking.id, booking.userId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // --- Logic Reviews ---

  Future<void> insertReview(DoctorReview review) async {
    await _createTableIfNeeded();
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      _reviewTable,
      review.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<DoctorReview>> getReviewsForDoctor(String doctorId) async {
    await _createTableIfNeeded();
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
  Future<DoctorReview?> getMyReviewForDoctor({
    required int userId,
    required String doctorId,
  }) async {
    await _createTableIfNeeded();
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      _reviewTable,
      where: 'user_id = ? AND doctor_id = ?',
      whereArgs: [userId, doctorId],
      orderBy: 'created_at_ms DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DoctorReview.fromMap(rows.first);
  }

  Future<int> updateReview(DoctorReview review) async {
    await _createTableIfNeeded();
    final db = await DatabaseHelper.instance.database;
    return db.update(
      _reviewTable,
      review.toMap(),
      where: 'id = ? AND user_id = ?',
      whereArgs: [review.id, review.userId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
