class DoctorReview {
  const DoctorReview({
    required this.id,
    required this.userId,
    required this.doctorId,
    required this.rating,
    required this.content,
    required this.userName,
    required this.createdAt,
  });

  final String id;
  final int userId;
  final String doctorId;
  final int rating;
  final String content;
  final String userName;
  final DateTime createdAt;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'user_id': userId,
      'doctor_id': doctorId,
      'rating': rating,
      'content': content,
      'user_name': userName,
      'created_at_ms': createdAt.millisecondsSinceEpoch,
    };
  }

  static DoctorReview fromMap(Map<String, Object?> map) {
    return DoctorReview(
      id: map['id'] as String,
      userId: (map['user_id'] as num).toInt(),
      doctorId: map['doctor_id'] as String,
      rating: (map['rating'] as num).toInt(),
      content: map['content'] as String,
      userName: map['user_name'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch((map['created_at_ms'] as num).toInt()),
    );
  }
}
