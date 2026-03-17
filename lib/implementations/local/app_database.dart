// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
//
// class AppDatabase {
//   AppDatabase._();
//
//   static final AppDatabase instance = AppDatabase._();
//
//   Database? _db;
//
//   Future<Database> get db async {
//     _db ??= await _open();
//     return _db!;
//   }
//
//   final List<Map<String, dynamic>> seedDoctors = [
//     {
//       'id': 'd1',
//       'name': 'BS. Nguyễn Văn An',
//       'specialty': 'Tim mạch',
//       'hospitalName': 'Bệnh viện Quốc tế DoLife',
//       'rating': 4.9,
//       'reviewCount': 120,
//       'imageAssetPath': 'assets/images/doctor.png',
//       'isFavorite': 1,
//     },
//     {
//       'id': 'd2',
//       'name': 'BS. Trần Thị Bình',
//       'specialty': 'Nha khoa',
//       'hospitalName': 'Bệnh viện Đa khoa Hồng Ngọc',
//       'rating': 4.8,
//       'reviewCount': 85,
//       'imageAssetPath': 'assets/images/doctor.png',
//       'isFavorite': 0,
//     },
//     // --- 6 Bác sĩ bổ sung ---
//     {
//       'id': 'd3',
//       'name': 'BS. Lê Hoàng Nam',
//       'specialty': 'Tim mạch',
//       'hospitalName': 'Bệnh viện Đa khoa Quốc tế Vinmec',
//       'rating': 5.0,
//       'reviewCount': 210,
//       'imageAssetPath': 'assets/images/doctor.png',
//       'isFavorite': 0,
//     },
//     {
//       'id': 'd4',
//       'name': 'BS. Phạm Minh Tuấn',
//       'specialty': 'Đa khoa',
//       'hospitalName': 'Bệnh viện Việt Pháp Hà Nội',
//       'rating': 4.7,
//       'reviewCount': 95,
//       'imageAssetPath': 'assets/images/doctor.png',
//       'isFavorite': 1,
//     },
//     {
//       'id': 'd5',
//       'name': 'BS. Hoàng Thanh Trúc',
//       'specialty': 'Hô hấp',
//       'hospitalName': 'Bệnh viện Quốc tế DoLife',
//       'rating': 4.6,
//       'reviewCount': 56,
//       'imageAssetPath': 'assets/images/doctor.png',
//       'isFavorite': 0,
//     },
//     {
//       'id': 'd6',
//       'name': 'BS. Ngô Đức Mạnh',
//       'specialty': 'Nha khoa',
//       'hospitalName': 'Bệnh viện Việt Pháp Hà Nội',
//       'rating': 4.9,
//       'reviewCount': 142,
//       'imageAssetPath': 'assets/images/doctor.png',
//       'isFavorite': 0,
//     },
//     {
//       'id': 'd7',
//       'name': 'BS. Đặng Thu Thảo',
//       'specialty': 'Đa khoa',
//       'hospitalName': 'Bệnh viện Đa khoa Hồng Ngọc',
//       'rating': 4.8,
//       'reviewCount': 78,
//       'imageAssetPath': 'assets/images/doctor.png',
//       'isFavorite': 0,
//     },
//     {
//       'id': 'd8',
//       'name': 'BS. Vũ Hải Đăng',
//       'specialty': 'Hô hấp',
//       'hospitalName': 'Bệnh viện Đa khoa Quốc tế Vinmec',
//       'rating': 4.5,
//       'reviewCount': 34,
//       'imageAssetPath': 'assets/images/doctor.png',
//       'isFavorite': 1,
//     },
//   ];
//
//   // Chèn dữ liệu mẫu (Seed Data)
//   final List<Map<String, dynamic>> seedHospitals = [
//     {
//       'id': 'h1',
//       'name': 'Bệnh viện Quốc tế DoLife',
//       'address': '108 Nguyễn Hoàng, Nam Từ Liêm, Hà Nội',
//       'rating': 4.8,
//       'reviewCount': 1250,
//       'distanceKm': 1.2,
//       'etaMinutes': 8,
//       'typeLabel': 'Đa khoa Quốc tế',
//       'imageAssetPath': 'assets/images/hospital_demo.jpg',
//       'isBookmarked': 0,
//     },
//     {
//       'id': 'h2',
//       'name': 'Bệnh viện Đa khoa Hồng Ngọc',
//       'address': '55 Yên Ninh, Ba Đình, Hà Nội',
//       'rating': 4.7,
//       'reviewCount': 3100,
//       'distanceKm': 4.5,
//       'etaMinutes': 20,
//       'typeLabel': 'Đa khoa Tư nhân',
//       'imageAssetPath': 'assets/images/hospital_demo.jpg',
//       'isBookmarked': 1,
//     },
//     {
//       'id': 'h3',
//       'name': 'Bệnh viện Đa khoa Quốc tế Vinmec',
//       'address': '458 Minh Khai, Hai Bà Trưng, Hà Nội',
//       'rating': 4.9,
//       'reviewCount': 5600,
//       'distanceKm': 8.0,
//       'etaMinutes': 35,
//       'typeLabel': 'Đạt chuẩn JCI',
//       'imageAssetPath': 'assets/images/hospital_demo.jpg',
//       'isBookmarked': 0,
//     },
//     {
//       'id': 'h4',
//       'name': 'Bệnh viện Việt Pháp Hà Nội',
//       'address': '01 Phương Mai, Đống Đa, Hà Nội',
//       'rating': 4.6,
//       'reviewCount': 1800,
//       'distanceKm': 6.2,
//       'etaMinutes': 25,
//       'typeLabel': 'Tiêu chuẩn Pháp',
//       'imageAssetPath': 'assets/images/hospital_demo.jpg',
//       'isBookmarked': 0,
//     },
//   ];
//
//   Future<Database> _open() async {
//     final dbPath = await getDatabasesPath();
//     // Tên database đồng bộ với project của bạn
//     final path = join(dbPath, 'doctor_appointment.db');
//
//     return openDatabase(
//       path,
//       version: 1,
//       onCreate: (Database db, int version) async {
//         await db.execute('''
//     CREATE TABLE hospitals (
//       id TEXT PRIMARY KEY,
//       name TEXT NOT NULL,
//       address TEXT NOT NULL,
//       rating REAL,
//       reviewCount INTEGER,
//       distanceKm REAL,
//       etaMinutes INTEGER,
//       typeLabel TEXT,
//       imageAssetPath TEXT,
//       isBookmarked INTEGER
//     )
//     ''');
//
//         await db.execute('''
//         CREATE TABLE doctors (
//           id TEXT PRIMARY KEY,
//           name TEXT NOT NULL,
//           specialty TEXT NOT NULL,
//           hospitalName TEXT NOT NULL,
//           rating REAL,
//           reviewCount INTEGER,
//           imageAssetPath TEXT,
//           isFavorite INTEGER
//         )
//       ''');
//
//         for (var hospital in seedHospitals) {
//           await db.insert('hospitals', hospital);
//         }
//         for (var doctor in seedDoctors) {
//           await db.insert('doctors', doctor);
//         }
//       },
//       onUpgrade: (Database db, int oldVersion, int newVersion) async {
//         if (oldVersion < 2) {
//           await db.execute('''
//     CREATE TABLE hospitals (
//       id TEXT PRIMARY KEY,
//       name TEXT NOT NULL,
//       address TEXT NOT NULL,
//       rating REAL,
//       reviewCount INTEGER,
//       distanceKm REAL,
//       etaMinutes INTEGER,
//       typeLabel TEXT,
//       imageAssetPath TEXT,
//       isBookmarked INTEGER
//     )
//     ''');
//         }
//       },
//     );
//   }
//
//   // Đóng kết nối database khi không sử dụng
//   Future close() async {
//     final dbClient = await db;
//     dbClient.close();
//   }
// }
