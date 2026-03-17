import 'package:doctor_appointment_app/views/home/models/hospital_item.dart';
import 'package:doctor_appointment_app/views/home/hospital_detail_screen.dart';
import 'package:flutter/material.dart';

class HospitalCard extends StatelessWidget {
  const HospitalCard({
    super.key,
    required this.item,
    this.width = 232,
    this.showRating = true,
  });

  final HospitalItem item;
  final double width;
  final bool showRating;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => HospitalDetailScreen(hospital: item),
            ),
          );
        },
        child: Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: SizedBox(
              width: double.infinity,
              height: 121,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (item.imageAssetPath != null)
                    Image.asset(
                      item.imageAssetPath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const ColoredBox(
                          color: Color(0xFFD1D5DB),
                          child: Center(
                            child: Icon(
                              Icons.local_hospital,
                              size: 34,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        );
                      },
                    )
                  else
                    const ColoredBox(
                      color: Color(0xFFD1D5DB),
                      child: Center(
                        child: Icon(
                          Icons.local_hospital,
                          size: 34,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Text(
              item.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4B5563),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.address,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (showRating) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Text(
                    item.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.star, size: 12, color: Color(0xFFFEB052)),
                  const Icon(Icons.star, size: 12, color: Color(0xFFFEB052)),
                  const Icon(Icons.star, size: 12, color: Color(0xFFFEB052)),
                  const Icon(Icons.star, size: 12, color: Color(0xFFFEB052)),
                  const Icon(Icons.star, size: 12, color: Color(0xFFFEB052)),
                  const SizedBox(width: 4),
                  Text(
                    '(${item.reviewCount} Reviews)',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
          ],
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Divider(height: 1, color: Color(0xFFE5E7EB)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.route, size: 15, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${item.distanceKm.toStringAsFixed(1)} km/${item.etaMinutes}min',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_hospital,
                        size: 15,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          item.typeLabel,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
        )
    );
  }
}
