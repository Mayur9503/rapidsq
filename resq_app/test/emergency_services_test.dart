import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resq_app/models/emergency_request.dart';
import 'package:resq_app/state/app_state_controller.dart';
import 'package:resq_app/state/emergency_enums.dart';
import 'package:resq_app/screens/home_screen.dart';
import 'package:resq_app/screens/ambulance_assigned_screen.dart';
import 'package:resq_app/screens/ambulance_driver_screen.dart';

void main() {
  group('Emergency Services Tests (Ambulance, Women Safety, Fire Brigade)', () {
    late AppStateController controller;

    setUp(() {
      controller = AppStateController();
    });

    tearDown(() {
      controller.cancelSOSCountdown();
      controller.dispose();
    });

    test('Default service is ambulance and can be switched', () {
      expect(controller.selectedService, EmergencyServiceType.ambulance);
      expect(controller.selectedService.key, 'ambulance');

      controller.setSelectedService(EmergencyServiceType.womenSafety);
      expect(controller.selectedService, EmergencyServiceType.womenSafety);
      expect(controller.selectedService.key, 'women_safety');

      controller.setSelectedService(EmergencyServiceType.fireBrigade);
      expect(controller.selectedService, EmergencyServiceType.fireBrigade);
      expect(controller.selectedService.key, 'fire_brigade');
    });

    test('triggerWomenSafetyEmergency populates emergency request correctly', () async {
      await controller.triggerWomenSafetyEmergency(message: 'Suspicious individual following');

      expect(controller.state, EmergencyState.searching);
      expect(controller.selectedService, EmergencyServiceType.womenSafety);
      expect(controller.currentRequest, isNotNull);
      expect(controller.currentRequest!.serviceType, EmergencyServiceType.womenSafety);
      expect(controller.currentRequest!.priority, 'CRITICAL');
      expect(controller.currentRequest!.additionalNotes, contains('Suspicious individual'));
    });

    test('triggerFireBrigadeEmergency populates fire subtype correctly', () async {
      await controller.triggerFireBrigadeEmergency(fireType: 'Building fire', notes: 'Level 2 smoke');

      expect(controller.state, EmergencyState.searching);
      expect(controller.selectedService, EmergencyServiceType.fireBrigade);
      expect(controller.currentRequest, isNotNull);
      expect(controller.currentRequest!.serviceType, EmergencyServiceType.fireBrigade);
      expect(controller.currentRequest!.priority, 'HIGH');
      expect(controller.currentRequest!.additionalNotes, contains('Building fire'));
      expect(controller.currentRequest!.additionalNotes, contains('Level 2 smoke'));
    });

    testWidgets('HomeScreen displays all 3 emergency service selectors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(controller: controller),
        ),
      );
      await tester.pump();

      expect(find.text('Ambulance'), findsWidgets);
      expect(find.text('Women Safety'), findsOneWidget);
      expect(find.text('Fire Brigade'), findsOneWidget);
      expect(find.text('Medical SOS'), findsOneWidget);
      expect(find.text('Danger SOS'), findsOneWidget);
      expect(find.text('Fire & Rescue'), findsOneWidget);
    });

    testWidgets('Switching to Women Safety shows 1-Tap SOS UI', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(controller: controller),
        ),
      );
      await tester.pump();

      // Tap on Women Safety tab
      await tester.tap(find.text('Women Safety'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('WOMEN SAFETY DISPATCH'), findsOneWidget);
      expect(find.text('ONE-TAP WOMEN SAFETY SOS'), findsOneWidget);
      expect(find.text('+ Add short distress voice/text note'), findsOneWidget);
    });

    testWidgets('Switching to Fire Brigade shows fire category choices', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(controller: controller),
        ),
      );
      await tester.pump();

      // Tap on Fire Brigade tab
      await tester.tap(find.text('Fire Brigade'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('FIRE BRIGADE & RESCUE SQUAD'), findsOneWidget);
      expect(find.text('Building fire'), findsOneWidget);
      expect(find.text('Vehicle fire'), findsOneWidget);
      expect(find.text('Industrial fire'), findsOneWidget);
      expect(find.text('DISPATCH FIRE BRIGADE NOW'), findsOneWidget);
    });

    testWidgets('AmbulanceAssignedScreen renders dynamic Women Safety response', (WidgetTester tester) async {
      controller.setSelectedService(EmergencyServiceType.womenSafety);

      await tester.pumpWidget(
        MaterialApp(
          home: AmbulanceAssignedScreen(controller: controller),
        ),
      );
      await tester.pump();

      expect(find.text('Safety Response Assigned'), findsOneWidget);
      expect(find.text('SAFETY PATROL DISPATCH CONFIRMED'), findsOneWidget);
      expect(find.text('QUICK RESPONSE PATROL (QRT)'), findsOneWidget);
      expect(find.text('PATROL-108'), findsOneWidget);
      expect(find.text('Officer R. Verma (QRT)'), findsOneWidget);
    });

    testWidgets('AmbulanceAssignedScreen renders dynamic Fire Brigade response', (WidgetTester tester) async {
      controller.setSelectedService(EmergencyServiceType.fireBrigade);

      await tester.pumpWidget(
        MaterialApp(
          home: AmbulanceAssignedScreen(controller: controller),
        ),
      );
      await tester.pump();

      expect(find.text('Fire Brigade Assigned'), findsOneWidget);
      expect(find.text('FIRE BRIGADE DISPATCH CONFIRMED'), findsOneWidget);
      expect(find.text('FIRE ENGINE & RESCUE SQUAD'), findsOneWidget);
      expect(find.text('FIRE-05'), findsOneWidget);
      expect(find.text('Commander S. Negi'), findsOneWidget);
    });

    testWidgets('Responder terminal displays incoming Women Safety badge and offer', (WidgetTester tester) async {
      controller.setSelectedService(EmergencyServiceType.womenSafety);
      controller.ambulanceStatus = 'OFFERED';

      await tester.pumpWidget(
        MaterialApp(
          home: AmbulanceDriverScreen(controller: controller),
        ),
      );
      await tester.pump();

      expect(find.text('INCOMING WOMEN SAFETY OFFER'), findsOneWidget);
      expect(find.text('WOMEN SAFETY'), findsOneWidget);
      expect(find.text('ACCEPT DISPATCH'), findsOneWidget);
    });
  });
}
