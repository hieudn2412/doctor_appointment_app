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
}
