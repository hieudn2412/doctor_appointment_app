import 'package:doctor_appointment_app/data/implementations/local/session_manager.dart';
import 'package:doctor_appointment_app/views/home/data/notification_store.dart';
import 'package:flutter/material.dart';
import 'package:doctor_appointment_app/views/home/widgets/home_banner.dart';
import 'package:doctor_appointment_app/views/home/widgets/recent_facilities_section.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({
    super.key,
    required this.onSeeAllTap,
    required this.onSearchTap,
    required this.onNotificationTap,
  });

  final VoidCallback onSeeAllTap;
  final VoidCallback onSearchTap;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final currentUserLocation =
        SessionManager.instance.currentUser?.address?.trim().isNotEmpty == true
        ? SessionManager.instance.currentUser!.address!
        : 'Không xác định';
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 0, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              onNotificationTap: onNotificationTap,
              location: currentUserLocation,
            ),
            const SizedBox(height: 14),
            _SearchBar(onTap: onSearchTap),
            const SizedBox(height: 14),
            const Padding(
              padding: EdgeInsets.only(right: 24),
              child: HomeBanner(),
            ),
            const SizedBox(height: 16),
            RecentFacilitiesSection(onSeeAllTap: onSeeAllTap),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onNotificationTap, required this.location});

  final VoidCallback onNotificationTap;
  final String location;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Location',
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 18, color: Color(0xFF1C2A3A)),
                  SizedBox(width: 7),
                  Text(
                    location,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, size: 16),
                ],
              ),
            ],
          ),
          InkWell(
            onTap: onNotificationTap,
            borderRadius: BorderRadius.circular(72),
            child: AnimatedBuilder(
              animation: NotificationStore.instance,
              builder: (context, _) {
                final unread = NotificationStore.instance.unreadCount;
                return SizedBox(
                  width: 34,
                  height: 34,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3F4F6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications,
                          size: 20,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      if (unread > 0)
                        Positioned(
                          top: 1,
                          right: 1,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.search, color: Color(0xFF9CA3AF)),
              SizedBox(width: 12),
              Text(
                'Tìm kiếm bác sĩ...',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
