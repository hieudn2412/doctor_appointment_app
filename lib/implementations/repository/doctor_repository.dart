import 'package:doctor_appointment_app/implementations/local/app_database.dart';
import 'package:doctor_appointment_app/views/home/models/doctor_item.dart'; // Đảm bảo đúng path

class DoctorRepository {
  final dbHelper = AppDatabase.instance;

  // Lấy toàn bộ danh sách bác sĩ
  Future<List<DoctorItem>> getAllDoctors() async {
    final db = await dbHelper.db;
    final result = await db.query('doctors');

    return result.map((json) => DoctorItem(
      id: json['id'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String,
      hospitalName: json['hospitalName'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      imageAssetPath: json['imageAssetPath'] as String?,
      isFavorite: json['isFavorite'] == 1,
    )).toList();
  }

  // Tìm kiếm bác sĩ theo tên hoặc chuyên khoa
  Future<List<DoctorItem>> searchDoctors(String query) async {
    final db = await dbHelper.db;
    final result = await db.query(
      'doctors',
      where: 'name LIKE ? OR specialty LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    return result.map((json) => DoctorItem(
      id: json['id'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String,
      hospitalName: json['hospitalName'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      imageAssetPath: json['imageAssetPath'] as String?,
      isFavorite: json['isFavorite'] == 1,
    )).toList();
  }
}