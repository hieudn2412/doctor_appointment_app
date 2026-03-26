import 'package:doctor_appointment_app/data/implementations/local/database_helper.dart';
import 'package:doctor_appointment_app/views/home/models/doctor_item.dart';
import 'package:sqflite/sqflite.dart';

class DoctorRepository {
  DoctorRepository({DatabaseHelper? databaseHelper})
      : _dbHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _dbHelper;

  // Lấy toàn bộ danh sách bác sĩ
  Future<List<DoctorItem>> getAllDoctors() async {
    final db = await _dbHelper.database;
    final result = await db.query('doctors', orderBy: 'name ASC');
    return result.map((json) => DoctorItem.fromMap(json)).toList();
  }

  // Tìm kiếm bác sĩ theo tên hoặc chuyên khoa
  Future<List<DoctorItem>> searchDoctors(String query) async {
    final db = await _dbHelper.database;
    final cleanQuery = query.trim();

    final result = cleanQuery.isEmpty
        ? await db.query('doctors', orderBy: 'name ASC')
        : await db.query(
            'doctors',
            where: 'name LIKE ? OR specialty LIKE ?',
            whereArgs: ['%$cleanQuery%', '%$cleanQuery%'],
            orderBy: 'name ASC',
          );

    return result.map((json) => DoctorItem.fromMap(json)).toList();
  }

  Future<bool> addDoctor(DoctorItem doctor) async {
    final db = await _dbHelper.database;
    final rowId = await db.insert(
      'doctors',
      doctor.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    return rowId > 0;
  }

  Future<bool> updateDoctor(DoctorItem doctor) async {
    final db = await _dbHelper.database;
    final updated = await db.update(
      'doctors',
      doctor.toMap(),
      where: 'id = ?',
      whereArgs: [doctor.id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    return updated > 0;
  }

  Future<bool> deleteDoctor(String doctorId) async {
    final db = await _dbHelper.database;
    final deleted = await db.delete(
      'doctors',
      where: 'id = ?',
      whereArgs: [doctorId],
    );
    return deleted > 0;
  }
}
