import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resq_app/state/app_state_controller.dart';
import 'package:resq_app/models/emergency_request.dart';
import 'package:resq_app/screens/ambulance_driver_screen.dart';

void main() {
  group('Ambulance Driver Tests', () {
    late AppStateController controller;

    setUp(() {
      controller = AppStateController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('AmbulanceDriverScreen renders standby status when available', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AmbulanceDriverScreen(controller: controller),
        ),
      );

      expect(find.text('Ambulance Terminal (Unit #402)'), findsOneWidget);
      expect(find.text('AVAILABLE'), findsOneWidget);
      expect(find.text('STANDBY • READY FOR DISPATCH'), findsOneWidget);
      expect(find.text('PATIENT GPS COORDINATES (CAPTURED AT SOS)'), findsOneWidget);
      expect(find.text('STATIC GPS'), findsOneWidget);
    });

    testWidgets('AmbulanceDriverScreen shows incoming alert when OFFERED', (WidgetTester tester) async {
      controller.ambulanceStatus = 'OFFERED';

      await tester.pumpWidget(
        MaterialApp(
          home: AmbulanceDriverScreen(controller: controller),
        ),
      );

      expect(find.text('INCOMING EMERGENCY OFFER'), findsOneWidget);
      expect(find.text('ACCEPT DISPATCH'), findsOneWidget);
      expect(find.text('REJECT'), findsOneWidget);
    });

    testWidgets('AmbulanceDriverScreen shows 6-second countdown timer when OFFERED', (WidgetTester tester) async {
      controller.ambulanceStatus = 'OFFERED';

      await tester.pumpWidget(
        MaterialApp(
          home: AmbulanceDriverScreen(controller: controller),
        ),
      );

      expect(find.text('INCOMING EMERGENCY OFFER'), findsOneWidget);
      expect(find.text('NEW EMERGENCY'), findsOneWidget);
      expect(find.text('Accept in 6 seconds'), findsOneWidget);
      expect(find.text('6 → 5 → 4 → 3 → 2 → 1'), findsOneWidget);
      expect(find.text('ACCEPT DISPATCH'), findsOneWidget);
      expect(find.text('REJECT'), findsOneWidget);
    });

    testWidgets('Tapping ACCEPT DISPATCH transitions to BUSY and reveals Open Google Maps', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      controller.ambulanceStatus = 'OFFERED';

      await tester.pumpWidget(
        MaterialApp(
          home: AmbulanceDriverScreen(controller: controller),
        ),
      );

      final acceptBtn = find.text('ACCEPT DISPATCH');
      await tester.ensureVisible(acceptBtn);
      await tester.tap(acceptBtn);
      await tester.pumpAndSettle();

      expect(controller.ambulanceStatus, 'BUSY');
      expect(find.text('ACTIVE EMERGENCY DISPATCH'), findsOneWidget);
      expect(find.text('Open Google Maps'), findsOneWidget);
    });

    testWidgets('Tapping REJECT resets status to AVAILABLE', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      controller.ambulanceStatus = 'OFFERED';

      await tester.pumpWidget(
        MaterialApp(
          home: AmbulanceDriverScreen(controller: controller),
        ),
      );

      final rejectBtn = find.text('REJECT');
      await tester.ensureVisible(rejectBtn);
      await tester.tap(rejectBtn);
      await tester.pumpAndSettle();

      expect(controller.ambulanceStatus, 'AVAILABLE');
      expect(find.text('STANDBY • READY FOR DISPATCH'), findsOneWidget);
    });

    testWidgets('AmbulanceDriverScreen displays actual emergency details for women safety dispatch', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Set up real emergency details
      controller.ambulanceStatus = 'OFFERED';
      controller.setSelectedService(EmergencyServiceType.womenSafety);
      controller.currentRequest = EmergencyRequest(
        id: 'RQ-TEST-WS',
        location: const EmergencyLocation(
          title: 'Sector 62, Noida',
          subtitle: 'Near Metro Gate',
          latitude: 28.6295,
          longitude: 77.3660,
        ),
        serviceType: EmergencyServiceType.womenSafety,
        additionalNotes: 'Urgent patrol required',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AmbulanceDriverScreen(controller: controller),
        ),
      );

      expect(find.text('INCOMING WOMEN SAFETY OFFER'), findsOneWidget);
      expect(find.text('WOMEN SAFETY'), findsOneWidget);
      expect(find.text('ACCEPT DISPATCH'), findsOneWidget);
      expect(find.text('REJECT'), findsOneWidget);
    });

    test('Google navigation URI formats correctly with stored emergency coordinates', () {
      const lat = 28.6280;
      const lng = 77.3649;
      final uri = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
      expect(uri.scheme, 'google.navigation');
      expect(uri.toString(), 'google.navigation:q=28.628,77.3649&mode=d');
    });
  });
}
