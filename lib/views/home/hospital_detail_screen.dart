import 'package:doctor_appointment_app/views/home/doctor_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:doctor_appointment_app/views/home/models/hospital_item.dart';
import 'package:doctor_appointment_app/views/home/models/specialty.dart';
import 'package:doctor_appointment_app/views/appointment/manage_appointments_screen.dart';
import 'package:doctor_appointment_app/views/profile/profile_screen.dart';
import 'package:doctor_appointment_app/views/home/widgets/home_bottom_menu_bar.dart';

class HospitalDetailScreen extends StatefulWidget {
  final HospitalItem hospital;

  const HospitalDetailScreen({
    super.key,
    required this.hospital,
  });

  @override
  State<HospitalDetailScreen> createState() => _HospitalDetailScreenState();
}

class _HospitalDetailScreenState extends State<HospitalDetailScreen> {
  // Biến trạng thái để kiểm soát việc hiển thị tất cả chuyên khoa
  bool _showAllSpecialties = false;

  // Danh sách chuyên khoa đầy đủ
  final List<Specialty> allSpecialties = [
    Specialty(name: 'Nha khoa', icon: Icons.health_and_safety, color: const Color(0xFFE59A9A)),
    Specialty(name: 'Tim mạch', icon: Icons.favorite, color: const Color(0xFF9AC6A7)),
    Specialty(name: 'Hô hấp', icon: Icons.air, color: const Color(0xFFF4B183)),
    Specialty(name: 'Tổng thể', icon: Icons.medical_information, color: const Color(0xFFB1A7D1)),
    // Thêm các chuyên khoa khác để test tính năng "Xem tất cả"
    Specialty(name: 'Nhi khoa', icon: Icons.child_care, color: const Color(0xFF81D4FA)),
    Specialty(name: 'Thần kinh', icon: Icons.psychology, color: const Color(0xFFCE93D8)),
    Specialty(name: 'Tai mũi họng', icon: Icons.hearing, color: const Color(0xFFFFF59D)),
    Specialty(name: 'Nhãn khoa', icon: Icons.visibility, color: const Color(0xFFA5D6A7)),
  ];

  @override
  Widget build(BuildContext context) {
    // Nếu chưa bấm "Xem tất cả", chỉ lấy 4 mục đầu tiên
    final displaySpecialties = _showAllSpecialties
        ? allSpecialties
        : allSpecialties.take(4).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4B5563)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thông tin bệnh viện',
          style: TextStyle(color: Color(0xFF1C2A3A), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Hình ảnh bệnh viện
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: widget.hospital.imageAssetPath != null
                            ? Image.asset(
                          widget.hospital.imageAssetPath!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                            : Container(height: 200, color: Colors.grey[300]),
                      ),
                    ),

                    // 2. Tên bệnh viện
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                        child: Text(
                          widget.hospital.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C2A3A),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 3. Giới thiệu
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Giới thiệu',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.hospital.name} tọa lạc tại ${widget.hospital.address}. Đây là cơ sở y tế đạt chuẩn ${widget.hospital.typeLabel}, cung cấp dịch vụ khám chữa bệnh toàn diện với đội ngũ bác sĩ chuyên môn cao.',
                            style: const TextStyle(color: Colors.grey, height: 1.5),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 4. Thời gian làm việc
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thời gian làm việc',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Thứ 2-Thứ 6, 08.00 AM-18.00 PM',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 5. Chuyên khoa
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Chuyên khoa',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _showAllSpecialties = !_showAllSpecialties;
                              });
                            },
                            child: Text(
                              _showAllSpecialties ? 'Thu gọn' : 'Xem tất cả',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Grid chuyên khoa
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: displaySpecialties.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.75,
                        ),
                        itemBuilder: (context, index) {
                          final item = displaySpecialties[index];
                          return Column(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: item.color,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Center(
                                  child: Icon(item.icon, color: Colors.white, size: 30),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.name,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // --- MENU BAR PHÍA DƯỚI ---
            HomeBottomMenuBar(
              selectedTab: HomeMenuTab.home,
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