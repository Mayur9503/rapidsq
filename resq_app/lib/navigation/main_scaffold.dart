import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../state/app_state_controller.dart';
import '../state/emergency_enums.dart';
import '../screens/home_screen.dart';
import '../screens/activity_screen.dart';
import '../screens/profile_screen.dart';
import '../widgets/error_state_sheet.dart';

class MainScaffold extends StatefulWidget {
  final AppStateController controller;

  const MainScaffold({
    super.key,
    required this.controller,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleStateChange);
  }

  void _handleStateChange() {
    if (widget.controller.state == EmergencyState.errorState && widget.controller.errorType != null) {
      final err = widget.controller.errorType!;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => ErrorStateSheet(
          errorType: err,
          onRetry: () {
            Navigator.pop(ctx);
            widget.controller.resetToIdle();
          },
          onDismiss: () {
            Navigator.pop(ctx);
            widget.controller.resetToIdle();
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleStateChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(controller: widget.controller),
      ActivityScreen(controller: widget.controller),
      ProfileScreen(controller: widget.controller),
    ];

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          border: Border(top: BorderSide(color: AppColors.borderLight, width: 1)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.health_and_safety, 'Home'),
                _buildNavItem(1, Icons.history, 'Activity', badgeCount: 1),
                _buildNavItem(2, Icons.badge_outlined, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, {int badgeCount = 0}) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected ? AppColors.primary : AppColors.secondary,
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -2,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
