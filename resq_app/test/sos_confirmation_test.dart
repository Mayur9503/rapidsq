import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resq_app/screens/sos_confirmation_screen.dart';
import 'package:resq_app/screens/sos_searching_screen.dart';
import 'package:resq_app/state/app_state_controller.dart';
import 'package:resq_app/navigation/app_routes.dart';

void main() {
  testWidgets('Timer expiry in SosConfirmationScreen automatically sends SOS', (tester) async {
    final controller = AppStateController();

    await tester.pumpWidget(
      MaterialApp(
        routes: {
          AppRoutes.sosConfirmation: (context) => SosConfirmationScreen(controller: controller),
          AppRoutes.sosSearching: (context) => SosSearchingScreen(controller: controller),
          AppRoutes.ambulanceAssigned: (context) => const Scaffold(body: Text('Assigned')),
        },
        initialRoute: AppRoutes.sosConfirmation,
      ),
    );

    expect(find.byType(SosConfirmationScreen), findsOneWidget);
    expect(find.text('Auto-Dispatching Ambulance'), findsOneWidget);

    // Trigger SOS countdown
    controller.triggerSOS();
    await tester.pump();

    // Fast-forward 5 seconds
    for (int i = 0; i < 6; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Must have automatically navigated to searching screen
    expect(find.byType(SosSearchingScreen), findsOneWidget);
    expect(find.text('Finding nearest ambulance...'), findsOneWidget);

    // Let the 3.5s auto-assign timer complete cleanly
    await tester.pump(const Duration(seconds: 4));
  });
}
