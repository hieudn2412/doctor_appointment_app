class DoctorItem {
  const DoctorItem({
    required this.id,
    required this.name,
    required this.specialty,
    required this.hospitalName,
    required this.rating,
    required this.reviewCount,
    this.imageAssetPath,
    this.isFavorite = false,
  });

  final String id;
  final String name;
  final String specialty;
  final String hospitalName;
  final double rating;
  final int reviewCount;
  final String? imageAssetPath;
  final bool isFavorite;

  DoctorItem copyWith({
    String? id,
    String? name,
    String? specialty,
    String? hospitalName,
    double? rating,
    int? reviewCount,
    String? imageAssetPath,
    bool? isFavorite,
  }) {
    return DoctorItem(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      hospitalName: hospitalName ?? this.hospitalName,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageAssetPath: imageAssetPath ?? this.imageAssetPath,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'specialty': specialty,
      'hospitalName': hospitalName,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageAssetPath': imageAssetPath,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory DoctorItem.fromMap(Map<String, Object?> json) {
    return DoctorItem(
      id: json['id'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String,
      hospitalName: json['hospitalName'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      imageAssetPath: json['imageAssetPath'] as String?,
      isFavorite: (json['isFavorite'] as num?)?.toInt() == 1,
    );
  }
}
