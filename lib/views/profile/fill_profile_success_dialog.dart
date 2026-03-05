import 'dart:math' as math;

import 'package:flutter/material.dart';

class FillProfileSuccessDialog extends StatefulWidget {
  const FillProfileSuccessDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const FillProfileSuccessDialog(),
    );
  }

  @override
  State<FillProfileSuccessDialog> createState() => _FillProfileSuccessDialogState();
}

class _FillProfileSuccessDialogState extends State<FillProfileSuccessDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 26),
      child: Container(
        width: 337,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(48),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 131,
              height: 131,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFA4CFC3),
              ),
              child: const Icon(Icons.check_rounded, size: 66, color: Color(0xFF1F2A37)),
            ),
            const SizedBox(height: 32),
            const Text(
              'Hoàn tất!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                height: 1.5,
                color: Color(0xFF1C2A3A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tài khoản của bạn đã hoàn tất đăng ký. Bạn sẽ được chuyển hướng đến Trang chủ trong vài giây...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.5,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 57,
              height: 57,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _SpinnerPainter(_controller.value),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  _SpinnerPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final paint = Paint()
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 12; i++) {
      final t = (i / 12.0 + progress) % 1.0;
      final opacity = 0.15 + 0.85 * t;
      paint.color = const Color(0xFF1F2A37).withValues(alpha: opacity);

      final angle = (i / 12) * math.pi * 2;
      final start = Offset(
        center.dx + (radius - 10) * math.cos(angle),
        center.dy + (radius - 10) * math.sin(angle),
      );
      final end = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpinnerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
