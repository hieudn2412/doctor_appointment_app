import 'package:doctor_appointment_app/domain/entities/user.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Singleton helper to manage the local SQLite database.
class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  /// Returns the database instance, creating it if needed.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'doctor_appointment.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
    CREATE TABLE hospitals (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      address TEXT NOT NULL,
      rating REAL,
      reviewCount INTEGER,
      distanceKm REAL,
      etaMinutes INTEGER,
      typeLabel TEXT,
      imageAssetPath TEXT,
      isBookmarked INTEGER
    )
    ''');

          await db.execute('''
        CREATE TABLE doctors (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          specialty TEXT NOT NULL,
          hospitalName TEXT NOT NULL,
          rating REAL,
          reviewCount INTEGER,
          imageAssetPath TEXT,
          isFavorite INTEGER
        )
      ''');

          for (var hospital in seedHospitals) {
            await db.insert('hospitals', hospital);
          }
          for (var doctor in seedDoctors) {
            await db.insert('doctors', doctor);
          }

        }
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        phone TEXT,
        address TEXT,
        birth_date TEXT,
        gender TEXT,
        reset_code TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Trong _onCreate, sau CREATE TABLE:
    await db.execute('CREATE INDEX idx_users_email ON users(email)');

    // ── Insert Mock Account for Testing ──
    // Password '123456' hashed with SHA-256
    final bytes = utf8.encode('123456');
    final hashedPassword = sha256.convert(bytes).toString();

    await db.execute('''
    CREATE TABLE hospitals (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      address TEXT NOT NULL,
      rating REAL,
      reviewCount INTEGER,
      distanceKm REAL,
      etaMinutes INTEGER,
      typeLabel TEXT,
      imageAssetPath TEXT,
      isBookmarked INTEGER
    )
    ''');

    await db.execute('''
        CREATE TABLE doctors (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          specialty TEXT NOT NULL,
          hospitalName TEXT NOT NULL,
          rating REAL,
          reviewCount INTEGER,
          imageAssetPath TEXT,
          isFavorite INTEGER
        )
      ''');

    for (var hospital in seedHospitals) {
      await db.insert('hospitals', hospital);
    }
    for (var doctor in seedDoctors) {
      await db.insert('doctors', doctor);
    }

    await db.insert('users', {
      'name': 'User Test',
      'email': 'test@gmail.com',
      'password': hashedPassword,
      'phone': '0123456789',
      'address': 'Hà Nội, Việt Nam',
      'birth_date': '01/01/1990',
      'gender': 'Nam',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // ── User CRUD Operations ───────────────────────────────────────────────

  /// Insert a new user. Returns the row id.
  Future<int> insertUser(User user) async {
    final db = await database;
    return db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  /// Find a user by email. Returns `null` if not found.
  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  /// Find a user by email and password hash.
  Future<User?> getUserByEmailAndPassword(
      String email, String passwordHash) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email.trim().toLowerCase(), passwordHash],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  /// Update the reset_code for a user (used for forgot password OTP).
  Future<int> updateResetCode(String email, String? resetCode) async {
    final db = await database;
    return db.update(
      'users',
      {'reset_code': resetCode},
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
    );
  }

  /// Update the password for a user (used after OTP verification).
  Future<int> updatePassword(String email, String newPasswordHash) async {
    final db = await database;
    return db.update(
      'users',
      {
        'password': newPasswordHash,
        'reset_code': null, // clear OTP after password change
      },
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
    );
  }

  /// Update user profile fields.
  Future<int> updateUserProfile(
    String email, {
    String? name,
    String? phone,
    String? address,
    String? birthDate,
    String? gender,
  }) async {
    final db = await database;
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (phone != null) data['phone'] = phone;
    if (address != null) data['address'] = address;
    if (birthDate != null) data['birth_date'] = birthDate;
    if (gender != null) data['gender'] = gender;
    if (data.isEmpty) return 0;

    return db.update(
      'users',
      data,
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
    );
  }

  /// Check if an email already exists in the DB.
  Future<bool> emailExists(String email) async {
    final user = await getUserByEmail(email);
    return user != null;
  }

  /// Get all users (for debugging purposes).
  Future<List<User>> getAllUsers() async {
    final db = await database;
    final result = await db.query('users');
    return result.map((map) => User.fromMap(map)).toList();
  }

  /// Delete a user by email.
  Future<int> deleteUser(String email) async {
    final db = await database;
    return db.delete(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
    );
  }

  /// Close the database.
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  final List<Map<String, dynamic>> seedDoctors = [
    {
      'id': 'd1',
      'name': 'BS. Nguyễn Văn An',
      'specialty': 'Tim mạch',
      'hospitalName': 'Bệnh viện Quốc tế DoLife',
      'rating': 4.9,
      'reviewCount': 120,
      'imageAssetPath': 'assets/images/doctor.png',
      'isFavorite': 1,
    },
    {
      'id': 'd2',
      'name': 'BS. Trần Thị Bình',
      'specialty': 'Nha khoa',
      'hospitalName': 'Bệnh viện Đa khoa Hồng Ngọc',
      'rating': 4.8,
      'reviewCount': 85,
      'imageAssetPath': 'assets/images/doctor.png',
      'isFavorite': 0,
    },
    // --- 6 Bác sĩ bổ sung ---
    {
      'id': 'd3',
      'name': 'BS. Lê Hoàng Nam',
      'specialty': 'Tim mạch',
      'hospitalName': 'Bệnh viện Đa khoa Quốc tế Vinmec',
      'rating': 5.0,
      'reviewCount': 210,
      'imageAssetPath': 'assets/images/doctor.png',
      'isFavorite': 0,
    },
    {
      'id': 'd4',
      'name': 'BS. Phạm Minh Tuấn',
      'specialty': 'Đa khoa',
      'hospitalName': 'Bệnh viện Việt Pháp Hà Nội',
      'rating': 4.7,
      'reviewCount': 95,
      'imageAssetPath': 'assets/images/doctor.png',
      'isFavorite': 1,
    },
    {
      'id': 'd5',
      'name': 'BS. Hoàng Thanh Trúc',
      'specialty': 'Hô hấp',
      'hospitalName': 'Bệnh viện Quốc tế DoLife',
      'rating': 4.6,
      'reviewCount': 56,
      'imageAssetPath': 'assets/images/doctor.png',
      'isFavorite': 0,
    },
    {
      'id': 'd6',
      'name': 'BS. Ngô Đức Mạnh',
      'specialty': 'Nha khoa',
      'hospitalName': 'Bệnh viện Việt Pháp Hà Nội',
      'rating': 4.9,
      'reviewCount': 142,
      'imageAssetPath': 'assets/images/doctor.png',
      'isFavorite': 0,
    },
    {
      'id': 'd7',
      'name': 'BS. Đặng Thu Thảo',
      'specialty': 'Đa khoa',
      'hospitalName': 'Bệnh viện Đa khoa Hồng Ngọc',
      'rating': 4.8,
      'reviewCount': 78,
      'imageAssetPath': 'assets/images/doctor.png',
      'isFavorite': 0,
    },
    {
      'id': 'd8',
      'name': 'BS. Vũ Hải Đăng',
      'specialty': 'Hô hấp',
      'hospitalName': 'Bệnh viện Đa khoa Quốc tế Vinmec',
      'rating': 4.5,
      'reviewCount': 34,
      'imageAssetPath': 'assets/images/doctor.png',
      'isFavorite': 1,
    },
  ];

  // Chèn dữ liệu mẫu (Seed Data)
  final List<Map<String, dynamic>> seedHospitals = [
    {
      'id': 'h1',
      'name': 'Bệnh viện Quốc tế DoLife',
      'address': '108 Nguyễn Hoàng, Nam Từ Liêm, Hà Nội',
      'rating': 4.8,
      'reviewCount': 1250,
      'distanceKm': 1.2,
      'etaMinutes': 8,
      'typeLabel': 'Đa khoa Quốc tế',
      'imageAssetPath': 'assets/images/hospital_demo.jpg',
      'isBookmarked': 0,
    },
    {
      'id': 'h2',
      'name': 'Bệnh viện Đa khoa Hồng Ngọc',
      'address': '55 Yên Ninh, Ba Đình, Hà Nội',
      'rating': 4.7,
      'reviewCount': 3100,
      'distanceKm': 4.5,
      'etaMinutes': 20,
      'typeLabel': 'Đa khoa Tư nhân',
      'imageAssetPath': 'assets/images/hospital_demo.jpg',
      'isBookmarked': 1,
    },
    {
      'id': 'h3',
      'name': 'Bệnh viện Đa khoa Quốc tế Vinmec',
      'address': '458 Minh Khai, Hai Bà Trưng, Hà Nội',
      'rating': 4.9,
      'reviewCount': 5600,
      'distanceKm': 8.0,
      'etaMinutes': 35,
      'typeLabel': 'Đạt chuẩn JCI',
      'imageAssetPath': 'assets/images/hospital_demo.jpg',
      'isBookmarked': 0,
    },
    {
      'id': 'h4',
      'name': 'Bệnh viện Việt Pháp Hà Nội',
      'address': '01 Phương Mai, Đống Đa, Hà Nội',
      'rating': 4.6,
      'reviewCount': 1800,
      'distanceKm': 6.2,
      'etaMinutes': 25,
      'typeLabel': 'Tiêu chuẩn Pháp',
      'imageAssetPath': 'assets/images/hospital_demo.jpg',
      'isBookmarked': 0,
    },
  ];
}
