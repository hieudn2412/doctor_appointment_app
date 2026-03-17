import 'package:doctor_appointment_app/data/implementations/local/database_helper.dart';
import 'package:doctor_appointment_app/views/appointment/models/appointment_booking.dart';
import 'package:sqflite/sqflite.dart';

class AppointmentDatabase {
  AppointmentDatabase._() {
    _initFuture = _createTableIfNeeded();
  }

  static final AppointmentDatabase instance = AppointmentDatabase._();

  static const String _tableName = 'appointments';

  late final Future<void> _initFuture;

  Future<void> _createTableIfNeeded() async {
    final db = await DatabaseHelper.instance.database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id TEXT PRIMARY KEY,
        doctor_name TEXT NOT NULL,
        specialty TEXT NOT NULL,
        hospital TEXT NOT NULL,
        image_path TEXT NOT NULL,
        date_time_ms INTEGER NOT NULL,
        status TEXT NOT NULL
      )
    ''');
  }

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

  Future<void> insertMany(List<AppointmentBooking> bookings) async {
    await _initFuture;
    final db = await DatabaseHelper.instance.database;
    await db.transaction((txn) async {
      for (final booking in bookings) {
        await txn.insert(
          _tableName,
          booking.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
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
}
