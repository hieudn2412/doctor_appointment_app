import 'package:doctor_appointment_app/views/appointment/data/appointment_booking_store.dart';
import 'package:doctor_appointment_app/views/appointment/models/appointment_booking.dart';
import 'package:doctor_appointment_app/views/appointment/reschedule_appointment_screen.dart';
import 'package:doctor_appointment_app/views/appointment/write_review_screen.dart';
import 'package:doctor_appointment_app/views/home/doctor_list_screen.dart';
import 'package:doctor_appointment_app/views/home/home_screen.dart';
import 'package:doctor_appointment_app/views/home/widgets/home_bottom_menu_bar.dart';
import 'package:doctor_appointment_app/views/profile/profile_screen.dart';
import 'package:flutter/material.dart';

class ManageAppointmentsScreen extends StatefulWidget {
  const ManageAppointmentsScreen({super.key});

  @override
  State<ManageAppointmentsScreen> createState() => _ManageAppointmentsScreenState();
}

class _ManageAppointmentsScreenState extends State<ManageAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final AppointmentBookingStore _store = AppointmentBookingStore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              'Lịch hẹn của tôi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(color: Color(0xFF1C2A3A), width: 3),
                insets: EdgeInsets.symmetric(horizontal: 34),
              ),
              labelColor: const Color(0xFF1C2A3A),
              unselectedLabelColor: const Color(0xFF9CA3AF),
              labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Sắp tới'),
                Tab(text: 'Đã khám'),
                Tab(text: 'Lịch trình'),
              ],
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _AppointmentList(
                    tabType: _AppointmentTabType.upcoming,
                    bookings: _store.upcomingBookings,
                    onCancelTap: _showCancelModal,
                    onWriteReviewTap: _openWriteReview,
                    onRescheduleTap: _openReschedule,
                  ),
                  _AppointmentList(
                    tabType: _AppointmentTabType.completed,
                    bookings: _store.completedBookings,
                    onCancelTap: _showCancelModal,
                    onWriteReviewTap: _openWriteReview,
                    onRescheduleTap: _openReschedule,
                  ),
                  _ScheduleTabView(
                    bookings: _store.upcomingBookings,
                    onCancelTap: _showCancelModal,
                    onWriteReviewTap: _openWriteReview,
                    onRescheduleTap: _openReschedule,
                  ),
                ],
              ),
            ),
            HomeBottomMenuBar(
              selectedTab: HomeMenuTab.calendar,
              onHomeTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const HomeScreen(),
                  ),
                );
              },
              onSearchTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const DoctorListScreen(),
                  ),
                );
              },
              onProfileTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelModal(String bookingId) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x66000000),
      builder: (context) {
        return Container(
          height: 199,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(34),
              topRight: Radius.circular(34),
              bottomLeft: Radius.circular(54),
              bottomRight: Radius.circular(54),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'Hủy lịch',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C2A3A),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: 16),
              const Text(
                'Bạn có muốn hủy lịch khám không?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        height: 41,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Text(
                          'Bỏ qua',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1C2A3A),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () async {
                        await _store.cancelBooking(bookingId);
                        if (mounted) Navigator.of(context).pop();
                      },
                      child: Container(
                        height: 41,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C2A3A),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Text(
                          'Tôi muốn',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _openWriteReview(AppointmentBooking booking) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WriteReviewScreen(
          doctorId: booking.doctorId, // Đã thêm doctorId
          doctorName: booking.doctorName,
          specialty: booking.specialty,
          hospital: booking.hospital,
          imagePath: booking.imagePath,
        ),
      ),
    );
  }

  void _openReschedule(AppointmentBooking booking) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RescheduleAppointmentScreen(
          bookingId: booking.id,
          doctorName: booking.doctorName,
          specialty: booking.specialty,
          hospital: booking.hospital,
          imagePath: booking.imagePath,
        ),
      ),
    );
  }
}

enum _AppointmentTabType { upcoming, completed, schedule }

class _AppointmentList extends StatelessWidget {
  const _AppointmentList({
    required this.tabType,
    required this.bookings,
    required this.onCancelTap,
    required this.onWriteReviewTap,
    required this.onRescheduleTap,
  });

  final _AppointmentTabType tabType;
  final List<AppointmentBooking> bookings;
  final ValueChanged<String> onCancelTap;
  final ValueChanged<AppointmentBooking> onWriteReviewTap;
  final ValueChanged<AppointmentBooking> onRescheduleTap;

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có lịch hẹn nào',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF9CA3AF),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 10),
      children: [
        for (final booking in bookings) ...[
          _AppointmentCard(
            booking: booking,
            tabType: tabType,
            onCancelTap: onCancelTap,
            onWriteReviewTap: onWriteReviewTap,
            onRescheduleTap: onRescheduleTap,
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ScheduleTabView extends StatelessWidget {
  const _ScheduleTabView({
    required this.bookings,
    required this.onCancelTap,
    required this.onWriteReviewTap,
    required this.onRescheduleTap,
  });

  final List<AppointmentBooking> bookings;
  final ValueChanged<String> onCancelTap;
  final ValueChanged<AppointmentBooking> onWriteReviewTap;
  final ValueChanged<AppointmentBooking> onRescheduleTap;

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return const Center(
        child: Text(
          'Không có lịch trình sắp tới',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF9CA3AF),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 10),
      children: [
        for (final booking in bookings) ...[
          _ScheduleCard(
            booking: booking,
            onCancelTap: onCancelTap,
            onWriteReviewTap: onWriteReviewTap,
            onRescheduleTap: onRescheduleTap,
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.booking,
    required this.onCancelTap,
    required this.onWriteReviewTap,
    required this.onRescheduleTap,
  });

  final AppointmentBooking booking;
  final ValueChanged<String> onCancelTap;
  final ValueChanged<AppointmentBooking> onWriteReviewTap;
  final ValueChanged<AppointmentBooking> onRescheduleTap;

  @override
  Widget build(BuildContext context) {
    final timeText =
        '${_formatTime(booking.dateTime)} • ${booking.dateTime.day} tháng ${booking.dateTime.month}, ${booking.dateTime.year}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 0.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            timeText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2A37),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 12),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 109,
                  height: 109,
                  child: Image.asset(
                    booking.imagePath,
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
                      booking.doctorName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2A37),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      booking.specialty,
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
                            booking.hospital,
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
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  text: 'Hủy',
                  isPrimary: false,
                  onTap: () => onCancelTap(booking.id),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ActionButton(
                  text: 'Đổi lịch',
                  isPrimary: true,
                  onTap: () => onRescheduleTap(booking),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _MiniCalendarCard(
            displayDate: booking.dateTime,
            useTopMargin: false,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final displayHour = hour == 0
        ? 12
        : (hour > 12 ? hour - 12 : hour);
    final meridiem = hour >= 12 ? 'PM' : 'AM';
    return '${displayHour.toString().padLeft(2, '0')}:$minute $meridiem';
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.booking,
    required this.tabType,
    required this.onCancelTap,
    required this.onWriteReviewTap,
    required this.onRescheduleTap,
  });

  final AppointmentBooking booking;
  final _AppointmentTabType tabType;
  final ValueChanged<String> onCancelTap;
  final ValueChanged<AppointmentBooking> onWriteReviewTap;
  final ValueChanged<AppointmentBooking> onRescheduleTap;

  @override
  Widget build(BuildContext context) {
    final isCompleted = tabType == _AppointmentTabType.completed;
    final firstButtonText = isCompleted ? 'Đặt lại' : 'Hủy';
    final secondButtonText = isCompleted ? 'Viết đánh giá' : 'Đổi lịch';

    final timeText =
        '${_formatTime(booking.dateTime)} • ${booking.dateTime.day} tháng ${booking.dateTime.month}, ${booking.dateTime.year}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 0.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            timeText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2A37),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 12),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 109,
                  height: 109,
                  child: Image.asset(
                    booking.imagePath,
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
                      booking.doctorName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2A37),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      booking.specialty,
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
                            booking.hospital,
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
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  text: firstButtonText,
                  isPrimary: false,
                  onTap: isCompleted ? () => onRescheduleTap(booking) : () => onCancelTap(booking.id),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ActionButton(
                  text: secondButtonText,
                  isPrimary: true,
                  onTap:
                      isCompleted ? () => onWriteReviewTap(booking) : () => onRescheduleTap(booking),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final displayHour = hour == 0
        ? 12
        : (hour > 12 ? hour - 12 : hour);
    final meridiem = hour >= 12 ? 'PM' : 'AM';
    return '${displayHour.toString().padLeft(2, '0')}:$minute $meridiem';
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.text,
    required this.isPrimary,
    this.onTap,
  });

  final String text;
  final bool isPrimary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        height: 37,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF1C2A3A) : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isPrimary ? Colors.white : const Color(0xFF1C2A3A),
          ),
        ),
      ),
    );
  }
}

class _MiniCalendarCard extends StatelessWidget {
  const _MiniCalendarCard({
    required this.displayDate,
    this.useTopMargin = true,
  });

  final DateTime displayDate;
  final bool useTopMargin;

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(displayDate.year, displayDate.month, 1);
    final lastDayOfMonth = DateTime(displayDate.year, displayDate.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final weekdayOffset = (firstDayOfMonth.weekday % 7); // 0 = CN, 1 = T2...
    
    // Tính tổng số ô cần hiển thị (bội số của 7)
    final totalCells = ((weekdayOffset + daysInMonth + 6) ~/ 7) * 7;
    
    final cells = List<int?>.generate(totalCells, (index) {
      final dayNum = index - weekdayOffset + 1;
      if (dayNum < 1 || dayNum > daysInMonth) return null;
      return dayNum;
    });

    return Container(
      margin: useTopMargin ? const EdgeInsets.only(top: 10) : EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
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
                'Tháng ${displayDate.month} ${displayDate.year}', 
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)
              ),
              const Row(
                children: [
                  Icon(Icons.chevron_left, size: 16, color: Color(0xFF9CA3AF)),
                  Icon(Icons.chevron_right, size: 16, color: Color(0xFF1C2A3A)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [Text('CN'), Text('T2'), Text('T3'), Text('T4'), Text('T5'), Text('T6'), Text('T7')],
          ),
          const SizedBox(height: 6),
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
              if (dayNumber == null) return const SizedBox.shrink();
              
              final isTargetDay = dayNumber == displayDate.day;
              
              return Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isTargetDay ? const Color(0xFF1C2A3A) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$dayNumber',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isTargetDay ? Colors.white : const Color(0xFF6B7280),
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
