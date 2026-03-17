import 'package:doctor_appointment_app/implementations/repository/hospital_repository.dart';
import 'package:doctor_appointment_app/views/home/models/hospital_item.dart';
import 'package:doctor_appointment_app/views/home/widgets/hospital_card.dart';
import 'package:flutter/material.dart';

class RecentFacilitiesSection extends StatelessWidget {
  const RecentFacilitiesSection({
    super.key,
    required this.onSeeAllTap,
  });

  final VoidCallback onSeeAllTap;

  @override
  Widget build(BuildContext context) {
    // 1. Khởi tạo repository
    final hospitalRepo = HospitalRepository();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cơ sở y tế gần đây',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C2A3A),
                ),
              ),
              InkWell(
                onTap: onSeeAllTap,
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 2. Sử dụng FutureBuilder để lấy dữ liệu từ DB
        FutureBuilder<List<HospitalItem>>(
          future: hospitalRepo.getAllHospitals(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return Center(child: Text('Lỗi: ${snapshot.error}'));
            }

            final hospitals = snapshot.data ?? [];

            if (hospitals.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('Không có cơ sở y tế nào')),
              );
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none, // Để đổ bóng không bị cắt
              child: Row(
                children: List.generate(hospitals.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == hospitals.length - 1 ? 24 : 16,
                    ),
                    child: HospitalCard(item: hospitals[index]),
                  );
                }),
              ),
            );
          },
        ),
      ],
    );
  }
}