import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../navigation/app_routes.dart';
import '../state/app_state_controller.dart';
import '../state/app_mode.dart';

class OnboardingScreen extends StatefulWidget {
  final AppStateController? controller;

  const OnboardingScreen({super.key, this.controller});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingItem> _pages = const [
    _OnboardingItem(
      icon: Icons.emergency,
      title: "One-Touch Ambulance SOS",
      description:
          "Press and hold the tactical SOS trigger to immediately mobilize the closest Advanced Life Support ambulance unit.",
      tag: "PRIORITY 1 DISPATCH",
    ),
    _OnboardingItem(
      icon: Icons.route,
      title: "Live Emergency Telemetry",
      description:
          "Follow your responder vehicle on a high-precision live route map with real-time ETA, distance metrics, and hospital triage sync.",
      tag: "REAL-TIME GPS",
    ),
    _OnboardingItem(
      icon: Icons.volunteer_activism,
      title: "Good Samaritan Bystander Mode",
      description:
          "Summon emergency trauma units for injured strangers or accident scenes with a fast 15-second triage voice note. No login required.",
      tag: "COMMUNITY RESCUE",
    ),
  ];

  void _finishOnboarding() {
    if (widget.controller?.appMode == AppMode.firebase) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.auth);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.mainScaffold);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _finishOnboarding,
            child: const Text(
              'SKIP',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.secondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemBuilder: (context, index) {
                  final item = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.icon,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            item.tag,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.description,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.secondary,
                            height: 1.45,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Pagination Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                final isSelected = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isSelected ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),

            // Bottom Action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage < _pages.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _finishOnboarding();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                ),
                child: Text(_currentPage == _pages.length - 1 ? "ENTER EMERGENCY DESK" : "CONTINUE"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingItem {
  final IconData icon;
  final String title;
  final String description;
  final String tag;

  const _OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.tag,
  });
}
