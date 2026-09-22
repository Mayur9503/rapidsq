import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../state/app_state_controller.dart';
import '../state/emergency_enums.dart';
import '../state/app_mode.dart';
import '../navigation/app_routes.dart';

class DevControlBar extends StatefulWidget {
  final AppStateController controller;

  const DevControlBar({
    super.key,
    required this.controller,
  });

  @override
  State<DevControlBar> createState() => _DevControlBarState();
}

class _DevControlBarState extends State<DevControlBar> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.inverseSurface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Bar
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getStateColor(state),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'DEV SIMULATION: ${state.name.toUpperCase()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_more : Icons.tune,
                    color: Colors.white70,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          if (_expanded) ...[
            const Divider(color: Colors.white24, height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'APP RUNTIME MODE',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text('MOCK', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                            selected: widget.controller.appMode == AppMode.mock,
                            onSelected: (_) => widget.controller.setAppMode(AppMode.mock),
                            selectedColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          const SizedBox(width: 4),
                          ChoiceChip(
                            label: const Text('FIREBASE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                            selected: widget.controller.appMode == AppMode.firebase,
                            onSelected: (_) => widget.controller.setAppMode(AppMode.firebase),
                            selectedColor: AppColors.tertiary,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'STATE OVERRIDE CONTROLS',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildStateChip(EmergencyState.idle, 'IDLE'),
                      _buildStateChip(EmergencyState.searching, 'SEARCHING'),
                      _buildStateChip(EmergencyState.ambulanceAssigned, 'ASSIGNED'),
                      _buildStateChip(EmergencyState.enRoute, 'EN_ROUTE'),
                      _buildStateChip(EmergencyState.arriving, 'ARRIVING'),
                      _buildStateChip(EmergencyState.arrived, 'ARRIVED'),
                      _buildStateChip(EmergencyState.completed, 'COMPLETED'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'SIMULATE ERROR STATES',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildErrorChip(ErrorStateType.noAmbulanceAvailable, 'NO AMBULANCE'),
                      _buildErrorChip(ErrorStateType.networkUnavailable, 'OFFLINE / NET'),
                      _buildErrorChip(ErrorStateType.locationPermissionDenied, 'NO GPS PERM'),
                      _buildErrorChip(ErrorStateType.requestCancelled, 'CANCELLED'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          setState(() => _expanded = false);
                          Navigator.of(context).pushNamed(AppRoutes.driver);
                        },
                        icon: const Icon(Icons.airport_shuttle, size: 14, color: AppColors.tertiary),
                        label: const Text(
                          'DRIVER TERMINAL',
                          style: TextStyle(
                            color: AppColors.tertiary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          widget.controller.resetToIdle();
                          setState(() => _expanded = false);
                        },
                        icon: const Icon(Icons.restart_alt, size: 14, color: AppColors.primaryFixed),
                        label: const Text(
                          'RESET TO HOME',
                          style: TextStyle(
                            color: AppColors.primaryFixed,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStateChip(EmergencyState target, String label) {
    final isSelected = widget.controller.state == target;
    return InkWell(
      onTap: () {
        widget.controller.transitionTo(target);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white12,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white24,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorChip(ErrorStateType type, String label) {
    return InkWell(
      onTap: () {
        widget.controller.triggerError(type);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.error, width: 1),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Color _getStateColor(EmergencyState s) {
    switch (s) {
      case EmergencyState.idle:
        return Colors.blue;
      case EmergencyState.sosCountdown:
      case EmergencyState.searching:
        return AppColors.amber;
      case EmergencyState.ambulanceAssigned:
      case EmergencyState.enRoute:
      case EmergencyState.arriving:
      case EmergencyState.arrived:
      case EmergencyState.completed:
        return AppColors.tertiary;
      case EmergencyState.errorState:
      case EmergencyState.cancelled:
        return AppColors.error;
    }
  }
}
