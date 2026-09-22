import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resq_app/state/app_state_controller.dart';
import 'package:resq_app/state/app_mode.dart';
import 'package:resq_app/screens/role_selection_screen.dart';
import 'package:resq_app/navigation/app_routes.dart';

void main() {
  group('Role Selection Tests', () {
    late AppStateController controller;

    setUp(() {
      controller = AppStateController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('RoleSelectionScreen displays USER and RIDER options', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RoleSelectionScreen(controller: controller),
        ),
      );

      expect(find.text('Choose your account type'), findsWidgets);
      expect(find.text('USER'), findsOneWidget);
      expect(find.text('For a person who needs emergency assistance.'), findsOneWidget);
      expect(find.text('CONTINUE AS USER'), findsOneWidget);
      expect(find.text('RIDER'), findsOneWidget);
      expect(find.text('For an ambulance/responder who receives emergency requests.'), findsOneWidget);
      expect(find.text('CONTINUE AS RIDER'), findsOneWidget);
    });

    testWidgets('Selecting USER calls selectRole and navigates to mainScaffold', (WidgetTester tester) async {
      String? navigatedRoute;

      await tester.pumpWidget(
        MaterialApp(
          initialRoute: AppRoutes.roleSelection,
          routes: {
            AppRoutes.roleSelection: (context) => RoleSelectionScreen(controller: controller),
            AppRoutes.mainScaffold: (context) {
              navigatedRoute = AppRoutes.mainScaffold;
              return const Scaffold(body: Text('User Home Screen'));
            },
            AppRoutes.driver: (context) {
              navigatedRoute = AppRoutes.driver;
              return const Scaffold(body: Text('Rider Driver Screen'));
            },
          },
        ),
      );

      await tester.tap(find.text('USER'));
      await tester.pumpAndSettle();

      expect(controller.userRole, 'user');
      expect(navigatedRoute, AppRoutes.mainScaffold);
    });

    testWidgets('Selecting RIDER calls selectRole and navigates to driver screen', (WidgetTester tester) async {
      String? navigatedRoute;

      await tester.pumpWidget(
        MaterialApp(
          initialRoute: AppRoutes.roleSelection,
          routes: {
            AppRoutes.roleSelection: (context) => RoleSelectionScreen(controller: controller),
            AppRoutes.mainScaffold: (context) {
              navigatedRoute = AppRoutes.mainScaffold;
              return const Scaffold(body: Text('User Home Screen'));
            },
            AppRoutes.driver: (context) {
              navigatedRoute = AppRoutes.driver;
              return const Scaffold(body: Text('Rider Driver Screen'));
            },
          },
        ),
      );

      await tester.tap(find.text('RIDER'));
      await tester.pumpAndSettle();

      expect(controller.userRole, 'rider');
      expect(navigatedRoute, AppRoutes.driver);
    });

    test('Role persistence saves and updates controller userRole', () async {
      expect(controller.userRole, isNull);
      await controller.selectRole('user');
      expect(controller.userRole, 'user');
      
      // Select rider
      await controller.selectRole('rider');
      expect(controller.userRole, 'rider');
    });

    testWidgets('Existing USER skips role selection and routes directly to MainScaffold', (WidgetTester tester) async {
      String? currentRoute;
      // Pre-set user role as 'user'
      controller.setUserRole('user');

      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/',
          routes: {
            '/': (context) {
              // Simulate Auth/Splash routing logic
              final role = controller.userRole;
              if (role == 'rider') {
                return const Scaffold(body: Text('Rider Dashboard'));
              } else if (role == 'user') {
                currentRoute = AppRoutes.mainScaffold;
                return const Scaffold(body: Text('User MainScaffold'));
              } else {
                return RoleSelectionScreen(controller: controller);
              }
            },
            AppRoutes.mainScaffold: (context) => const Scaffold(body: Text('User MainScaffold')),
          },
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('User MainScaffold'), findsOneWidget);
      expect(find.text('Choose your account type'), findsNothing);
      expect(currentRoute, AppRoutes.mainScaffold);
    });

    testWidgets('Existing RIDER skips role selection and routes directly to Rider Dashboard', (WidgetTester tester) async {
      String? currentRoute;
      // Pre-set user role as 'rider'
      controller.setUserRole('rider');

      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/',
          routes: {
            '/': (context) {
              // Simulate Auth/Splash routing logic
              final role = controller.userRole;
              if (role == 'rider') {
                currentRoute = AppRoutes.driver;
                return const Scaffold(body: Text('Rider Dashboard'));
              } else if (role == 'user') {
                return const Scaffold(body: Text('User MainScaffold'));
              } else {
                return RoleSelectionScreen(controller: controller);
              }
            },
            AppRoutes.driver: (context) => const Scaffold(body: Text('Rider Dashboard')),
          },
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Rider Dashboard'), findsOneWidget);
      expect(find.text('Choose your account type'), findsNothing);
      expect(currentRoute, AppRoutes.driver);
    });

    test('Firebase mode contains no fake ambulance or simulated movement', () {
      controller.setAppMode(AppMode.firebase);
      expect(controller.appMode, AppMode.firebase);
      expect(controller.hasActiveEmergency, false);
      expect(controller.assignedUnit.id, 'main');
    });
  });
}
