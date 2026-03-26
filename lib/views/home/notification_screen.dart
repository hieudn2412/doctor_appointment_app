import 'package:doctor_appointment_app/views/home/data/notification_store.dart';
import 'package:doctor_appointment_app/views/home/models/user_notification.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationStore _store = NotificationStore.instance;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
    _refreshNotifications();
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _refreshNotifications() async {
    try {
      await _store.refreshForCurrentUser();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải thông báo: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  Future<void> _markSectionAsRead(List<UserNotification> items) async {
    final unreadIds = items
        .where((item) => !item.isRead)
        .map((e) => e.id)
        .toList();
    if (unreadIds.isEmpty) return;

    try {
      await _store.markItemsAsRead(unreadIds);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể cập nhật thông báo: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  Future<void> _markOneAsRead(UserNotification item) async {
    if (item.isRead) return;

    try {
      await _store.markAsRead(item.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể cập nhật thông báo: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allItems = _store.items;
    final todayItems = _store.todayItems;
    final yesterdayItems = _store.yesterdayItems;
    final olderItems = _store.olderItems;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Thông báo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  Container(
                    height: 25,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4B5563),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${allItems.length} tin',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _buildBody(
                allItems: allItems,
                todayItems: todayItems,
                yesterdayItems: yesterdayItems,
                olderItems: olderItems,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody({
    required List<UserNotification> allItems,
    required List<UserNotification> todayItems,
    required List<UserNotification> yesterdayItems,
    required List<UserNotification> olderItems,
  }) {
    if (!_store.isLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (allItems.isEmpty) {
      return const Center(
        child: Text(
          'Bạn chưa có thông báo nào',
          style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshNotifications,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 12),
        children: [
          if (todayItems.isNotEmpty) ...[
            _SectionHeader(
              title: 'HÔM NAY',
              hasUnread: todayItems.any((item) => !item.isRead),
              onMarkReadTap: () => _markSectionAsRead(todayItems),
            ),
            ...todayItems.map(
              (item) => _NotificationTile(
                item: item,
                timeText: _relativeTimeText(item.createdAt),
                onTap: () => _markOneAsRead(item),
              ),
            ),
          ],
          if (yesterdayItems.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionHeader(
              title: 'HÔM QUA',
              hasUnread: yesterdayItems.any((item) => !item.isRead),
              onMarkReadTap: () => _markSectionAsRead(yesterdayItems),
            ),
            ...yesterdayItems.map(
              (item) => _NotificationTile(
                item: item,
                timeText: _relativeTimeText(item.createdAt),
                onTap: () => _markOneAsRead(item),
              ),
            ),
          ],
          if (olderItems.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionHeader(
              title: 'CŨ HƠN',
              hasUnread: olderItems.any((item) => !item.isRead),
              onMarkReadTap: () => _markSectionAsRead(olderItems),
            ),
            ...olderItems.map(
              (item) => _NotificationTile(
                item: item,
                timeText: _relativeTimeText(item.createdAt),
                onTap: () => _markOneAsRead(item),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _relativeTimeText(DateTime createdAt) {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return 'vừa xong';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.hasUnread,
    required this.onMarkReadTap,
  });

  final String title;
  final bool hasUnread;
  final VoidCallback onMarkReadTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
            ),
          ),
          InkWell(
            onTap: hasUnread ? onMarkReadTap : null,
            child: Text(
              hasUnread ? 'Đánh dấu đã đọc' : 'Đã đọc',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: hasUnread
                    ? const Color(0xFF1C2A3A)
                    : const Color(0xFF9CA3AF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.timeText,
    required this.onTap,
  });

  final UserNotification item;
  final String timeText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = switch (item.type) {
      UserNotificationType.success => const Color(0xFFDEF7E5),
      UserNotificationType.danger => const Color(0xFFFDE8E8),
      UserNotificationType.neutral => const Color(0xFFF3F4F6),
    };

    final iconColor = switch (item.type) {
      UserNotificationType.success => const Color(0xFF014737),
      UserNotificationType.danger => const Color(0xFF771D1D),
      UserNotificationType.neutral => const Color(0xFF1C2A3A),
    };

    final icon = switch (item.type) {
      UserNotificationType.success => Icons.event_available_outlined,
      UserNotificationType.danger => Icons.event_busy_outlined,
      UserNotificationType.neutral => Icons.event_note_outlined,
    };

    return InkWell(
      onTap: onTap,
      child: Container(
        color: item.isRead ? Colors.white : const Color(0xFFF9FAFB),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, size: 24, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1C2A3A),
                          ),
                        ),
                      ),
                      Text(
                        timeText,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
