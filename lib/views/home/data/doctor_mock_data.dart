import 'package:doctor_appointment_app/views/home/models/doctor_item.dart';

const List<DoctorItem> kDoctorMockData = [
  DoctorItem(
    id: 'doc_001',
    name: 'Bác sĩ Nguyễn Văn A',
    specialty: 'Chuyên khoa Tim mạch',
    hospitalName: 'Bệnh viện Quốc tế DoLife',
    rating: 5.0,
    reviewCount: 1872,
    imageAssetPath: 'assets/images/doctor.png',
  ),
  DoctorItem(
    id: 'doc_002',
    name: 'Bác sĩ Phạm Thị B',
    specialty: 'Chuyên khoa sản phụ',
    hospitalName: 'Bệnh viện Quốc tế DoLife',
    rating: 4.9,
    reviewCount: 127,
    imageAssetPath: 'assets/images/doctor.png',
  ),
  DoctorItem(
    id: 'doc_003',
    name: 'Bác sĩ Nguyễn Văn C',
    specialty: 'Chuyên khoa Da liễu',
    hospitalName: 'Bệnh viện Quốc tế DoLife',
    rating: 4.7,
    reviewCount: 5223,
    imageAssetPath: 'assets/images/doctor.png',
  ),
  DoctorItem(
    id: 'doc_004',
    name: 'Bác sĩ Hoàng Thị B',
    specialty: 'Chuyên khoa Thần kinh',
    hospitalName: 'Bệnh viện Quốc tế DoLife',
    rating: 5.0,
    reviewCount: 405,
    imageAssetPath: 'assets/images/doctor.png',
  ),
];
