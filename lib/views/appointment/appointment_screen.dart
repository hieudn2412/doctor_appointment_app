import 'package:doctor_appointment_app/views/appointment/data/appointment_booking_store.dart';
import 'package:doctor_appointment_app/views/home/models/doctor_item.dart';
import 'package:flutter/material.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({
    super.key,
    required this.doctor,
  });

  final DoctorItem doctor;

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? _selectedDate;
  String? _selectedTime;
  bool _isSaving = false;
  String? _bookingId;

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
                            'Đặt lịch hẹn',
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
                    const Text(
                      'Chọn ngày',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C2A3A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCalendarCard(),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  onPressed: _isSaving ? null : _onConfirmPressed,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Xác nhận',
                          style:
                              TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCard() {
    final now = DateTime.now();
    final firstAllowedMonth = DateTime(now.year, now.month);
    final isAtFirstMonth =
        _focusedMonth.year == firstAllowedMonth.year && _focusedMonth.month == firstAllowedMonth.month;

    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final weekdayOffset = (firstDayOfMonth.weekday % 7); // 0 = CN, 1 = T2, ...
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
                'Tháng ${_focusedMonth.month} ${_focusedMonth.year}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111928)),
              ),
              Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: isAtFirstMonth
                        ? null
                        : () {
                      setState(() {
                        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
                        _selectedDate = null;
                      });
                    },
                    icon: Icon(
                      Icons.chevron_left,
                      size: 18,
                      color: isAtFirstMonth ? const Color(0xFFCBD5E1) : const Color(0xFF6B7280),
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() {
                        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
                        _selectedDate = null;
                      });
                    },
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
              Text('CN'), Text('T2'), Text('T3'), Text('T4'), Text('T5'), Text('T6'), Text('T7'),
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

              final date = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
              final isPast = date.isBefore(DateTime(now.year, now.month, now.day));
              final selected = _selectedDate != null &&
                  _selectedDate!.year == date.year &&
                  _selectedDate!.month == date.month &&
                  _selectedDate!.day == date.day;
              return InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: isPast
                    ? null
                    : () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
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

  Future<void> _onConfirmPressed() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày hẹn')),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn giờ hẹn')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final selectedDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _parseHour(_selectedTime!),
      _parseMinute(_selectedTime!),
    );

    try {
      final isUpdate = _bookingId != null;
      if (!isUpdate) {
        _bookingId = await AppointmentBookingStore.instance.addBooking(
          doctor: widget.doctor,
          dateTime: selectedDateTime,
        );
      } else {
        await AppointmentBookingStore.instance.rescheduleBooking(
          _bookingId!,
          selectedDateTime,
        );
      }
      if (!mounted) return;
      _showSuccessDialog(isUpdate: isUpdate);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể lưu lịch hẹn: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  int _parseHour(String timeLabel) {
    final parts = timeLabel.split(' ');
    if (parts.length != 2) return 0;
    final time = parts[0];
    final meridiem = parts[1];
    final hm = time.split('.');
    if (hm.length != 2) return 0;
    var hour = int.tryParse(hm[0]) ?? 0;
    if (meridiem.toUpperCase() == 'PM' && hour != 12) {
      hour += 12;
    } else if (meridiem.toUpperCase() == 'AM' && hour == 12) {
      hour = 0;
    }
    return hour;
  }

  int _parseMinute(String timeLabel) {
    final parts = timeLabel.split(' ');
    if (parts.length != 2) return 0;
    final time = parts[0];
    final hm = time.split('.');
    if (hm.length != 2) return 0;
    return int.tryParse(hm[1]) ?? 0;
  }

  void _showSuccessDialog({bool isUpdate = false}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // Ngăn người dùng tắt dialog bằng cách nhấn ra ngoài
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
                  isUpdate
                      ? 'Lịch hẹn của bạn với ${widget.doctor.name} đã được cập nhật vào lúc $_selectedTime'
                          '${_selectedDate != null ? ', ngày ${_selectedDate!.day} tháng ${_selectedDate!.month} năm ${_selectedDate!.year}' : ''}.'
                      : 'Lịch hẹn của bạn với ${widget.doctor.name} đã được xác nhận vào lúc $_selectedTime'
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
                    onPressed: () {
                      Navigator.of(context).pop(); // Đóng Dialog
                      Navigator.of(context).pop(); // Quay lại trang trước đó
                    },
                    child: const Text(
                      'Xong',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(), // Chỉ đóng dialog để chỉnh sửa tiếp
                  child: const Text(
                    'Chỉnh sửa lịch hẹn',
                    style: TextStyle(color: Color(0xFF6B7280)),
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
