import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF374151)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4B5563),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '1 tin',
                      style: TextStyle(
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
              child: ListView(
                padding: const EdgeInsets.only(bottom: 12),
                children: const [
                  _SectionHeader(title: 'HÔM NAY'),
                  _NotificationTile(
                    type: _NotificationType.success,
                    title: 'Đặt lịch thành công',
                    timeText: '1h',
                    message: 'Bạn đã đặt lịch hẹn thành công với bác sĩ Nguyễn Văn A',
                  ),
                  _NotificationTile(
                    type: _NotificationType.danger,
                    title: 'Đã hủy lịch hẹn',
                    timeText: '2h',
                    message: 'Bạn đã hủy lịch hẹn thành công với bác sĩ Lê Thị B',
                    highlighted: true,
                  ),
                  _NotificationTile(
                    type: _NotificationType.neutral,
                    title: 'Đã thay đổi lịch hẹn',
                    timeText: '8h',
                    message: 'Bạn đã thay đổi lịch hẹn thành công với bác sĩ Phùng Thanh D',
                  ),
                  SizedBox(height: 16),
                  _SectionHeader(title: 'HÔM QUA'),
                  _NotificationTile(
                    type: _NotificationType.success,
                    title: 'Đặt lịch thành công',
                    timeText: '1d',
                    message: 'Bạn đã đặt lịch hẹn thành công với bác sĩ Nguyễn Văn C',
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

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
          const Text(
            'Đánh dấu đã đọc',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C2A3A),
            ),
          ),
        ],
      ),
    );
  }
}

enum _NotificationType { success, danger, neutral }

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.type,
    required this.title,
    required this.timeText,
    required this.message,
    this.highlighted = false,
  });

  final _NotificationType type;
  final String title;
  final String timeText;
  final String message;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final bgColor = switch (type) {
      _NotificationType.success => const Color(0xFFDEF7E5),
      _NotificationType.danger => const Color(0xFFFDE8E8),
      _NotificationType.neutral => const Color(0xFFF3F4F6),
    };

    final iconColor = switch (type) {
      _NotificationType.success => const Color(0xFF014737),
      _NotificationType.danger => const Color(0xFF771D1D),
      _NotificationType.neutral => const Color(0xFF1C2A3A),
    };

    final icon = switch (type) {
      _NotificationType.success => Icons.event_available_outlined,
      _NotificationType.danger => Icons.event_busy_outlined,
      _NotificationType.neutral => Icons.event_note_outlined,
    };

    return Container(
      color: highlighted ? const Color(0xFFF9FAFB) : Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
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
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C2A3A),
                        ),
                      ),
                    ),
                    Text(
                      timeText,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
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
    );
  }
}
