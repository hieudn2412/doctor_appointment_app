import 'package:flutter/material.dart';

class HomeBanner extends StatelessWidget {
  const HomeBanner({super.key});

  static const String bannerAssetPath = 'assets/images/home_banner.png';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 342,
        height: 163,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              bannerAssetPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2F8F83), Color(0xFF1B5E57)],
                    ),
                  ),
                );
              },
            ),
            Container(
              color: Colors.black.withValues(alpha: 0.18),
            ),
            const Positioned(
              left: 12,
              top: 24,
              child: Text(
                'Tìm bác sĩ\nchuyên khoa?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const Positioned(
              left: 12,
              top: 88,
              child: Text(
                'Chỉ cần vài thao tác bác sĩ\nhãy để DoLife chăm sóc.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
