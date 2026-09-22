import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'state/app_state_controller.dart';
import 'navigation/app_routes.dart';
import 'navigation/main_scaffold.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/sos_confirmation_screen.dart';
import 'screens/sos_searching_screen.dart';
import 'screens/ambulance_assigned_screen.dart';
import 'screens/live_tracking_screen.dart';
import 'screens/voice_message_screen.dart';
import 'screens/help_someone_else_screen.dart';
import 'screens/bystander_emergency_screen.dart';
import 'screens/emergency_profile_screen.dart';
import 'screens/activity_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/privacy_security_screen.dart';
import 'screens/ambulance_driver_screen.dart';
import 'screens/role_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  runApp(const ResQEmergencyApp());
}

class ResQEmergencyApp extends StatefulWidget {
  const ResQEmergencyApp({super.key});

  @override
  State<ResQEmergencyApp> createState() => _ResQEmergencyAppState();
}

class _ResQEmergencyAppState extends State<ResQEmergencyApp> {
  final AppStateController _controller = AppStateController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return MaterialApp(
          title: 'ResQ Emergency Dispatch',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          initialRoute: AppRoutes.splash,
          routes: {
            AppRoutes.splash: (context) => SplashScreen(controller: _controller),
            AppRoutes.onboarding: (context) => OnboardingScreen(controller: _controller),
            AppRoutes.mainScaffold: (context) => MainScaffold(controller: _controller),
            AppRoutes.home: (context) => HomeScreen(controller: _controller),
            AppRoutes.sosConfirmation: (context) => SosConfirmationScreen(controller: _controller),
            AppRoutes.sosSearching: (context) => SosSearchingScreen(controller: _controller),
            AppRoutes.ambulanceAssigned: (context) => AmbulanceAssignedScreen(controller: _controller),
            AppRoutes.liveTracking: (context) => LiveTrackingScreen(controller: _controller),
            AppRoutes.voiceMessage: (context) => const VoiceMessageScreen(),
            AppRoutes.helpSomeoneElse: (context) => HelpSomeoneElseScreen(controller: _controller),
            AppRoutes.bystanderEmergency: (context) => BystanderEmergencyScreen(controller: _controller),
            AppRoutes.emergencyProfile: (context) => EmergencyProfileScreen(controller: _controller),
            AppRoutes.activity: (context) => ActivityScreen(controller: _controller),
            AppRoutes.profile: (context) => ProfileScreen(controller: _controller),
            AppRoutes.settings: (context) => SettingsScreen(controller: _controller),
            AppRoutes.privacySecurity: (context) => PrivacySecurityScreen(controller: _controller),
            AppRoutes.auth: (context) => AuthScreen(controller: _controller),
            AppRoutes.roleSelection: (context) => RoleSelectionScreen(controller: _controller),
            AppRoutes.driver: (context) => AmbulanceDriverScreen(controller: _controller),
          },
        );
      },
    );
  }
}
