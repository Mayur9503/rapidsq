import 'package:flutter_test/flutter_test.dart';
import 'package:resq_app/main.dart';

void main() {
  testWidgets('ResQ app boots and renders splash and transitions', (WidgetTester tester) async {
    await tester.pumpWidget(const ResQEmergencyApp());
    expect(find.text('ResQ'), findsOneWidget);
    expect(find.text('CIVIC OPERATIONAL DISPATCH'), findsOneWidget);

    // Fast-forward past the splash timer
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();

    // Verify Onboarding screen is loaded
    expect(find.text('One-Touch Ambulance SOS'), findsOneWidget);
  });
}
