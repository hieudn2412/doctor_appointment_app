enum AppointmentStatus { upcoming, completed }

class AppointmentBooking {
  const AppointmentBooking({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.hospital,
    required this.imagePath,
    required this.dateTime,
    this.status = AppointmentStatus.upcoming,
  });

  final String id;
  final String doctorName;
  final String specialty;
  final String hospital;
  final String imagePath;
  final DateTime dateTime;
  final AppointmentStatus status;

  AppointmentBooking copyWith({
    String? id,
    String? doctorName,
    String? specialty,
    String? hospital,
    String? imagePath,
    DateTime? dateTime,
    AppointmentStatus? status,
  }) {
    return AppointmentBooking(
      id: id ?? this.id,
      doctorName: doctorName ?? this.doctorName,
      specialty: specialty ?? this.specialty,
      hospital: hospital ?? this.hospital,
      imagePath: imagePath ?? this.imagePath,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'doctor_name': doctorName,
      'specialty': specialty,
      'hospital': hospital,
      'image_path': imagePath,
      'date_time_ms': dateTime.millisecondsSinceEpoch,
      'status': _statusToString(status),
    };
  }

  static AppointmentBooking fromMap(Map<String, Object?> map) {
    return AppointmentBooking(
      id: map['id'] as String,
      doctorName: map['doctor_name'] as String,
      specialty: map['specialty'] as String,
      hospital: map['hospital'] as String,
      imagePath: map['image_path'] as String,
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['date_time_ms'] as int),
      status: _statusFromString(map['status'] as String?),
    );
  }

  static String _statusToString(AppointmentStatus status) {
    return switch (status) {
      AppointmentStatus.upcoming => 'upcoming',
      AppointmentStatus.completed => 'completed',
    };
  }

  static AppointmentStatus _statusFromString(String? rawStatus) {
    return switch (rawStatus) {
      'completed' => AppointmentStatus.completed,
      _ => AppointmentStatus.upcoming,
    };
  }
}
