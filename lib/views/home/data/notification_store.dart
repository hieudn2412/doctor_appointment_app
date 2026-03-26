import 'package:doctor_appointment_app/data/implementations/local/session_manager.dart';
import 'package:doctor_appointment_app/views/home/data/notification_database.dart';
import 'package:doctor_appointment_app/views/home/models/user_notification.dart';
import 'package:flutter/material.dart';

class NotificationStore extends ChangeNotifier {
  NotificationStore._() {
    _loadingFuture = _loadForCurrentUser();
  }

  static final NotificationStore instance = NotificationStore._();

  final NotificationDatabase _database = NotificationDatabase.instance;
  final List<UserNotification> _items = <UserNotification>[];
  late Future<void> _loadingFuture;

  int? _loadedUserId;
  bool _isLoaded = false;
  int _idCounter = 0;

  bool get isLoaded => _isLoaded;
  List<UserNotification> get items => List.unmodifiable(_items);
  int get unreadCount => _items.where((item) => !item.isRead).length;

  List<UserNotification> get todayItems => _itemsForDate(DateTime.now());

  List<UserNotification> get yesterdayItems =>
      _itemsForDate(DateTime.now().subtract(const Duration(days: 1)));

  List<UserNotification> get olderItems {
    final today = DateUtils.dateOnly(DateTime.now());
    final yesterday = DateUtils.dateOnly(
      DateTime.now().subtract(const Duration(days: 1)),
    );
    return List.unmodifiable(
      _items.where((item) {
        final d = DateUtils.dateOnly(item.createdAt);
        return d != today && d != yesterday;
      }),
    );
  }

  Future<void> refreshForCurrentUser() async {
    _loadingFuture = _loadForCurrentUser();
    await _loadingFuture;
  }

  void clearCache() {
    _items.clear();
    _loadedUserId = null;
    _isLoaded = false;
    _idCounter = 0;
    notifyListeners();
  }

  Future<void> addNotification({
    required UserNotificationType type,
    required String title,
    required String message,
  }) async {
    await _ensureReadyForCurrentUser();
    if (_loadedUserId == null) return;

    _idCounter += 1;
    final notification = UserNotification(
      id: 'noti_${DateTime.now().millisecondsSinceEpoch}_$_idCounter',
      userId: _loadedUserId!,
      type: type,
      title: title.trim(),
      message: message.trim(),
      createdAt: DateTime.now(),
      isRead: false,
    );

    _items.insert(0, notification);
    notifyListeners();

    try {
      await _database.insertNotification(notification);
    } catch (e) {
      _items.removeWhere((item) => item.id == notification.id);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    await _ensureReadyForCurrentUser();
    if (_loadedUserId == null) return;

    final index = _items.indexWhere((item) => item.id == notificationId);
    if (index < 0 || _items[index].isRead) return;

    final previous = _items[index];
    _items[index] = previous.copyWith(isRead: true);
    notifyListeners();

    try {
      final updated = await _database.markNotificationRead(
        userId: _loadedUserId!,
        notificationId: notificationId,
      );
      if (updated <= 0) {
        throw Exception('Không thể cập nhật trạng thái thông báo');
      }
    } catch (e) {
      _items[index] = previous;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> markItemsAsRead(List<String> notificationIds) async {
    await _ensureReadyForCurrentUser();
    if (_loadedUserId == null || notificationIds.isEmpty) return;

    final targetSet = notificationIds.toSet();
    final previous = List<UserNotification>.from(_items);
    var changed = false;

    for (var i = 0; i < _items.length; i++) {
      final item = _items[i];
      if (targetSet.contains(item.id) && !item.isRead) {
        _items[i] = item.copyWith(isRead: true);
        changed = true;
      }
    }

    if (!changed) return;
    notifyListeners();

    try {
      await _database.markNotificationsRead(
        userId: _loadedUserId!,
        notificationIds: notificationIds,
      );
    } catch (e) {
      _items
        ..clear()
        ..addAll(previous);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    await _ensureReadyForCurrentUser();
    if (_loadedUserId == null) return;

    if (_items.every((item) => item.isRead)) return;
    final previous = List<UserNotification>.from(_items);
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isRead: true);
    }
    notifyListeners();

    try {
      await _database.markAllReadForUser(_loadedUserId!);
    } catch (e) {
      _items
        ..clear()
        ..addAll(previous);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _ensureReadyForCurrentUser() async {
    await _loadingFuture;

    final currentUserId = SessionManager.instance.currentUser?.id;
    if (currentUserId != _loadedUserId) {
      _loadingFuture = _loadForCurrentUser();
      await _loadingFuture;
    }
  }

  Future<void> _loadForCurrentUser() async {
    final userId = SessionManager.instance.currentUser?.id;

    if (userId == null) {
      _items.clear();
      _loadedUserId = null;
      _isLoaded = true;
      _idCounter = 0;
      notifyListeners();
      return;
    }

    try {
      final result = await _database
          .getNotificationsForUser(userId)
          .timeout(const Duration(seconds: 5));
      _items
        ..clear()
        ..addAll(result);
      _loadedUserId = userId;
      _idCounter = _maxCounterFromIds(_items);
    } catch (_) {
      _items.clear();
      _loadedUserId = userId;
      _idCounter = 0;
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  List<UserNotification> _itemsForDate(DateTime dateTime) {
    final target = DateUtils.dateOnly(dateTime);
    return List.unmodifiable(
      _items.where((item) => DateUtils.dateOnly(item.createdAt) == target),
    );
  }

  int _maxCounterFromIds(List<UserNotification> items) {
    var max = 0;
    for (final item in items) {
      final segments = item.id.split('_');
      if (segments.isEmpty) continue;
      final parsed = int.tryParse(segments.last);
      if (parsed != null && parsed > max) {
        max = parsed;
      }
    }
    return max;
  }
}
