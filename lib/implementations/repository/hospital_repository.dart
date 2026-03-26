import 'package:doctor_appointment_app/data/implementations/local/database_helper.dart';
import 'package:doctor_appointment_app/views/home/models/hospital_item.dart';
import 'package:sqflite/sqflite.dart';

class HospitalRepository {
  HospitalRepository({DatabaseHelper? databaseHelper})
      : _dbHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _dbHelper;

  Future<List<HospitalItem>> getAllHospitals() async {
    final db = await _dbHelper.database;
    final result = await db.query('hospitals', orderBy: 'name ASC');
    return result.map((json) => HospitalItem.fromMap(json)).toList();
  }

  Future<bool> addHospital(HospitalItem hospital) async {
    final db = await _dbHelper.database;
    final rowId = await db.insert(
      'hospitals',
      hospital.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    return rowId > 0;
  }

  Future<bool> updateHospital(HospitalItem hospital) async {
    final db = await _dbHelper.database;
    final updated = await db.update(
      'hospitals',
      hospital.toMap(),
      where: 'id = ?',
      whereArgs: [hospital.id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    return updated > 0;
  }

  Future<bool> deleteHospital(String hospitalId) async {
    final db = await _dbHelper.database;
    final deleted = await db.delete(
      'hospitals',
      where: 'id = ?',
      whereArgs: [hospitalId],
    );
    return deleted > 0;
  }
}
