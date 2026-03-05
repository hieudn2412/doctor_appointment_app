import 'package:doctor_appointment_app/views/home/models/hospital_item.dart';

const List<HospitalItem> kHospitalMockData = [
  HospitalItem(
    id: 'hos_dolife_001',
    name: 'Bệnh viện Quốc tế DoLife',
    address: '123 Oak Street, CA 98765',
    rating: 5.0,
    reviewCount: 58,
    distanceKm: 2.5,
    etaMinutes: 40,
    typeLabel: 'Hospital',
    imageAssetPath: 'assets/images/hospital_demo.jpg',
    isBookmarked: true,
  ),
  HospitalItem(
    id: 'hos_phuong_dong_002',
    name: 'Bệnh viện Đa khoa Phương Đông',
    address: '555 Bridge Street, Golden Gate',
    rating: 4.9,
    reviewCount: 108,
    distanceKm: 3.2,
    etaMinutes: 48,
    typeLabel: 'Clinic',
    imageAssetPath: 'assets/images/hospital_demo.jpg',
  ),
];
