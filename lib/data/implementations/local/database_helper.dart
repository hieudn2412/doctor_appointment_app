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
      version: 1,
      onCreate: _onCreate,
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
}
