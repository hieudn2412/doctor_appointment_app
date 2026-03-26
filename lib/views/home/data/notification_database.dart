import 'package:doctor_appointment_app/data/implementations/local/database_helper.dart';
import 'package:doctor_appointment_app/views/home/models/user_notification.dart';
import 'package:sqflite/sqflite.dart';

class NotificationDatabase {
  NotificationDatabase._();

  static final NotificationDatabase instance = NotificationDatabase._();
  static const String _tableName = 'notifications';

  Future<void> _createTableIfNeeded() async {
    final db = await DatabaseHelper.instance.database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id TEXT PRIMARY KEY,
        user_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        created_at_ms INTEGER NOT NULL,
        is_read INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_notifications_user_created '
      'ON $_tableName(user_id, created_at_ms DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_notifications_user_read '
      'ON $_tableName(user_id, is_read)',
    );
  }

  Future<List<UserNotification>> getNotificationsForUser(int userId) async {
    await _createTableIfNeeded();
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      _tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at_ms DESC',
    );
    return rows.map(UserNotification.fromMap).toList();
  }

  Future<void> insertNotification(UserNotification notification) async {
    await _createTableIfNeeded();
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      _tableName,
      notification.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> markNotificationRead({
    required int userId,
    required String notificationId,
  }) async {
    await _createTableIfNeeded();
    final db = await DatabaseHelper.instance.database;
    return db.update(
      _tableName,
      {'is_read': 1},
      where: 'id = ? AND user_id = ?',
      whereArgs: [notificationId, userId],
    );
  }

  Future<int> markNotificationsRead({
    required int userId,
    required List<String> notificationIds,
  }) async {
    await _createTableIfNeeded();
    if (notificationIds.isEmpty) return 0;

    final db = await DatabaseHelper.instance.database;
    final placeholders = List.filled(notificationIds.length, '?').join(', ');
    return db.rawUpdate(
      'UPDATE $_tableName SET is_read = 1 '
      'WHERE user_id = ? AND id IN ($placeholders)',
      <Object>[userId, ...notificationIds],
    );
  }

  Future<int> markAllReadForUser(int userId) async {
    await _createTableIfNeeded();
    final db = await DatabaseHelper.instance.database;
    return db.update(
      _tableName,
      {'is_read': 1},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
