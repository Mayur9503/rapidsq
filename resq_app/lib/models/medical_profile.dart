class EmergencyContact {
  final String name;
  final String relationship;
  final String phone;
  final bool isPrimary;

  const EmergencyContact({
    required this.name,
    required this.relationship,
    required this.phone,
    this.isPrimary = false,
  });
}

class MedicalDocument {
  final String id;
  final String title;
  final String type;
  final String dateAdded;
  final String fileSize;

  const MedicalDocument({
    required this.id,
    required this.title,
    required this.type,
    required this.dateAdded,
    required this.fileSize,
  });
}

class MedicalProfile {
  String fullName;
  int age;
  String gender;
  String bloodGroup;
  String allergies;
  String medicalConditions;
  String currentMedications;
  List<EmergencyContact> contacts;
  List<MedicalDocument> documents;

  MedicalProfile({
    required this.fullName,
    required this.age,
    required this.gender,
    required this.bloodGroup,
    required this.allergies,
    required this.medicalConditions,
    required this.currentMedications,
    required this.contacts,
    required this.documents,
  });

  static MedicalProfile defaultMockProfile() {
    return MedicalProfile(
      fullName: "Aarav Sharma",
      age: 21,
      gender: "Male",
      bloodGroup: "O+",
      allergies: "None",
      medicalConditions: "Mild Asthma (Exercise-induced)",
      currentMedications: "Salbutamol Inhaler (PRN)",
      contacts: [
        const EmergencyContact(
          name: "Ramesh Sharma",
          relationship: "Father",
          phone: "+91 98765 43210",
          isPrimary: true,
        ),
        const EmergencyContact(
          name: "Sunita Sharma",
          relationship: "Mother",
          phone: "+91 98765 43211",
          isPrimary: false,
        ),
      ],
      documents: [
        const MedicalDocument(
          id: "DOC-1",
          title: "Aadhaar Identity Card",
          type: "National ID",
          dateAdded: "15 Jan 2026",
          fileSize: "1.2 MB",
        ),
        const MedicalDocument(
          id: "DOC-2",
          title: "Star Health Comprehensive Policy",
          type: "Health Insurance",
          dateAdded: "01 Mar 2026",
          fileSize: "2.4 MB",
        ),
        const MedicalDocument(
          id: "DOC-3",
          title: "Pulmonary Allergy Diagnostic Report",
          type: "Lab Report",
          dateAdded: "20 May 2026",
          fileSize: "850 KB",
        ),
      ],
    );
  }
}
