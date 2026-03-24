import 'package:flutter/material.dart';
import 'package:doctor_appointment_app/views/appointment/manage_appointments_screen.dart';
import 'package:doctor_appointment_app/views/home/all_facilities_screen.dart';
import 'package:doctor_appointment_app/views/home/doctor_list_screen.dart';
import 'package:doctor_appointment_app/views/home/notification_screen.dart';
import 'package:doctor_appointment_app/views/profile/profile_screen.dart';
import 'package:doctor_appointment_app/views/home/widgets/home_bottom_menu_bar.dart';
import 'package:doctor_appointment_app/views/home/widgets/home_content.dart';
import 'package:doctor_appointment_app/views/home/widgets/home_status_row.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: HomeContent(
                onSeeAllTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AllFacilitiesScreen(),
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
                onNotificationTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const NotificationScreen(),
                    ),
                  );
                },
              ),
            ),
            HomeBottomMenuBar(
              selectedTab: HomeMenuTab.home,
              onSearchTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const DoctorListScreen(),
                  ),
                );
              },
              onCalendarTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ManageAppointmentsScreen(),
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
}
