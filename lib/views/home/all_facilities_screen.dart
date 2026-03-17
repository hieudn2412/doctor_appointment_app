import 'package:doctor_appointment_app/implementations/repository/hospital_repository.dart';
import 'package:doctor_appointment_app/views/appointment/manage_appointments_screen.dart';
import 'package:doctor_appointment_app/views/home/data/hospital_mock_data.dart';
import 'package:doctor_appointment_app/views/home/models/hospital_item.dart';
import 'package:doctor_appointment_app/views/home/widgets/home_bottom_menu_bar.dart';
import 'package:doctor_appointment_app/views/home/widgets/hospital_card.dart';
import 'package:doctor_appointment_app/views/profile/profile_screen.dart';
import 'package:flutter/material.dart';

class AllFacilitiesScreen extends StatelessWidget {
  const AllFacilitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hospitalRepo = HospitalRepository();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
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
                                'Quận Nam Từ Liêm, Hà Nội',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF374151),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Stack(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE5E7EB),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications,
                              size: 20,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF0000),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF4B5563)),
                      ),
                      const Expanded(
                        child: Text(
                          'Cơ sở y tế gần đây',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1C2A3A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<HospitalItem>>(
                future: hospitalRepo.getAllHospitals(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Không có dữ liệu"));
                  }

                  final hospitals = snapshot.data!;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: GridView.builder(
                      itemCount: hospitals.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.68,
                      ),
                      itemBuilder: (context, index) {
                        return HospitalCard(
                          item: hospitals[index],
                          showRating: false,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            HomeBottomMenuBar(
              selectedTab: HomeMenuTab.home,
              onCalendarTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ManageAppointmentsScreen(),
                  ),
                );
              },
              onProfileTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
