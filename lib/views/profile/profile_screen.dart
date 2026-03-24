import 'package:doctor_appointment_app/views/appointment/manage_appointments_screen.dart';
import 'package:doctor_appointment_app/views/home/doctor_list_screen.dart';
import 'package:doctor_appointment_app/views/home/widgets/home_bottom_menu_bar.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              'Hồ sơ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 14),
                child: Column(
                  children: [
                    _ProfileHeader(),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          _ProfileMenuItem(
                            icon: Icons.edit_outlined,
                            title: 'Chỉnh sửa hồ sơ',
                            onTap: () {},
                          ),
                          const Divider(color: Color(0xFFE5E7EB), height: 1),
                          _ProfileMenuItem(
                            icon: Icons.notifications_none,
                            title: 'Thông báo',
                            onTap: () {},
                          ),
                          const Divider(color: Color(0xFFE5E7EB), height: 1),
                          _ProfileMenuItem(
                            icon: Icons.settings_outlined,
                            title: 'Cài đặt',
                            onTap: () {},
                          ),
                          const Divider(color: Color(0xFFE5E7EB), height: 1),
                          _ProfileMenuItem(
                            icon: Icons.help_outline,
                            title: 'Trợ giúp & Hỗ trợ',
                            onTap: () {},
                          ),
                          const Divider(color: Color(0xFFE5E7EB), height: 1),
                          _ProfileMenuItem(
                            icon: Icons.security_outlined,
                            title: 'Điều khoản và điều kiện',
                            onTap: () {},
                          ),
                          const Divider(color: Color(0xFFE5E7EB), height: 1),
                          _ProfileMenuItem(
                            icon: Icons.logout,
                            title: 'Đăng xuất',
                            showArrow: false,
                            onTap: () => _showLogoutModal(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            HomeBottomMenuBar(
              selectedTab: HomeMenuTab.profile,
              onHomeTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
              onSearchTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const DoctorListScreen(),
                  ),
                );
              },
              onCalendarTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ManageAppointmentsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x66000000),
      builder: (context) {
        return Container(
          height: 199,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(34),
              topRight: Radius.circular(34),
              bottomLeft: Radius.circular(54),
              bottomRight: Radius.circular(54),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'Đăng xuất',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C2A3A),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: 16),
              const Text(
                'Bạn muốn đăng xuất?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ModalActionButton(
                      text: 'Hủy',
                      isPrimary: false,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ModalActionButton(
                      text: 'Đăng xuất',
                      isPrimary: true,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 202,
              height: 202,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/profile.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const ColoredBox(
                    color: Color(0xFFE5E7EB),
                    child: Icon(Icons.person, size: 84, color: Color(0xFF6B7280)),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: 14,
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFF1C2A3A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, size: 18, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Hà Lê Iset',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2A37),
          ),
        ),
        const Text(
          '+123 856479683',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.showArrow = true,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 24, color: const Color(0xFF1C2A3A)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
            if (showArrow) const Icon(Icons.chevron_right, size: 18, color: Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }
}

class _ModalActionButton extends StatelessWidget {
  const _ModalActionButton({
    required this.text,
    required this.isPrimary,
    required this.onTap,
  });

  final String text;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        height: 41,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF1C2A3A) : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isPrimary ? Colors.white : const Color(0xFF1C2A3A),
          ),
        ),
      ),
    );
  }
}
