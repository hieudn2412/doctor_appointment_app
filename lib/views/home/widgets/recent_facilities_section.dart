import 'package:doctor_appointment_app/views/home/data/hospital_mock_data.dart';
import 'package:doctor_appointment_app/views/home/widgets/hospital_card.dart';
import 'package:flutter/material.dart';

class RecentFacilitiesSection extends StatelessWidget {
  const RecentFacilitiesSection({
    super.key,
    required this.onSeeAllTap,
  });

  final VoidCallback onSeeAllTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cơ sở y tế gần đây',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C2A3A),
                ),
              ),
              InkWell(
                onTap: onSeeAllTap,
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: _buildCards()),
        ),
      ],
    );
  }

  List<Widget> _buildCards() {
    final widgets = <Widget>[];
    for (var i = 0; i < kHospitalMockData.length; i++) {
      widgets.add(HospitalCard(item: kHospitalMockData[i]));
      widgets.add(SizedBox(width: i == kHospitalMockData.length - 1 ? 24 : 16));
    }
    return widgets;
  }
}
