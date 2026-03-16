import 'package:flutter_test/flutter_test.dart';

import 'package:doctor_appointment_app/main.dart';

void main() {
  testWidgets('App shows splash branding', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('AnKhang'), findsOneWidget);
    expect(find.text('Doctor Appointment'), findsOneWidget);
  });
}
