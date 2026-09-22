import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resq_app/state/app_state_controller.dart';
import 'package:resq_app/state/app_mode.dart';
import 'package:resq_app/screens/auth_screen.dart';
import 'package:resq_app/models/medical_profile.dart';

void main() {
  group('Firebase Services & AppMode Unit Tests', () {
    test('AppStateController supports dual mode switching', () {
      final controller = AppStateController();
      expect(controller.appMode, AppMode.mock);

      controller.setAppMode(AppMode.firebase);
      expect(controller.appMode, AppMode.firebase);

      controller.setAppMode(AppMode.mock);
      expect(controller.appMode, AppMode.mock);
    });

    test('Medical profile update propagates in controller', () async {
      final controller = AppStateController();
      final currentProfile = controller.medicalProfile;

      final updatedProfile = MedicalProfile(
        fullName: 'Dr. Test Responder',
        age: 32,
        gender: 'Female',
        bloodGroup: 'B+',
        allergies: 'None reported',
        medicalConditions: 'None',
        currentMedications: 'None',
        contacts: currentProfile.contacts,
        documents: currentProfile.documents,
      );

      await controller.saveMedicalProfile(updatedProfile);
      expect(controller.medicalProfile.fullName, 'Dr. Test Responder');
      expect(controller.medicalProfile.bloodGroup, 'B+');
    });

    testWidgets('AuthScreen renders login form and toggles to registration', (tester) async {
      final controller = AppStateController();

      await tester.pumpWidget(
        MaterialApp(
          home: AuthScreen(controller: controller),
        ),
      );

      // Verify Login Screen Elements
      expect(find.text('Civic Account Login'), findsOneWidget);
      expect(find.text('SIGN IN SECURELY'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      // Tap Toggle to Register
      await tester.tap(find.text('New to ResQ? Create an account'));
      await tester.pumpAndSettle();

      // Verify Register Screen Elements
      expect(find.text('Register Civic Profile'), findsOneWidget);
      expect(find.text('CREATE ACCOUNT & VERIFY'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Emergency Mobile Number'), findsOneWidget);

      // Validation check
      await tester.tap(find.text('CREATE ACCOUNT & VERIFY'));
      await tester.pump();
      expect(find.text('Please enter your full name'), findsOneWidget);
    });
  });
}
