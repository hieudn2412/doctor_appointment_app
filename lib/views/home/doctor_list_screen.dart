import 'package:flutter/material.dart';
import 'package:doctor_appointment_app/implementations/repository/doctor_repository.dart';
import 'package:doctor_appointment_app/views/home/doctor_detail_screen.dart';
import 'package:doctor_appointment_app/views/home/models/doctor_item.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DoctorRepository _doctorRepo = DoctorRepository(); // Khởi tạo Repository

  String _selectedFilter = 'Tất cả';

  static const List<String> _filters = [
    'Tất cả',
    'Đa khoa',
    'Tim mạch',
    'Nha khoa',
    'Hô hấp',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            children: [
              // --- Header ---
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF4B5563)),
                  ),
                  const Expanded(
                    child: Text(
                      'Danh sách bác sĩ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 8),

              // --- Thanh tìm kiếm ---
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          // Gọi setState để FutureBuilder chạy lại fetch data từ DB
                          setState(() {});
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Tìm bác sĩ...',
                          hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // --- Bộ lọc chuyên khoa (Chips) ---
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final selected = _selectedFilter == filter;
                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFF1F2937) : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFF1F2937)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 12,
                            color: selected ? Colors.white : const Color(0xFF1F2937),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // --- Danh sách Bác sĩ từ Database ---
              Expanded(
                child: FutureBuilder<List<DoctorItem>>(
                  // Sử dụng hàm search trong Repo để lọc theo text query
                  future: _doctorRepo.searchDoctors(_searchController.text),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Lỗi: ${snapshot.error}'));
                    }

                    // Lấy list từ DB và lọc tiếp theo chuyên khoa trên UI
                    final rawList = snapshot.data ?? [];
                    final doctors = rawList.where((doc) {
                      return _selectedFilter == 'Tất cả' ||
                          doc.specialty.toLowerCase() == _selectedFilter.toLowerCase();
                    }).toList();

                    return Column(
                      children: [
                        // Kết quả tìm thấy
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${doctors.length} kết quả',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const Text(
                              'Mặc định',
                              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Danh sách hiển thị
                        Expanded(
                          child: ListView.separated(
                            itemCount: doctors.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              return _DoctorCard(
                                item: doctors[index],
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => DoctorDetailScreen(doctor: doctors[index]),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
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

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({
    required this.item,
    required this.onTap,
  });

  final DoctorItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              offset: Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            // Ảnh bác sĩ
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 74,
                height: 74,
                child: item.imageAssetPath == null
                    ? const ColoredBox(
                  color: Color(0xFFE5E7EB),
                  child: Icon(Icons.person, size: 34, color: Color(0xFF6B7280)),
                )
                    : Image.asset(
                  item.imageAssetPath!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const ColoredBox(
                    color: Color(0xFFE5E7EB),
                    child: Icon(Icons.person, size: 34, color: Color(0xFF6B7280)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Thông tin bác sĩ
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        item.isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: item.isFavorite ? Colors.red : const Color(0xFF4B5563),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.specialty,
                    style: const TextStyle(fontSize: 15, color: Color(0xFF374151), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF6B7280)),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          item.hospitalName,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 4),
                      Text(
                        '${item.rating.toStringAsFixed(1)} | ${item.reviewCount} Đánh giá',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
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