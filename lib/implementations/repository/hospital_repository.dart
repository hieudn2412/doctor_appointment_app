import 'package:doctor_appointment_app/data/implementations/local/database_helper.dart';

import 'package:doctor_appointment_app/views/home/models/hospital_item.dart';

class HospitalRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<List<HospitalItem>> getAllHospitals() async {
    final db = await dbHelper.database;
    final result = await db.query('hospitals');

    return result.map((json) => HospitalItem(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      rating: json['rating'] as double,
      reviewCount: json['reviewCount'] as int,
      distanceKm: json['distanceKm'] as double,
      etaMinutes: json['etaMinutes'] as int,
      typeLabel: json['typeLabel'] as String,
      imageAssetPath: json['imageAssetPath'] as String?,
      isBookmarked: json['isBookmarked'] == 1,
    )).toList();
  }
}