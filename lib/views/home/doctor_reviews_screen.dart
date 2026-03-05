import 'package:flutter/material.dart';

class DoctorReviewsScreen extends StatelessWidget {
  const DoctorReviewsScreen({
    super.key,
    required this.doctorName,
  });

  final String doctorName;

  @override
  Widget build(BuildContext context) {
    const reviews = <String>[
      'Bác sĩ A là một chuyên gia thực thụ, luôn thật sự quan tâm đến bệnh nhân.',
      'Bác sĩ A là một chuyên gia thực thụ, luôn thật sự quan tâm đến bệnh nhân.',
      'Bác sĩ A là một chuyên gia thực thụ, luôn thật sự quan tâm đến bệnh nhân.',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF374151)),
                  ),
                  const Expanded(
                    child: Text(
                      'Nhận xét',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2A37),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: reviews.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _ReviewItem(
                      customerName: 'Phạm Thị D',
                      reviewText: reviews[index],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  const _ReviewItem({
    required this.customerName,
    required this.reviewText,
  });

  final String customerName;
  final String reviewText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(41),
              child: SizedBox(
                width: 57,
                height: 57,
                child: Image.asset(
                  'assets/images/customer.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const ColoredBox(
                    color: Color(0xFFE5E7EB),
                    child: Icon(Icons.person, size: 28, color: Color(0xFF6B7280)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phạm Thị D',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151),
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Text('5.0', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                    SizedBox(width: 4),
                    Icon(Icons.star, size: 12, color: Color(0xFFFEB052)),
                    Icon(Icons.star, size: 12, color: Color(0xFFFEB052)),
                    Icon(Icons.star, size: 12, color: Color(0xFFFEB052)),
                    Icon(Icons.star, size: 12, color: Color(0xFFFEB052)),
                    Icon(Icons.star, size: 12, color: Color(0xFFFEB052)),
                  ],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          reviewText,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
