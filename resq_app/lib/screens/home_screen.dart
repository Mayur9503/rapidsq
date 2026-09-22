import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../state/app_state_controller.dart';
import '../widgets/emergency_app_bar.dart';
import '../widgets/tactile_sos_button.dart';
import '../widgets/dev_control_bar.dart';
import '../navigation/app_routes.dart';

import '../models/emergency_request.dart';

class HomeScreen extends StatefulWidget {
  final AppStateController controller;

  const HomeScreen({
    super.key,
    required this.controller,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFireType = 'Building fire';
  final TextEditingController _safetyNoteController = TextEditingController();
  bool _showSafetyNoteField = false;

  @override
  void dispose() {
    _safetyNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final controller = widget.controller;
        final profile = controller.medicalProfile;
        final location = controller.userLocation;
        final selectedService = controller.selectedService;

        return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: EmergencyAppBar(
        title: "ResQ Emergency",
        onProfileTap: () {
          Navigator.of(context).pushNamed(AppRoutes.profile);
        },
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. User Status & Precision Location
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Hi, ${profile.fullName}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: AppColors.tertiary, size: 7),
                          SizedBox(width: 5),
                          Text(
                            'READY',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Live Location Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryFixed,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.pin_drop,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              location.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.tertiaryFixed,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'GPS ${location.accuracy}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.tertiary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    location.subtitle,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.secondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Calibrating live high-precision GPS...")),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.surfaceContainerLow,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                        child: const Text(
                          'Change',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Emergency Service Selection (Ambulance, Women Safety, Fire Brigade)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      _buildServiceTab(
                        type: EmergencyServiceType.ambulance,
                        icon: Icons.airport_shuttle,
                        label: 'Ambulance',
                        subtitle: 'Medical SOS',
                        activeColor: AppColors.primary,
                        selected: selectedService == EmergencyServiceType.ambulance,
                      ),
                      const SizedBox(width: 4),
                      _buildServiceTab(
                        type: EmergencyServiceType.womenSafety,
                        icon: Icons.shield,
                        label: 'Women Safety',
                        subtitle: 'Danger SOS',
                        activeColor: const Color(0xFF7C3AED),
                        selected: selectedService == EmergencyServiceType.womenSafety,
                      ),
                      const SizedBox(width: 4),
                      _buildServiceTab(
                        type: EmergencyServiceType.fireBrigade,
                        icon: Icons.local_fire_department,
                        label: 'Fire Brigade',
                        subtitle: 'Fire & Rescue',
                        activeColor: const Color(0xFFEA580C),
                        selected: selectedService == EmergencyServiceType.fireBrigade,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Dynamic Service Action Station
                if (selectedService == EmergencyServiceType.ambulance) ...[
                  // Ambulance Station: Center Tactile SOS Button
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TactileSosButton(
                      onTriggered: () {
                        controller.triggerSOS(serviceType: EmergencyServiceType.ambulance);
                        Navigator.of(context).pushNamed(AppRoutes.sosConfirmation);
                      },
                    ),
                  ),
                  const Text(
                    'Press and hold to request an ambulance',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.volume_up,
                            size: 16,
                            color: controller.settings.sirenArmed ? AppColors.tertiary : AppColors.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            controller.settings.sirenArmed ? 'Siren Armed' : 'Siren Muted',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.vibration,
                            size: 16,
                            color: controller.settings.hapticFeedback ? AppColors.primary : AppColors.secondary,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Haptic Feedback',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ] else if (selectedService == EmergencyServiceType.womenSafety) ...[
                  // Women Safety Station: 1-Tap Emergency Activation
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF5FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF7C3AED), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.shield, color: Color(0xFF7C3AED), size: 24),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'WOMEN SAFETY DISPATCH',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF7C3AED),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Personal safety & immediate danger response protocol',
                                    style: TextStyle(fontSize: 11, color: AppColors.secondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // One-tap trigger button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final note = _safetyNoteController.text.trim();
                              await controller.triggerWomenSafetyEmergency(
                                message: note.isNotEmpty ? note : null,
                              );
                              if (context.mounted) {
                                Navigator.of(context).pushNamed(AppRoutes.sosSearching);
                              }
                            },
                            icon: const Icon(Icons.warning_amber_rounded, size: 24, color: Colors.white),
                            label: const Text(
                              'ONE-TAP WOMEN SAFETY SOS',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.6),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7C3AED),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Voice/Text Note Toggle
                        InkWell(
                          onTap: () {
                            setState(() {
                              _showSafetyNoteField = !_showSafetyNoteField;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _showSafetyNoteField ? Icons.expand_less : Icons.add_comment,
                                  size: 16,
                                  color: const Color(0xFF7C3AED),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _showSafetyNoteField ? 'Hide distress note' : '+ Add short distress voice/text note',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF7C3AED),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (_showSafetyNoteField) ...[
                          const SizedBox(height: 8),
                          TextField(
                            controller: _safetyNoteController,
                            decoration: InputDecoration(
                              hintText: 'e.g., Followed by suspect near metro gate 2',
                              hintStyle: const TextStyle(fontSize: 12, color: AppColors.secondary),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.borderLight),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFF7C3AED)),
                              ),
                            ),
                          ),
                        ],

                        const Divider(height: 20),
                        Row(
                          children: [
                            const Icon(Icons.share_location, size: 16, color: Color(0xFF7C3AED)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                profile.contacts.isNotEmpty
                                    ? 'Emergency contact ${profile.contacts.first.name} will be auto-notified.'
                                    : 'Auto-capturing GPS & dispatching nearest Quick Response Patrol.',
                                style: const TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ] else if (selectedService == EmergencyServiceType.fireBrigade) ...[
                  // Fire Brigade Station: Subtype selector & dispatch
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEA580C), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEA580C).withValues(alpha: 0.15),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.local_fire_department, color: Color(0xFFEA580C), size: 26),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'FIRE BRIGADE & RESCUE SQUAD',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFEA580C),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Select fire emergency classification:',
                                    style: TextStyle(fontSize: 11, color: AppColors.secondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Subtype Chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            'Building fire',
                            'Vehicle fire',
                            'Industrial fire',
                            'Other',
                          ].map((type) {
                            final isSelected = _selectedFireType == type;
                            return ChoiceChip(
                              label: Text(
                                type,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? Colors.white : AppColors.onSurface,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: const Color(0xFFEA580C),
                              backgroundColor: Colors.white,
                              onSelected: (_) {
                                setState(() => _selectedFireType = type);
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // Dispatch Button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await controller.triggerFireBrigadeEmergency(
                                fireType: _selectedFireType,
                              );
                              if (context.mounted) {
                                Navigator.of(context).pushNamed(AppRoutes.sosSearching);
                              }
                            },
                            icon: const Icon(Icons.flash_on, size: 22, color: Colors.white),
                            label: const Text(
                              'DISPATCH FIRE BRIGADE NOW',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.6),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEA580C),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            'Fire engine and heavy rescue squad alerted with your coordinates',
                            style: TextStyle(fontSize: 11, color: AppColors.secondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // 3. Bystander / Help Someone Else Action
                Material(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.helpSomeoneElse);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.secondaryContainer,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.group_add,
                                color: AppColors.onSecondaryContainer,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Request Help for Someone Else',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Accident bystander or stranger triage mode',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.secondary),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Quick Bystander Mode Pill Link
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.bystanderEmergency);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.volunteer_activism, size: 18, color: AppColors.primary),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Someone nearby in distress?',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Bystander Emergency',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                            Icon(Icons.chevron_right, size: 18, color: AppColors.primary),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Emergency Profile Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.medical_information, size: 20, color: AppColors.primary),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Emergency Medical Card',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(AppRoutes.emergencyProfile);
                            },
                            child: const Row(
                              children: [
                                Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Icon(Icons.chevron_right, size: 16, color: AppColors.primary),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Quick Vital Grid
                      Row(
                        children: [
                          _buildVitalBox('Blood Group', profile.bloodGroup, isHighlight: true),
                          const SizedBox(width: 8),
                          _buildVitalBox('Age', '${profile.age} Yrs'),
                          const SizedBox(width: 8),
                          _buildVitalBox('Allergies', profile.allergies, isSuccess: true),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Contact Banner
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.secondaryFixed,
                              ),
                              child: const Icon(
                                Icons.contact_phone,
                                size: 18,
                                color: AppColors.onSecondaryFixed,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'PRIMARY CONTACT',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                  Text(
                                    profile.contacts.isNotEmpty
                                        ? '${profile.contacts.first.name} (${profile.contacts.first.relationship})'
                                        : 'None added',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Material(
                              color: AppColors.primaryFixed,
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Simulating call to contact: ${profile.contacts.first.phone}'),
                                    ),
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.call, size: 20, color: AppColors.onPrimaryFixed),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 5. Statutory Emergency Hotline Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.inverseSurface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.error,
                        ),
                        child: const Icon(Icons.phone_in_talk, size: 20, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NATIONAL POLICE & MEDICAL',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: AppColors.surfaceDim,
                              ),
                            ),
                            Text(
                              'Direct 112 Emergency Dispatch',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.inverseOnSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Simulating 112 Emergency Call..."),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white24,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(80, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text(
                          'DIAL NOW',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 6. Local Area Coverage Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: AppColors.tertiary, size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '3 ResQ ALS Ambulances patrolling Sector 62 cluster',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      Icon(Icons.wifi_tethering, size: 16, color: AppColors.tertiary),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Floating Dev Simulation Controls
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: DevControlBar(controller: controller),
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildServiceTab({
    required EmergencyServiceType type,
    required IconData icon,
    required String label,
    required String subtitle,
    required Color activeColor,
    required bool selected,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          widget.controller.setSelectedService(type);
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? activeColor.withValues(alpha: 0.5) : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? activeColor.withValues(alpha: 0.15) : AppColors.surfaceContainerHigh,
                ),
                child: Icon(
                  icon,
                  color: selected ? activeColor : AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  color: selected ? activeColor : AppColors.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: selected ? activeColor : AppColors.secondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVitalBox(String title, String value, {bool isHighlight = false, bool isSuccess = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: AppColors.secondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isHighlight
                    ? AppColors.primary
                    : isSuccess
                        ? AppColors.tertiary
                        : AppColors.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}


