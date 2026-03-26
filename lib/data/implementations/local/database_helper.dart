import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:doctor_appointment_app/domain/entities/user.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Singleton helper to manage the local SQLite database.
class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;
  static const int _databaseVersion = 3;

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
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: (db) async {
        await _ensureUserSchema(db);
        await _ensureHospitalDoctorTables(db);
        await _ensureAdminAccount(db);
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createUsersTable(db);
    await _ensureHospitalDoctorTables(db);
    await _seedDefaultUsers(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await _ensureUserSchema(db);
    await _ensureHospitalDoctorTables(db);
    await _ensureAdminAccount(db);
  }

  Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'user',
        google_id TEXT,
        auth_provider TEXT NOT NULL DEFAULT 'local',
        avatar_url TEXT,
        phone TEXT,
        address TEXT,
        birth_date TEXT,
        gender TEXT,
        reset_code TEXT,
        reset_code_expires_at TEXT,
        reset_code_verified INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_users_google_id ON users(google_id)',
    );
  }

  Future<void> _ensureUserSchema(Database db) async {
    final hasUsers = await _tableExists(db, 'users');
    if (!hasUsers) {
      await _createUsersTable(db);
      await _seedDefaultUsers(db);
      return;
    }

    await _addColumnIfNotExists(
      db,
      table: 'users',
      column: 'role',
      definition: "TEXT NOT NULL DEFAULT 'user'",
    );
    await _addColumnIfNotExists(
      db,
      table: 'users',
      column: 'google_id',
      definition: 'TEXT',
    );
    await _addColumnIfNotExists(
      db,
      table: 'users',
      column: 'auth_provider',
      definition: "TEXT NOT NULL DEFAULT 'local'",
    );
    await _addColumnIfNotExists(
      db,
      table: 'users',
      column: 'avatar_url',
      definition: 'TEXT',
    );
    await _addColumnIfNotExists(
      db,
      table: 'users',
      column: 'reset_code_expires_at',
      definition: 'TEXT',
    );
    await _addColumnIfNotExists(
      db,
      table: 'users',
      column: 'reset_code_verified',
      definition: 'INTEGER NOT NULL DEFAULT 0',
    );

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_users_google_id ON users(google_id)',
    );

    await db.execute(
      "UPDATE users SET role = 'user' WHERE role IS NULL OR TRIM(role) = ''",
    );
    await db.execute(
      "UPDATE users SET auth_provider = 'local' WHERE auth_provider IS NULL OR TRIM(auth_provider) = ''",
    );
    await db.execute(
      'UPDATE users SET reset_code_verified = 0 WHERE reset_code_verified IS NULL',
    );
  }

  Future<void> _ensureHospitalDoctorTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS hospitals (
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
      CREATE TABLE IF NOT EXISTS doctors (
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

    final hospitalCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM hospitals'),
        ) ??
        0;
    if (hospitalCount == 0) {
      for (final hospital in seedHospitals) {
        await db.insert('hospitals', hospital);
      }
    }

    final doctorCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM doctors'),
        ) ??
        0;
    if (doctorCount == 0) {
      for (final doctor in seedDoctors) {
        await db.insert('doctors', doctor);
      }
    }
  }

  Future<void> _seedDefaultUsers(Database db) async {
    final hashedDefaultPassword = _hash('123456');
    final hashedAdminPassword = _hash('admin123');

    await db.insert('users', {
      'name': 'User Test',
      'email': 'test@gmail.com',
      'password': hashedDefaultPassword,
      'role': 'user',
      'auth_provider': 'local',
      'phone': '0123456789',
      'address': 'Ha Noi, Viet Nam',
      'birth_date': '01/01/1990',
      'gender': 'Nam',
      'reset_code_verified': 0,
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    await db.insert('users', {
      'name': 'System Admin',
      'email': 'admin@gmail.com',
      'password': hashedAdminPassword,
      'role': 'admin',
      'auth_provider': 'local',
      'phone': '0900000000',
      'address': 'Local Admin',
      'reset_code_verified': 0,
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> _ensureAdminAccount(Database db) async {
    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: ['admin@gmail.com'],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      await db.update(
        'users',
        {'role': 'admin', 'auth_provider': 'local'},
        where: 'email = ?',
        whereArgs: ['admin@gmail.com'],
      );
      return;
    }

    await db.insert('users', {
      'name': 'System Admin',
      'email': 'admin@gmail.com',
      'password': _hash('admin123'),
      'role': 'admin',
      'auth_provider': 'local',
      'phone': '0900000000',
      'address': 'Local Admin',
      'reset_code_verified': 0,
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  String _hash(String value) => sha256.convert(utf8.encode(value)).toString();

  Future<bool> _tableExists(Database db, String tableName) async {
    final rows = await db.query(
      'sqlite_master',
      columns: ['name'],
      where: 'type = ? AND name = ?',
      whereArgs: ['table', tableName],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> _addColumnIfNotExists(
    Database db, {
    required String table,
    required String column,
    required String definition,
  }) async {
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    final exists = columns.any((c) => c['name'] == column);
    if (!exists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $definition');
    }
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

  /// Find a user by id. Returns `null` if not found.
  Future<User?> getUserById(int userId) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
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

  /// Find a user by Google id. Returns `null` if not found.
  Future<User?> getUserByGoogleId(String googleId) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'google_id = ?',
      whereArgs: [googleId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  /// Find a user by email and password hash.
  Future<User?> getUserByEmailAndPassword(
    String email,
    String passwordHash,
  ) async {
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

  /// Store reset OTP state.
  Future<int> updateResetCode(
    String email, {
    required String resetCode,
    required DateTime expiresAt,
  }) async {
    final db = await database;
    return db.update(
      'users',
      {
        'reset_code': resetCode,
        'reset_code_expires_at': expiresAt.toIso8601String(),
        'reset_code_verified': 0,
      },
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
    );
  }

  /// Mark OTP as verified.
  Future<int> markResetCodeVerified(String email) async {
    final db = await database;
    return db.update(
      'users',
      {'reset_code_verified': 1},
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
    );
  }

  /// Clear OTP state when send/verify/reset flow fails or ends.
  Future<int> clearResetPasswordState(String email) async {
    final db = await database;
    return db.update(
      'users',
      {
        'reset_code': null,
        'reset_code_expires_at': null,
        'reset_code_verified': 0,
      },
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
    );
  }

  /// Update the password for a user after OTP verification.
  Future<int> updatePassword(String email, String newPasswordHash) async {
    final db = await database;
    return db.update(
      'users',
      {
        'password': newPasswordHash,
        'reset_code': null,
        'reset_code_expires_at': null,
        'reset_code_verified': 0,
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

  /// Update name/avatar for Google sign-in account.
  Future<int> updateUserGoogleIdentity(
    int userId, {
    required String googleId,
    required String email,
    required String name,
    String? avatarUrl,
  }) async {
    final db = await database;
    return db.update(
      'users',
      {
        'google_id': googleId.trim(),
        'email': email.trim().toLowerCase(),
        'name': name.trim(),
        'avatar_url': avatarUrl,
        'auth_provider': 'google',
      },
      where: 'id = ?',
      whereArgs: [userId],
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
    if (_database == null) return;
    await _database!.close();
    _database = null;
  }

  final List<Map<String, dynamic>> seedDoctors = [
    {
      'id': 'd1',
      'name': 'BS. Nguyen Van An',
      'specialty': 'Tim mach',
      'hospitalName': 'Benh vien Quoc te DoLife',
      'rating': 4.9,
      'reviewCount': 120,
      'imageAssetPath': 'assets/images/doctor.png',
      'isFavorite': 1,
    },
    {
      'id': 'd2',
      'name': 'BS. Tran Thi Binh',
      'specialty': 'Nha khoa',
      'hospitalName': 'Benh vien Da khoa Hong Ngoc',
      'rating': 4.8,
      'reviewCount': 85,
      'imageAssetPath': 'assets/images/doctor.png',
      'isFavorite': 0,
    },
    {
      'id': 'd3',
      'name': 'BS. Le Hoang Nam',
      'specialty': 'Tim mach',
      'hospitalName': 'Benh vien Da khoa Quoc te Vinmec',
      'rating': 5.0,
      'reviewCount': 210,
      'imageAssetPath': 'assets/images/doctor.png',
      'isFavorite': 0,
    },
    {
      'id': 'd4',
      'name': 'BS. Pham Minh Tuan',
      'specialty': 'Da khoa',
      'hospitalName': 'Benh vien Viet Phap Ha Noi',
      'rating': 4.7,
      'reviewCount': 95,
      'imageAssetPath': 'assets/images/doctor.png',
      'isFavorite': 1,
    },
    {
      'id': 'd5',
      'name': 'BS. Hoang Thanh Truc',
      'specialty': 'Ho hap',
      'hospitalName': 'Benh vien Quoc te DoLife',
      'rating': 4.6,
      'reviewCount': 56,
      'imageAssetPath': 'assets/images/doctor.png',
      'isFavorite': 0,
    },
    {
      'id': 'd6',
      'name': 'BS. Ngo Duc Manh',
      'specialty': 'Nha khoa',
      'hospitalName': 'Benh vien Viet Phap Ha Noi',
      'rating': 4.9,
      'reviewCount': 142,
      'imageAssetPath': 'assets/images/doctor.png',
      'isFavorite': 0,
    },
    {
      'id': 'd7',
      'name': 'BS. Dang Thu Thao',
      'specialty': 'Da khoa',
      'hospitalName': 'Benh vien Da khoa Hong Ngoc',
      'rating': 4.8,
      'reviewCount': 78,
      'imageAssetPath': 'assets/images/doctor.png',
      'isFavorite': 0,
    },
    {
      'id': 'd8',
      'name': 'BS. Vu Hai Dang',
      'specialty': 'Ho hap',
      'hospitalName': 'Benh vien Da khoa Quoc te Vinmec',
      'rating': 4.5,
      'reviewCount': 34,
      'imageAssetPath': 'assets/images/doctor.png',
      'isFavorite': 1,
    },
  ];

  final List<Map<String, dynamic>> seedHospitals = [
    {
      'id': 'h1',
      'name': 'Benh vien Quoc te DoLife',
      'address': '108 Nguyen Hoang, Nam Tu Liem, Ha Noi',
      'rating': 4.8,
      'reviewCount': 1250,
      'distanceKm': 1.2,
      'etaMinutes': 8,
      'typeLabel': 'Da khoa Quoc te',
      'imageAssetPath': 'assets/images/hospital_demo.jpg',
      'isBookmarked': 0,
    },
    {
      'id': 'h2',
      'name': 'Benh vien Da khoa Hong Ngoc',
      'address': '55 Yen Ninh, Ba Dinh, Ha Noi',
      'rating': 4.7,
      'reviewCount': 3100,
      'distanceKm': 4.5,
      'etaMinutes': 20,
      'typeLabel': 'Da khoa Tu nhan',
      'imageAssetPath': 'assets/images/hospital_demo.jpg',
      'isBookmarked': 1,
    },
    {
      'id': 'h3',
      'name': 'Benh vien Da khoa Quoc te Vinmec',
      'address': '458 Minh Khai, Hai Ba Trung, Ha Noi',
      'rating': 4.9,
      'reviewCount': 5600,
      'distanceKm': 8.0,
      'etaMinutes': 35,
      'typeLabel': 'Dat chuan JCI',
      'imageAssetPath': 'assets/images/hospital_demo.jpg',
      'isBookmarked': 0,
    },
    {
      'id': 'h4',
      'name': 'Benh vien Viet Phap Ha Noi',
      'address': '01 Phuong Mai, Dong Da, Ha Noi',
      'rating': 4.6,
      'reviewCount': 1800,
      'distanceKm': 6.2,
      'etaMinutes': 25,
      'typeLabel': 'Tieu chuan Phap',
      'imageAssetPath': 'assets/images/hospital_demo.jpg',
      'isBookmarked': 0,
    },
  ];
}
