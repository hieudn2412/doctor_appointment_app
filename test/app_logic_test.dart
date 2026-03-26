import 'package:doctor_appointment_app/data/implementations/local/database_helper.dart';
import 'package:doctor_appointment_app/data/implementations/local/session_manager.dart';
import 'package:doctor_appointment_app/services/email_js_service.dart';
import 'package:doctor_appointment_app/viewmodels/login/auth_viewmodel.dart';
import 'package:doctor_appointment_app/views/appointment/data/appointment_booking_store.dart';
import 'package:doctor_appointment_app/views/home/models/doctor_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _FakeEmailOtpService implements EmailOtpService {
  String? lastEmail;
  String? lastOtp;
  bool shouldFail = false;

  @override
  Future<void> sendResetOtp({
    required String toEmail,
    required String otpCode,
    required DateTime expiresAt,
  }) async {
    if (shouldFail) {
      throw Exception('Email provider failed');
    }
    lastEmail = toEmail;
    lastOtp = otpCode;
  }
}

Future<void> _resetDatabase() async {
  await DatabaseHelper.instance.close();
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'doctor_appointment.db');
  await databaseFactory.deleteDatabase(path);
}

void main() {
  final fakeEmailService = _FakeEmailOtpService();
  final auth = AuthViewModel();

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await _resetDatabase();
    AppointmentBookingStore.instance.clearCache();
    await SessionManager.instance.clearSession();
    auth.setEmailOtpServiceForTesting(fakeEmailService);
    fakeEmailService.lastEmail = null;
    fakeEmailService.lastOtp = null;
    fakeEmailService.shouldFail = false;

    // Khởi tạo DB mới + seed.
    await DatabaseHelper.instance.database;
  });

  test('login and restore session by current_user_id', () async {
    final ok = await auth.signIn(email: 'test@gmail.com', password: '123456');
    expect(ok, isTrue);
    expect(SessionManager.instance.currentUser?.email, 'test@gmail.com');

    final restored = await SessionManager.instance.restoreSession();
    expect(restored, isTrue);
    expect(SessionManager.instance.currentUser?.id, isNotNull);
  });

  test('appointments are scoped by current user', () async {
    final loginUser1 = await auth.signIn(email: 'test@gmail.com', password: '123456');
    expect(loginUser1, isTrue);
    final store = AppointmentBookingStore.instance;

    final doctor = DoctorItem(
      id: 'd1',
      name: 'Doctor A',
      specialty: 'Tim mach',
      hospitalName: 'Hospital A',
      rating: 4.8,
      reviewCount: 10,
      imageAssetPath: 'assets/images/doctor.png',
    );
    await store.addBooking(doctor: doctor, dateTime: DateTime(2026, 4, 1, 9, 0));
    expect(store.upcomingBookings.length, 1);

    await auth.logout();

    final signupUser2 = await auth.signUp(
      name: 'User 2',
      email: 'user2@gmail.com',
      password: '123456',
    );
    expect(signupUser2, isTrue);
    await store.refreshForCurrentUser();
    expect(store.upcomingBookings, isEmpty);

    await auth.logout();
    final loginAgainUser1 =
        await auth.signIn(email: 'test@gmail.com', password: '123456');
    expect(loginAgainUser1, isTrue);
    await store.refreshForCurrentUser();
    expect(store.upcomingBookings.length, 1);
  });

  test('my review is scoped by user + doctor and upsert works', () async {
    expect(await auth.signIn(email: 'test@gmail.com', password: '123456'), isTrue);
    final store = AppointmentBookingStore.instance;
    await store.addReview(doctorId: 'd1', rating: 5, content: 'review_user1');
    await store.addReview(doctorId: 'd1', rating: 4, content: 'review_user1_updated');

    await auth.logout();

    expect(
      await auth.signUp(name: 'User 2', email: 'user2@gmail.com', password: '123456'),
      isTrue,
    );
    await store.addReview(doctorId: 'd1', rating: 3, content: 'review_user2');

    await auth.logout();
    expect(await auth.signIn(email: 'test@gmail.com', password: '123456'), isTrue);

    final myReview = await store.getMyReviewForDoctor('d1');
    expect(myReview, isNotNull);
    expect(myReview!.content, 'review_user1_updated');

    final allReviews = await store.getReviewsForDoctor('d1');
    expect(allReviews.length, 2);
  });

  test('OTP verify then reset password', () async {
    final sent = await auth.sendResetCode(email: 'test@gmail.com');
    expect(sent, isTrue);
    expect(fakeEmailService.lastOtp, isNotNull);

    final verified = await auth.verifyOtp(
      email: 'test@gmail.com',
      otp: fakeEmailService.lastOtp!,
    );
    expect(verified, isTrue);

    final reset = await auth.resetPassword(
      email: 'test@gmail.com',
      password: 'newpass123',
      confirmPassword: 'newpass123',
    );
    expect(reset, isTrue);

    final oldLogin = await auth.signIn(email: 'test@gmail.com', password: '123456');
    expect(oldLogin, isFalse);

    final newLogin =
        await auth.signIn(email: 'test@gmail.com', password: 'newpass123');
    expect(newLogin, isTrue);
  });

  test('admin account login routes by role', () async {
    final ok = await auth.signIn(email: 'admin@gmail.com', password: 'admin123');
    expect(ok, isTrue);
    expect(auth.currentUser?.role, 'admin');
    expect(auth.isCurrentUserAdmin, isTrue);
  });
}
