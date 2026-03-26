class HospitalItem {
  const HospitalItem({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.distanceKm,
    required this.etaMinutes,
    required this.typeLabel,
    this.imageAssetPath,
    this.isBookmarked = false,
  });

  final String id;
  final String name;
  final String address;
  final double rating;
  final int reviewCount;
  final double distanceKm;
  final int etaMinutes;
  final String typeLabel;
  final String? imageAssetPath;
  final bool isBookmarked;

  HospitalItem copyWith({
    String? id,
    String? name,
    String? address,
    double? rating,
    int? reviewCount,
    double? distanceKm,
    int? etaMinutes,
    String? typeLabel,
    String? imageAssetPath,
    bool? isBookmarked,
  }) {
    return HospitalItem(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      distanceKm: distanceKm ?? this.distanceKm,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      typeLabel: typeLabel ?? this.typeLabel,
      imageAssetPath: imageAssetPath ?? this.imageAssetPath,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'address': address,
      'rating': rating,
      'reviewCount': reviewCount,
      'distanceKm': distanceKm,
      'etaMinutes': etaMinutes,
      'typeLabel': typeLabel,
      'imageAssetPath': imageAssetPath,
      'isBookmarked': isBookmarked ? 1 : 0,
    };
  }

  factory HospitalItem.fromMap(Map<String, Object?> json) {
    return HospitalItem(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      etaMinutes: (json['etaMinutes'] as num?)?.toInt() ?? 0,
      typeLabel: json['typeLabel'] as String? ?? '',
      imageAssetPath: json['imageAssetPath'] as String?,
      isBookmarked: (json['isBookmarked'] as num?)?.toInt() == 1,
    );
  }
}
