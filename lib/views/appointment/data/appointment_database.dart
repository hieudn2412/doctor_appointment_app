import 'package:doctor_appointment_app/views/appointment/models/appointment_booking.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class AppointmentDatabase {
  AppointmentDatabase._() {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
  }

  static final AppointmentDatabase instance = AppointmentDatabase._();

  static const String _dbName = 'doctor_appointment.db';
  static const String _tableName = 'appointments';
  static const int _dbVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            doctor_name TEXT NOT NULL,
            specialty TEXT NOT NULL,
            hospital TEXT NOT NULL,
            image_path TEXT NOT NULL,
            date_time_ms INTEGER NOT NULL,
            status TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<AppointmentBooking>> getAllBookings() async {
    final db = await database;
    final rows = await db.query(_tableName, orderBy: 'date_time_ms ASC');
    return rows.map(AppointmentBooking.fromMap).toList();
  }

  Future<void> insertBooking(AppointmentBooking booking) async {
    final db = await database;
    await db.insert(
      _tableName,
      booking.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertMany(List<AppointmentBooking> bookings) async {
    final db = await database;
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
    final db = await database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [bookingId]);
  }

  Future<void> updateBooking(AppointmentBooking booking) async {
    final db = await database;
    await db.update(
      _tableName,
      booking.toMap(),
      where: 'id = ?',
      whereArgs: [booking.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
