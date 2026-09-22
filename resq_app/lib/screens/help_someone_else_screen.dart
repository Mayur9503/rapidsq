import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../state/app_state_controller.dart';
import '../models/emergency_request.dart';
import '../navigation/app_routes.dart';
import '../widgets/voice_recorder_widget.dart';

class HelpSomeoneElseScreen extends StatefulWidget {
  final AppStateController controller;

  const HelpSomeoneElseScreen({
    super.key,
    required this.controller,
  });

  @override
  State<HelpSomeoneElseScreen> createState() => _HelpSomeoneElseScreenState();
}

class _HelpSomeoneElseScreenState extends State<HelpSomeoneElseScreen> {
  bool _useCurrentLocation = true;
  final TextEditingController _customLocationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  ConsciousnessState _consciousness = ConsciousnessState.unconscious;
  final EmergencyCategory _category = EmergencyCategory.bystanderAccident;
  final List<String> _selectedTraumas = ['Severe Bleeding'];
  String? _voiceNote;

  final List<String> _traumaOptions = [
    'Severe Bleeding',
    'Head Injury / Concussion',
    'Bone Fracture / Deformity',
    'Severe Burns',
    'Breathing Difficulty',
    'Chest Pain / Cardiac',
    'Unresponsive / Coma',
    'None Visible',
  ];

  @override
  void dispose() {
    _customLocationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final location = _useCurrentLocation
        ? widget.controller.userLocation
        : EmergencyLocation(
            title: _customLocationController.text.trim().isEmpty
                ? 'Custom Landmark Reported'
                : _customLocationController.text.trim(),
            subtitle: 'Bystander reported point',
            latitude: 28.6290,
            longitude: 77.3660,
          );

    widget.controller.submitHelpSomeoneElse(
      location: location,
      consciousness: _consciousness,
      visibleTraumas: _selectedTraumas,
      category: _category,
      voiceNoteDuration: _voiceNote,
      notes: _notesController.text.trim(),
    );

    Navigator.of(context).pushReplacementNamed(AppRoutes.sosSearching);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Triage Details', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Good Samaritan Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.secondary,
                      radius: 18,
                      child: Icon(Icons.volunteer_activism, color: Colors.white, size: 20),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Samaritan Bystander Mode',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSecondaryFixed,
                            ),
                          ),
                          Text(
                            'The patient does NOT require an account or app.',
                            style: TextStyle(fontSize: 12, color: AppColors.onSecondaryContainer),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Location Section
              _buildSectionCard(
                title: 'PATIENT PICKUP SPOT',
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('My GPS Pin'),
                            selected: _useCurrentLocation,
                            onSelected: (val) => setState(() => _useCurrentLocation = true),
                            avatar: const Icon(Icons.my_location, size: 16),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Custom Landmark'),
                            selected: !_useCurrentLocation,
                            onSelected: (val) => setState(() => _useCurrentLocation = false),
                            avatar: const Icon(Icons.edit_location, size: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_useCurrentLocation)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.near_me, color: AppColors.primary, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.controller.userLocation.title,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    widget.controller.userLocation.subtitle,
                                    style: const TextStyle(fontSize: 11, color: AppColors.secondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      TextField(
                        controller: _customLocationController,
                        decoration: const InputDecoration(
                          hintText: 'Enter shop name, pillar number, or crossroad...',
                          prefixIcon: Icon(Icons.search, size: 20),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Consciousness Section
              _buildSectionCard(
                title: 'PATIENT CONSCIOUSNESS (TRIAGE LEVEL 1)',
                child: Row(
                  children: [
                    _buildConsciousnessBtn('Conscious', Icons.check_circle, ConsciousnessState.conscious, AppColors.tertiary),
                    const SizedBox(width: 6),
                    _buildConsciousnessBtn('Unconscious', Icons.warning_rounded, ConsciousnessState.unconscious, AppColors.primary),
                    const SizedBox(width: 6),
                    _buildConsciousnessBtn('Unknown / Far', Icons.help, ConsciousnessState.unknown, AppColors.secondary),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Visible Trauma Chips
              _buildSectionCard(
                title: 'VISIBLE TRAUMA / INJURY (TAP ALL THAT APPLY)',
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _traumaOptions.map((item) {
                    final isSelected = _selectedTraumas.contains(item);
                    return FilterChip(
                      label: Text(item),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            if (item == 'None Visible') {
                              _selectedTraumas.clear();
                              _selectedTraumas.add(item);
                            } else {
                              _selectedTraumas.remove('None Visible');
                              _selectedTraumas.add(item);
                            }
                          } else {
                            _selectedTraumas.remove(item);
                          }
                        });
                      },
                      selectedColor: AppColors.primaryFixed,
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.primary : AppColors.onSurface,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Voice Message Component
              _buildSectionCard(
                title: 'OPTIONAL EMERGENCY VOICE INTEL',
                child: VoiceRecorderWidget(
                  compact: true,
                  onVoiceRecorded: (dur) {
                    setState(() => _voiceNote = dur);
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Additional Notes
              _buildSectionCard(
                title: 'LANDMARK OR RESCUE NOTES',
                child: TextField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'e.g., Near yellow billboard, 2 people on motorcycle...',
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.emergency, color: Colors.white, size: 24),
                label: const Text('REQUEST AMBULANCE FOR PATIENT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildConsciousnessBtn(String label, IconData icon, ConsciousnessState state, Color color) {
    final isSelected = _consciousness == state;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _consciousness = state),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? (state == ConsciousnessState.unconscious ? AppColors.primary : AppColors.surfaceContainerHigh) : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? (state == ConsciousnessState.unconscious ? AppColors.primary : color) : AppColors.borderLight,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: isSelected ? (state == ConsciousnessState.unconscious ? Colors.white : color) : AppColors.secondary),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? (state == ConsciousnessState.unconscious ? Colors.white : AppColors.onSurface) : AppColors.secondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
