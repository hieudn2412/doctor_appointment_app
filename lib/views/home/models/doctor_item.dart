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
}
