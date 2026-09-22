import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resq_app/main.dart';
import 'package:resq_app/screens/home_screen.dart';
import 'package:resq_app/widgets/tactile_sos_button.dart';

void main() {
  testWidgets('Full Emergency Dispatch Flow Test', (WidgetTester tester) async {
    // Smartphone viewport
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const ResQEmergencyApp());

    // 1. Splash Screen
    expect(find.text('ResQ'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pump(const Duration(milliseconds: 500));

    // 2. Onboarding Screen
    expect(find.text('SKIP'), findsOneWidget);
    await tester.tap(find.text('SKIP'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // 3. Home Screen
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Hi, Aarav Sharma'), findsOneWidget);
    expect(find.text('Sector 62, Noida, UP'), findsOneWidget);
    expect(find.text('SOS'), findsOneWidget);
    expect(find.byType(TactileSosButton), findsOneWidget);

    // 4. Help Someone Else Screen Navigation
    final helpBtn = find.text('Request Help for Someone Else');
    await tester.ensureVisible(helpBtn);
    await tester.pump(const Duration(milliseconds: 300));
    expect(helpBtn, findsOneWidget);
    await tester.tap(helpBtn);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Triage Details'), findsOneWidget);
    final reqBtn = find.text('REQUEST AMBULANCE FOR PATIENT');
    await tester.ensureVisible(reqBtn);
    await tester.pump(const Duration(milliseconds: 200));
    expect(reqBtn, findsOneWidget);

    // 5. Submit triage for patient
    await tester.tap(reqBtn);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // 6. Searching Screen
    expect(find.text('Finding nearest ambulance...'), findsOneWidget);
    final forceBtn = find.text('FORCE AMBULANCE ASSIGNMENT');
    await tester.ensureVisible(forceBtn);
    await tester.pump(const Duration(milliseconds: 200));
    expect(forceBtn, findsOneWidget);

    // 7. Force ambulance assignment
    await tester.tap(forceBtn);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // 8. Ambulance Assigned Screen
    expect(find.text('Rahul Patil'), findsOneWidget);
    expect(find.text('MH 12 AB 4521'), findsOneWidget);
    final trackBtn = find.text('OPEN LIVE GPS TRACKING');
    await tester.ensureVisible(trackBtn);
    await tester.pump(const Duration(milliseconds: 200));
    expect(trackBtn, findsOneWidget);

    // 9. Open Live Tracking
    await tester.tap(trackBtn);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // 10. Live Tracking Screen
    expect(find.text('Live Tracking'), findsOneWidget);
    final adv1 = find.text('ADVANCE STATUS (Arriving)');
    await tester.ensureVisible(adv1);
    await tester.pump(const Duration(milliseconds: 200));
    expect(adv1, findsOneWidget);

    // 11. Advance to Arriving
    await tester.tap(adv1);
    await tester.pump(const Duration(milliseconds: 400));
    final adv2 = find.text('ADVANCE STATUS (Arrived)');
    await tester.ensureVisible(adv2);
    await tester.pump(const Duration(milliseconds: 200));
    expect(adv2, findsOneWidget);

    // 12. Advance to Arrived
    await tester.tap(adv2);
    await tester.pump(const Duration(milliseconds: 400));
    final compBtn = find.text('COMPLETE EMERGENCY');
    await tester.ensureVisible(compBtn);
    await tester.pump(const Duration(milliseconds: 200));
    expect(compBtn, findsOneWidget);

    // 13. Complete Emergency
    await tester.tap(compBtn);
    await tester.pump(const Duration(milliseconds: 400));
    final homeBtn = find.text('RETURN TO HOME');
    await tester.ensureVisible(homeBtn);
    await tester.pump(const Duration(milliseconds: 200));
    expect(homeBtn, findsOneWidget);

    // 14. Return to Home
    await tester.tap(homeBtn);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // Back at Home
    expect(find.text('Hi, Aarav Sharma'), findsOneWidget);

    // 15. Bottom Navigation to Activity
    await tester.tap(find.text('Activity'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Emergency Activity Log'), findsOneWidget);

    // 16. Bottom Navigation to Profile
    await tester.tap(find.text('Profile'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('My Profile'), findsOneWidget);
  });
}

