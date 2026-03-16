import 'package:doctor_appointment_app/views/home/models/hospital_item.dart';
import 'package:flutter/material.dart';
import 'package:doctor_appointment_app/views/home/models/specialty.dart';

class HospitalDetailScreen extends StatelessWidget {
  // 1. Khai báo biến final để nhận dữ liệu truyền vào
  final HospitalItem hospital;

  const HospitalDetailScreen({
    super.key,
    required this.hospital, // Yêu cầu truyền dữ liệu khi gọi màn hình
  });

  @override
  Widget build(BuildContext context) {
    // Danh sách chuyên khoa vẫn có thể để ở đây hoặc truyền từ bên ngoài nếu mỗi bệnh viện có khoa khác nhau
    final List<Specialty> specialties = [
      Specialty(name: 'Nha khoa', icon: Icons.health_and_safety, color: const Color(0xFFE59A9A)),
      Specialty(name: 'Tim mạch', icon: Icons.monitor_heart, color: const Color(0xFF9AC6A7)),
      Specialty(name: 'Hô hấp', icon: Icons.air, color: const Color(0xFFF4B183)),
      Specialty(name: 'Tổng thể', icon: Icons.medical_information, color: const Color(0xFFB1A7D1)),
    ];

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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hình ảnh bệnh viện (Dùng từ data truyền vào)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: hospital.imageAssetPath != null
                    ? Image.asset(
                  hospital.imageAssetPath!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
                    : Image.network(
                  'https://picsum.photos/800/400', // Dự phòng nếu ko có ảnh
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // 2. Tên bệnh viện (Dùng hospital.name)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  hospital.name,
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

            // 3. Giới thiệu (Dùng hospital.address hoặc thêm trường description vào model)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Giới thiệu',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C2A3A)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Địa chỉ: ${hospital.address}. Đây là một cơ sở y tế đạt chuẩn ${hospital.typeLabel}, mang lại dịch vụ tốt nhất cho bệnh nhân.',
                    style: const TextStyle(color: Color(0xFF6B7280), height: 1.5, fontSize: 14),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C2A3A)),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Thứ 2 - Thứ 6: 08:00 AM - 18:00 PM\nCấp cứu: 24/7',
                    style: TextStyle(color: Color(0xFF6B7280)),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C2A3A)),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Xem tất cả', style: TextStyle(color: Color(0xFF6B7280))),
                  ),
                ],
              ),
            ),

            // Grid chuyên khoa với hiệu ứng "Glossy" nhẹ cho giống ảnh mẫu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: specialties.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final item = specialties[index];
                  return Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: item.color,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Stack(
                          children: [
                            // Hiệu ứng bóng bề mặt nhẹ
                            Positioned(
                              top: 0, left: 0,
                              child: Container(
                                width: 60, height: 30,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Colors.white.withOpacity(0.3), Colors.transparent],
                                  ),
                                ),
                              ),
                            ),
                            Center(child: Icon(item.icon, color: Colors.white, size: 28)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.name,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}