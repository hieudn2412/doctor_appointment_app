import 'package:flutter/material.dart';

class RescheduleAppointmentScreen extends StatefulWidget {
  const RescheduleAppointmentScreen({
    super.key,
    required this.doctorName,
    required this.specialty,
    required this.hospital,
    required this.imagePath,
  });

  final String doctorName;
  final String specialty;
  final String hospital;
  final String imagePath;

  @override
  State<RescheduleAppointmentScreen> createState() => _RescheduleAppointmentScreenState();
}

class _RescheduleAppointmentScreenState extends State<RescheduleAppointmentScreen> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? _selectedDate;
  String _selectedTime = '10.00 AM';

  static const List<String> _timeSlots = [
    '09.00 AM',
    '09.30 AM',
    '10.00 AM',
    '10.30 AM',
    '11.00 AM',
    '11.30 AM',
    '3.00 PM',
    '3.30 PM',
    '4.00 PM',
    '4.30 PM',
    '5.00 PM',
    '5.30 PM',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF374151)),
                        ),
                        const Expanded(
                          child: Text(
                            'Đổi lịch hẹn',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _DoctorSummaryCard(
                      doctorName: widget.doctorName,
                      specialty: widget.specialty,
                      hospital: widget.hospital,
                      imagePath: widget.imagePath,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Chọn ngày',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C2A3A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _CalendarCard(
                      focusedMonth: _focusedMonth,
                      selectedDate: _selectedDate,
                      onMonthChanged: (month) {
                        setState(() {
                          _focusedMonth = month;
                          _selectedDate = null;
                        });
                      },
                      onDateSelected: (date) => setState(() => _selectedDate = date),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Chọn giờ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C2A3A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _timeSlots.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 2.2,
                      ),
                      itemBuilder: (context, index) {
                        final slot = _timeSlots[index];
                        final selected = slot == _selectedTime;
                        return InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => setState(() => _selectedTime = slot),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected ? const Color(0xFF1C2A3A) : const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              slot,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C2A3A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  ),
                  onPressed: _showSuccessDialog,
                  child: const Text(
                    'Xác nhận',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: Color(0xFFA8CCC0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Hoàn tất!!',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: Color(0xFF1F2A37)),
                ),
                const SizedBox(height: 10),
                Text(
                  'Bạn đã đổi lịch hẹn thành công vào lúc $_selectedTime'
                      '${_selectedDate != null ? ', ngày ${_selectedDate!.day} tháng ${_selectedDate!.month} năm ${_selectedDate!.year}' : ''}.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F2A44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Xong',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DoctorSummaryCard extends StatelessWidget {
  const _DoctorSummaryCard({
    required this.doctorName,
    required this.specialty,
    required this.hospital,
    required this.imagePath,
  });

  final String doctorName;
  final String specialty;
  final String hospital;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 0.5),
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), offset: Offset(0, 4), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 109,
              height: 109,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const ColoredBox(
                  color: Color(0xFFE5E7EB),
                  child: Icon(Icons.person, size: 34, color: Color(0xFF6B7280)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctorName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2A37),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  specialty,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF4B5563)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        hospital,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.focusedMonth,
    required this.selectedDate,
    required this.onMonthChanged,
    required this.onDateSelected,
  });

  final DateTime focusedMonth;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstAllowedMonth = DateTime(now.year, now.month);
    final isAtFirstMonth =
        focusedMonth.year == firstAllowedMonth.year && focusedMonth.month == firstAllowedMonth.month;

    final firstDayOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth = DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final weekdayOffset = (firstDayOfMonth.weekday % 7); // 0 = CN
    final totalCells = ((weekdayOffset + daysInMonth + 6) ~/ 7) * 7;

    final cells = List<int?>.generate(totalCells, (index) {
      final dayNumber = index - weekdayOffset + 1;
      if (dayNumber < 1 || dayNumber > daysInMonth) return null;
      return dayNumber;
    });
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x12000000), blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tháng ${focusedMonth.month} ${focusedMonth.year}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111928)),
              ),
              Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: isAtFirstMonth
                        ? null
                        : () => onMonthChanged(
                      DateTime(focusedMonth.year, focusedMonth.month - 1, 1),
                    ),
                    icon: Icon(
                      Icons.chevron_left,
                      size: 18,
                      color: isAtFirstMonth ? const Color(0xFFCBD5E1) : const Color(0xFF6B7280),
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => onMonthChanged(
                      DateTime(focusedMonth.year, focusedMonth.month + 1, 1),
                    ),
                    icon: const Icon(Icons.chevron_right, size: 18, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('CN'),
              Text('T2'),
              Text('T3'),
              Text('T4'),
              Text('T5'),
              Text('T6'),
              Text('T7'),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cells.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final dayNumber = cells[index];
              if (dayNumber == null) {
                return const SizedBox.shrink();
              }

              final date = DateTime(focusedMonth.year, focusedMonth.month, dayNumber);
              final isPast = date.isBefore(DateTime(now.year, now.month, now.day));
              final selected = selectedDate != null &&
                  selectedDate!.year == date.year &&
                  selectedDate!.month == date.month &&
                  selectedDate!.day == date.day;
              return InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: isPast ? null : () => onDateSelected(date),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF1C2A3A) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$dayNumber',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? Colors.white
                          : (isPast ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

