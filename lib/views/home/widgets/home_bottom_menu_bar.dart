import 'package:flutter/material.dart';

enum HomeMenuTab { home, search, calendar, profile }

class HomeBottomMenuBar extends StatelessWidget {
  const HomeBottomMenuBar({
    super.key,
    this.selectedTab = HomeMenuTab.home,
    this.onHomeTap,
    this.onSearchTap,
    this.onCalendarTap,
    this.onProfileTap,
  });

  final HomeMenuTab selectedTab;
  final VoidCallback? onHomeTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onCalendarTap;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF7F7F7))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _MenuIcon(
            icon: Icons.home,
            active: selectedTab == HomeMenuTab.home,
            onTap: onHomeTap,
          ),
          _MenuIcon(
            icon: Icons.search_outlined,
            active: selectedTab == HomeMenuTab.search,
            onTap: onSearchTap,
          ),
          _MenuIcon(
            icon: Icons.calendar_month_outlined,
            active: selectedTab == HomeMenuTab.calendar,
            onTap: onCalendarTap,
          ),
          _MenuIcon(
            icon: Icons.person_outline,
            active: selectedTab == HomeMenuTab.profile,
            onTap: onProfileTap,
          ),
        ],
      ),
    );
  }
}

class _MenuIcon extends StatelessWidget {
  const _MenuIcon({
    required this.icon,
    this.active = false,
    this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(38),
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: active ? const Color(0xFFF3F4F6) : Colors.transparent,
          borderRadius: BorderRadius.circular(38),
        ),
        child: Icon(
          icon,
          color: active ? const Color(0xFF4B5563) : const Color(0xFF9CA3AF),
        ),
      ),
    );
  }
}
