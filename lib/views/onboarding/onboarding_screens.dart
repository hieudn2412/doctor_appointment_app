import 'package:doctor_appointment_app/views/user/signin_screen.dart';
import 'package:flutter/material.dart';

class OnboardingFirstScreen extends StatelessWidget {
  const OnboardingFirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingTemplate(
      step: 0,
      title: 'Đặt lịch hẹn trực tuyến',
      description: 'Người dùng có thể tìm và đặt lịch với bác sĩ theo thời gian phù hợp.',
      onNext: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const OnboardingSecondScreen(),
          ),
        );
      },
      onSkip: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const SignInScreen()),
          (route) => false,
        );
      },
    );
  }
}

class OnboardingSecondScreen extends StatelessWidget {
  const OnboardingSecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingTemplate(
      step: 1,
      title: 'Kết nối với chuyên gia',
      description: 'Trò chuyện trực tiếp với bác sĩ, chuyên khoa, cũng như nhận tư vấn từ xa.',
      onNext: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const OnboardingThirdScreen(),
          ),
        );
      },
      onSkip: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const SignInScreen()),
          (route) => false,
        );
      },
    );
  }
}

class OnboardingThirdScreen extends StatelessWidget {
  const OnboardingThirdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingTemplate(
      step: 2,
      title: 'Tiết kiệm thời gian',
      description: 'Quản lý lịch hẹn, hồ sơ, thông tin chỉ trên một ứng dụng.',
      actionText: 'Bắt đầu',
      onNext: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const SignInScreen()),
          (route) => false,
        );
      },
      onSkip: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const SignInScreen()),
          (route) => false,
        );
      },
    );
  }
}

class OnboardingTemplate extends StatelessWidget {
  const OnboardingTemplate({
    super.key,
    required this.step,
    required this.title,
    required this.description,
    required this.onNext,
    required this.onSkip,
    this.actionText = 'Tiếp',
  });

  final int step;
  final String title;
  final String description;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final String actionText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _TopImageSection(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 39.5),
                child: Column(
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 311,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: onNext,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFF1C2A3A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(61),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                        ),
                        child: Text(
                          actionText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  _Indicator(step: step),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: onSkip,
                    child: const Text(
                      'Bỏ qua',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopImageSection extends StatelessWidget {
  const _TopImageSection();

  static const String _onboardingAsset = 'assets/images/onboarding.png';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 532,
      width: double.infinity,
      child: Image.asset(
        _onboardingAsset,
        width: double.infinity,
        height: 532,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFFE5E7EB),
            alignment: Alignment.center,
            child: const Icon(
              Icons.image_not_supported_outlined,
              size: 54,
              color: Color(0xFF9CA3AF),
            ),
          );
        },
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index == step;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 30 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF26232F) : const Color(0xFF9B9B9B),
            borderRadius: BorderRadius.circular(40),
          ),
        );
      }),
    );
  }
}
