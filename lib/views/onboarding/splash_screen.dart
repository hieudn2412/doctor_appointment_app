import 'dart:async';

import 'package:doctor_appointment_app/data/implementations/local/session_manager.dart';
import 'package:doctor_appointment_app/views/appointment/data/appointment_booking_store.dart';
import 'package:doctor_appointment_app/views/admin/admin_home_screen.dart';
import 'package:doctor_appointment_app/views/home/home_screen.dart';
import 'package:doctor_appointment_app/views/onboarding/onboarding_screens.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const String logoAsset = 'assets/images/logo.png';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), _checkSessionAndNavigate);
  }

  /// Kiểm tra session: nếu đã đăng nhập → vào HomeScreen, ngược lại → Onboarding.
  Future<void> _checkSessionAndNavigate() async {
    if (!mounted) return;

    final hasSession = await SessionManager.instance.restoreSession();

    if (!mounted) return;

    if (hasSession) {
      await AppointmentBookingStore.instance.refreshForCurrentUser();
      if (!mounted) return;
      final isAdmin = SessionManager.instance.currentUser?.role == 'admin';
      Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
        builder: (_) => isAdmin ? const AdminHomeScreen() : const HomeScreen(),
      ));
    } else {
      // Chưa đăng nhập → màn hình onboarding
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const OnboardingFirstScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7FAFC), Color(0xFFEFF6FF)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -70,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE).withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -90,
              left: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  color: const Color(0xFFCCFBF1).withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1C2A3A), Color(0xFF0F172A)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1C2A3A).withValues(alpha: 0.12),
                          blurRadius: 30,
                          offset: const Offset(0, 14),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFF334155),
                      ),
                    ),
                    child: Image.asset(
                      SplashScreen.logoAsset,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.local_hospital_rounded,
                          color: Color(0xFF1C2A3A),
                          size: 72,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'AnKhang',
                    style: TextStyle(
                      color: Color(0xFF1C2A3A),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Doctor Appointment',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
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
