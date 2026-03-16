import 'package:doctor_appointment_app/views/appointment/data/appointment_booking_store.dart';
import 'package:doctor_appointment_app/views/appointment/models/appointment_booking.dart';
import 'package:doctor_appointment_app/views/appointment/write_review_screen.dart';
import 'package:doctor_appointment_app/views/home/widgets/home_bottom_menu_bar.dart';
import 'package:doctor_appointment_app/views/profile/profile_screen.dart';
import 'package:flutter/material.dart';

class ManageAppointmentsScreen extends StatefulWidget {
  const ManageAppointmentsScreen({super.key});

  @override
  State<ManageAppointmentsScreen> createState() =>
      _ManageAppointmentsScreenState();
}

class _ManageAppointmentsScreenState extends State<ManageAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final AppointmentBookingStore _store = AppointmentBookingStore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              indicatorColor: const Color(0xFF1C2A3A),
              labelColor: const Color(0xFF1C2A3A),
              unselectedLabelColor: const Color(0xFF9CA3AF),
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'Sắp tới'),
                Tab(text: 'Đã khám'),
                Tab(text: 'Lịch trình'),
              ],
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Expanded(
              child: AnimatedBuilder(
                animation: _store,
                builder: (context, _) {
                  if (!_store.isLoaded) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 12),
                          Text(
                            'Đang tải lịch hẹn...',
                            style: TextStyle(color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    );
                  }

                  final upcomingBookings = _store.upcomingBookings;
                  final completedBookings = _store.completedBookings;
                  final scheduledBooking = upcomingBookings.isEmpty
                      ? null
                      : upcomingBookings.first;

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _AppointmentList(
                        tabType: _AppointmentTabType.upcoming,
                        bookings: upcomingBookings,
                        onCancelTap: _showCancelModal,
                        onRescheduleTap: _rescheduleBooking,
                        onCompleteTap: _markBookingCompleted,
                        onRebookTap: _rebookAppointment,
                        onWriteReviewTap: _openWriteReview,
                      ),
                      _AppointmentList(
                        tabType: _AppointmentTabType.completed,
                        bookings: completedBookings,
                        onCancelTap: _showCancelModal,
                        onRescheduleTap: _rescheduleBooking,
                        onCompleteTap: _markBookingCompleted,
                        onRebookTap: _rebookAppointment,
                        onWriteReviewTap: _openWriteReview,
                      ),
                      _ScheduleTabView(
                        booking: scheduledBooking,
                        onCancelTap: _showCancelModal,
                        onRescheduleTap: _rescheduleBooking,
                        onCompleteTap: _markBookingCompleted,
                      ),
                    ],
                  );
                },
              ),
            ),
            HomeBottomMenuBar(
              selectedTab: HomeMenuTab.calendar,
              onHomeTap: () => Navigator.of(context).pop(),
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

  void _showCancelModal(AppointmentBooking booking) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x66000000),
      builder: (sheetContext) {
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
                      onTap: () => Navigator.of(sheetContext).pop(),
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
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        _store.cancelBooking(booking.id);
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
          doctorName: booking.doctorName,
          specialty: booking.specialty,
          hospital: booking.hospital,
          imagePath: booking.imagePath,
        ),
      ),
    );
  }

  Future<void> _rescheduleBooking(AppointmentBooking booking) async {
    final pickedDateTime = await _pickDateTime(booking.dateTime);
    if (pickedDateTime == null) {
      return;
    }
    await _store.rescheduleBooking(booking.id, pickedDateTime);
    if (!mounted) {
      return;
    }
    _showMessage('Đã đổi lịch hẹn thành công.');
  }

  Future<void> _markBookingCompleted(AppointmentBooking booking) async {
    await _store.markBookingCompleted(booking.id);
    if (!mounted) {
      return;
    }
    _showMessage('Lịch hẹn đã chuyển sang mục Đã khám.');
  }

  Future<void> _rebookAppointment(AppointmentBooking booking) async {
    final suggestedDate = DateTime.now().add(const Duration(days: 1));
    final pickedDateTime = await _pickDateTime(suggestedDate);
    if (pickedDateTime == null) {
      return;
    }
    await _store.rebookFrom(source: booking, dateTime: pickedDateTime);
    if (!mounted) {
      return;
    }
    _tabController.animateTo(0);
    _showMessage('Đã đặt lại lịch hẹn.');
  }

  Future<DateTime?> _pickDateTime(DateTime initialDateTime) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2035, 12, 31),
      helpText: 'Chọn ngày hẹn',
    );
    if (pickedDate == null) {
      return null;
    }

    if (!mounted) {
      return null;
    }

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDateTime),
      helpText: 'Chọn giờ hẹn',
    );
    if (pickedTime == null) {
      return null;
    }

    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

enum _AppointmentTabType { upcoming, completed }

class _AppointmentList extends StatelessWidget {
  const _AppointmentList({
    required this.tabType,
    required this.bookings,
    required this.onCancelTap,
    required this.onRescheduleTap,
    required this.onCompleteTap,
    required this.onRebookTap,
    required this.onWriteReviewTap,
  });

  final _AppointmentTabType tabType;
  final List<AppointmentBooking> bookings;
  final ValueChanged<AppointmentBooking> onCancelTap;
  final ValueChanged<AppointmentBooking> onRescheduleTap;
  final ValueChanged<AppointmentBooking> onCompleteTap;
  final ValueChanged<AppointmentBooking> onRebookTap;
  final ValueChanged<AppointmentBooking> onWriteReviewTap;

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      final message = tabType == _AppointmentTabType.upcoming
          ? 'Bạn chưa có lịch hẹn sắp tới.'
          : 'Bạn chưa có lịch hẹn đã khám.';
      return _EmptyState(message: message);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 10),
      itemBuilder: (context, index) {
        return _AppointmentCard(
          booking: bookings[index],
          tabType: tabType,
          onCancelTap: onCancelTap,
          onRescheduleTap: onRescheduleTap,
          onCompleteTap: onCompleteTap,
          onRebookTap: onRebookTap,
          onWriteReviewTap: onWriteReviewTap,
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemCount: bookings.length,
    );
  }
}

class _ScheduleTabView extends StatelessWidget {
  const _ScheduleTabView({
    required this.booking,
    required this.onCancelTap,
    required this.onRescheduleTap,
    required this.onCompleteTap,
  });

  final AppointmentBooking? booking;
  final ValueChanged<AppointmentBooking> onCancelTap;
  final ValueChanged<AppointmentBooking> onRescheduleTap;
  final ValueChanged<AppointmentBooking> onCompleteTap;

  @override
  Widget build(BuildContext context) {
    if (booking == null) {
      return const _EmptyState(
        message: 'Bạn chưa có lịch hẹn nào trong lịch trình.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 10),
      children: [
        _ScheduleCard(
          booking: booking!,
          onCancelTap: onCancelTap,
          onRescheduleTap: onRescheduleTap,
          onCompleteTap: onCompleteTap,
        ),
      ],
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.booking,
    required this.onCancelTap,
    required this.onRescheduleTap,
    required this.onCompleteTap,
  });

  final AppointmentBooking booking;
  final ValueChanged<AppointmentBooking> onCancelTap;
  final ValueChanged<AppointmentBooking> onRescheduleTap;
  final ValueChanged<AppointmentBooking> onCompleteTap;

  @override
  Widget build(BuildContext context) {
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
            _formatAppointmentDateTime(booking.dateTime),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2A37),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 12),
          _DoctorInfo(booking: booking),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  text: 'Hủy',
                  isPrimary: false,
                  onTap: () => onCancelTap(booking),
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
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => onCompleteTap(booking),
              child: const Text('Đánh dấu đã khám'),
            ),
          ),
          const SizedBox(height: 14),
          _MiniCalendarCard(
            selectedDay: booking.dateTime.day,
            month: booking.dateTime.month,
            year: booking.dateTime.year,
            useTopMargin: false,
          ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.booking,
    required this.tabType,
    required this.onCancelTap,
    required this.onRescheduleTap,
    required this.onCompleteTap,
    required this.onRebookTap,
    required this.onWriteReviewTap,
  });

  final AppointmentBooking booking;
  final _AppointmentTabType tabType;
  final ValueChanged<AppointmentBooking> onCancelTap;
  final ValueChanged<AppointmentBooking> onRescheduleTap;
  final ValueChanged<AppointmentBooking> onCompleteTap;
  final ValueChanged<AppointmentBooking> onRebookTap;
  final ValueChanged<AppointmentBooking> onWriteReviewTap;

  @override
  Widget build(BuildContext context) {
    final firstButtonText = tabType == _AppointmentTabType.completed
        ? 'Đặt lại'
        : 'Hủy';
    final secondButtonText = tabType == _AppointmentTabType.completed
        ? 'Viết đánh giá'
        : 'Đổi lịch';

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
            _formatAppointmentDateTime(booking.dateTime),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2A37),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 12),
          _DoctorInfo(booking: booking),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  text: firstButtonText,
                  isPrimary: false,
                  onTap: tabType == _AppointmentTabType.upcoming
                      ? () => onCancelTap(booking)
                      : () => onRebookTap(booking),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ActionButton(
                  text: secondButtonText,
                  isPrimary: true,
                  onTap: tabType == _AppointmentTabType.completed
                      ? () => onWriteReviewTap(booking)
                      : () => onRescheduleTap(booking),
                ),
              ),
            ],
          ),
          if (tabType == _AppointmentTabType.upcoming) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => onCompleteTap(booking),
                child: const Text('Đánh dấu đã khám'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DoctorInfo extends StatelessWidget {
  const _DoctorInfo({required this.booking});

  final AppointmentBooking booking;

  @override
  Widget build(BuildContext context) {
    return Row(
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
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: Color(0xFF4B5563),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      booking.hospital,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4B5563),
                      ),
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
    );
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
    required this.selectedDay,
    required this.month,
    required this.year,
    this.useTopMargin = true,
  });

  final int selectedDay;
  final int month;
  final int year;
  final bool useTopMargin;

  @override
  Widget build(BuildContext context) {
    final dayCount = DateUtils.getDaysInMonth(year, month);
    final days = List<int>.generate(35, (i) => i + 1);
    return Container(
      margin: useTopMargin ? const EdgeInsets.only(top: 10) : EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tháng $month $year',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
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
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final d = days[index];
              final visibleDay = d <= dayCount ? d : d - dayCount;
              final selected = visibleDay == selectedDay && d <= dayCount;
              final faded = d > dayCount;
              return Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF1C2A3A)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$visibleDay',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? Colors.white
                        : (faded
                              ? const Color(0xFFD1D5DB)
                              : const Color(0xFF6B7280)),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

String _formatAppointmentDateTime(DateTime dateTime) {
  final isPm = dateTime.hour >= 12;
  var hour = dateTime.hour % 12;
  if (hour == 0) {
    hour = 12;
  }
  final hh = hour.toString().padLeft(2, '0');
  final mm = dateTime.minute.toString().padLeft(2, '0');
  return '$hh:$mm ${isPm ? 'PM' : 'AM'} • ${dateTime.day} tháng ${dateTime.month}, ${dateTime.year}';
}
