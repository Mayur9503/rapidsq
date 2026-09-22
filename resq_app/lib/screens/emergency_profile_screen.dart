import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../state/app_state_controller.dart';
import '../models/medical_profile.dart';

class EmergencyProfileScreen extends StatefulWidget {
  final AppStateController controller;

  const EmergencyProfileScreen({
    super.key,
    required this.controller,
  });

  @override
  State<EmergencyProfileScreen> createState() => _EmergencyProfileScreenState();
}

class _EmergencyProfileScreenState extends State<EmergencyProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _bloodController;
  late TextEditingController _allergiesController;
  late TextEditingController _conditionsController;
  late TextEditingController _medicationsController;

  @override
  void initState() {
    super.initState();
    final p = widget.controller.medicalProfile;
    _nameController = TextEditingController(text: p.fullName);
    _ageController = TextEditingController(text: p.age.toString());
    _bloodController = TextEditingController(text: p.bloodGroup);
    _allergiesController = TextEditingController(text: p.allergies);
    _conditionsController = TextEditingController(text: p.medicalConditions);
    _medicationsController = TextEditingController(text: p.currentMedications);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _bloodController.dispose();
    _allergiesController.dispose();
    _conditionsController.dispose();
    _medicationsController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final updated = MedicalProfile(
      fullName: _nameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()) ?? 21,
      gender: widget.controller.medicalProfile.gender,
      bloodGroup: _bloodController.text.trim(),
      allergies: _allergiesController.text.trim(),
      medicalConditions: _conditionsController.text.trim(),
      currentMedications: _medicationsController.text.trim(),
      contacts: widget.controller.medicalProfile.contacts,
      documents: widget.controller.medicalProfile.documents,
    );
    await widget.controller.saveMedicalProfile(updated);
    if (!mounted) return;
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.tertiary,
        content: Text(
          widget.controller.authService.isAuthenticated
              ? 'Emergency medical profile synced to Firebase!'
              : 'Medical profile updated locally (Sign in to sync to Firebase).',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.controller.medicalProfile;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Emergency Medical Profile', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit, color: AppColors.primary),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encrypted Medical Record Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock, color: AppColors.tertiary, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Stored locally on your device. Auto-transmitted to paramedics solely upon active SOS dispatch.',
                        style: TextStyle(fontSize: 12, color: AppColors.secondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Section 1: Personal Details
              _buildSectionCard(
                title: 'PERSONAL VITALS',
                children: [
                  _buildField('Full Name', _nameController, _isEditing),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildField('Age', _ageController, _isEditing, keyboardType: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildField('Blood Group', _bloodController, _isEditing)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Section 2: Clinical Data
              _buildSectionCard(
                title: 'MEDICAL & ALLERGY ALERT',
                children: [
                  _buildField('Allergies', _allergiesController, _isEditing),
                  const SizedBox(height: 10),
                  _buildField('Existing Medical Conditions', _conditionsController, _isEditing),
                  const SizedBox(height: 10),
                  _buildField('Current Medications', _medicationsController, _isEditing),
                ],
              ),
              const SizedBox(height: 16),

              // Section 3: Contacts
              _buildSectionCard(
                title: 'CONTACTS',
                children: [
                  ...profile.contacts.map((c) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person_pin, color: AppColors.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${c.name} (${c.relationship})',
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                  ),
                                  Text(c.phone, style: const TextStyle(color: AppColors.secondary, fontSize: 12)),
                                ],
                              ),
                            ),
                            if (c.isPrimary)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryFixed,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'PRIMARY',
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.primary),
                                ),
                              ),
                          ],
                        ),
                      )),
                ],
              ),
              const SizedBox(height: 16),

              // Section 4: Uploaded Medical Documents
              _buildSectionCard(
                title: 'VERIFIED MEDICAL DOCUMENTS',
                children: [
                  ...profile.documents.map((doc) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.file_present, color: AppColors.secondary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(doc.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                  Text('${doc.type} • ${doc.fileSize}', style: const TextStyle(color: AppColors.secondary, fontSize: 11)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.visibility, size: 18, color: AppColors.secondary),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Viewing document: ${doc.title}')),
                                );
                              },
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mock document selector: PDF/Image selected')),
                      );
                    },
                    icon: const Icon(Icons.upload_file, size: 18),
                    label: const Text('ADD NEW DOCUMENT'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (_isEditing)
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: const Text('SAVE PROFILE CHANGES'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
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
          ...children,
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, bool isEditing, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary),
        ),
        const SizedBox(height: 4),
        if (isEditing)
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              controller.text,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface),
            ),
          ),
      ],
    );
  }
}
