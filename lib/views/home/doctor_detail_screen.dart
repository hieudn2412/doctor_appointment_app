import 'package:doctor_appointment_app/views/appointment/appointment_screen.dart';
import 'package:doctor_appointment_app/views/home/doctor_reviews_screen.dart';
import 'package:doctor_appointment_app/views/home/models/doctor_item.dart';
import 'package:flutter/material.dart';

class DoctorDetailScreen extends StatelessWidget {
  const DoctorDetailScreen({
    super.key,
    required this.doctor,
  });

  final DoctorItem doctor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back, color: Color(0xFF374151)),
                          ),
                          const Expanded(
                            child: Text(
                              'Thông tin bác sĩ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                      child: Container(
                        height: 133,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF3F4F6), width: 0.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A000000),
                              offset: Offset(0, 4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: 109,
                                height: 109,
                                child: doctor.imageAssetPath == null
                                    ? const ColoredBox(
                                        color: Color(0xFFE5E7EB),
                                        child: Icon(Icons.person, size: 36),
                                      )
                                    : Image.asset(
                                        doctor.imageAssetPath!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const ColoredBox(
                                          color: Color(0xFFE5E7EB),
                                          child: Icon(Icons.person, size: 36),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doctor.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1F2A37),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                                  const SizedBox(height: 8),
                                  Text(
                                    doctor.specialty,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF4B5563),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF4B5563)),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          doctor.hospitalName,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF4B5563),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _MetricItem(
                            icon: Icons.groups_2,
                            value: '2,000+',
                            label: 'bệnh nhân',
                          ),
                          _MetricItem(
                            icon: Icons.verified,
                            value: '10+',
                            label: 'kinh nghiệm',
                          ),
                          _MetricItem(
                            icon: Icons.star,
                            value: '5',
                            label: 'đánh giá',
                          ),
                          _MetricItem(
                            icon: Icons.message,
                            value: '1,872',
                            label: 'nhận xét',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Giới thiệu',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2A37),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                      child: Text(
                        '${doctor.name}, một bác sĩ tim mạch tận tâm, làm việc cho ${doctor.hospitalName}, Nam Từ Liêm, Hà Nội.',
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Thời gian làm việc',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2A37),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 8, 24, 0),
                      child: Text(
                        'Thứ 2-Thứ 6, 08.00 AM-18.00 PM',
                        style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Nhận xét',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2A37),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => DoctorReviewsScreen(
                                    doctorName: doctor.name,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'Xem tất cả',
                              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
                      child: _ReviewTile(),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 96,
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFF7F7F7))),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1C2A3A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => AppointmentScreen(doctor: doctor),
                    ),
                  );
                },
                child: const Text(
                  'Book Appointment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: Color(0xFFF3F4F6),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 28, color: const Color(0xFF1C2A3A)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4B5563),
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile();

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
                SizedBox(height: 4),
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
        const SizedBox(height: 8),
        const Text(
          'Bác sĩ A rất có chuyên gia thật sự, luôn thể hiện sự quan tâm đến bệnh nhân. Tôi rất khuyến nghị.',
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
