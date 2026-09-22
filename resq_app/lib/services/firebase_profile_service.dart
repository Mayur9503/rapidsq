import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medical_profile.dart';

class FirebaseProfileService {
  FirebaseFirestore? get _firestore {
    try {
      return Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null;
    } catch (_) {
      return null;
    }
  }

  CollectionReference? get _usersRef => _firestore?.collection('users');
  CollectionReference? get _profilesRef => _firestore?.collection('medical_profiles');

  /// Fetch basic user metadata from users/{uid}
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final ref = _usersRef;
    if (ref == null) return null;
    try {
      final doc = await ref.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw 'Failed to load user profile: $e';
    }
  }

  /// Get role from users/{uid} ('user' or 'rider' or null)
  Future<String?> getUserRole(String uid) async {
    final ref = _usersRef;
    if (ref == null) return null;
    try {
      final doc = await ref.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        final role = data['role'];
        if (role is String && role.isNotEmpty) {
          return role.toLowerCase();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Save role permanently in users/{uid} ('user' or 'rider')
  Future<void> setUserRole(String uid, String role) async {
    final ref = _usersRef;
    if (ref == null) return;
    try {
      await ref.doc(uid).set({
        'role': role.toLowerCase(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw 'Failed to save role: $e';
    }
  }

  /// Link authenticated rider to ambulances/main
  Future<void> registerRiderInAmbulance(
    String uid, {
    String? name,
    String? phone,
    String? email,
    String? fcmToken,
  }) async {
    final firestore = _firestore;
    if (firestore == null) return;
    try {
      final Map<String, dynamic> data = {
        'ambulanceId': 'main',
        'riderUid': uid,
        'driverId': uid,
        'driverName': name ?? 'Assigned Responder',
        'phone': phone ?? '+91 98765 40200',
        'email': email,
        'status': 'AVAILABLE',
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (fcmToken != null && fcmToken.isNotEmpty) {
        data['fcmToken'] = fcmToken;
      }
      await firestore.collection('ambulances').doc('main').set(data, SetOptions(merge: true));
    } catch (e) {
      // Non-fatal
    }
  }

  /// Fetch full medical profile from medical_profiles/{uid}
  Future<MedicalProfile?> getMedicalProfile(String uid) async {
    final ref = _profilesRef;
    if (ref == null) return null;
    try {
      final doc = await ref.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return _fromFirestore(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw 'Failed to load medical profile from Firebase: $e';
    }
  }

  /// Stream medical profile updates in real-time
  Stream<MedicalProfile?> streamMedicalProfile(String uid) {
    final ref = _profilesRef;
    if (ref == null) return const Stream.empty();
    return ref.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return _fromFirestore(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  /// Save or update medical profile in medical_profiles/{uid}
  Future<void> saveMedicalProfile(String uid, MedicalProfile profile) async {
    final ref = _profilesRef;
    if (ref == null) return;
    try {
      await ref.doc(uid).set(_toFirestore(profile), SetOptions(merge: true));
    } catch (e) {
      throw 'Failed to save medical profile: $e';
    }
  }

  /// Convert Firestore Map to MedicalProfile
  MedicalProfile _fromFirestore(Map<String, dynamic> data) {
    final contactsData = data['contacts'] as List<dynamic>? ?? [];
    final contacts = contactsData.map((c) {
      final map = c as Map<String, dynamic>;
      return EmergencyContact(
        name: map['name'] ?? '',
        relationship: map['relationship'] ?? '',
        phone: map['phone'] ?? '',
        isPrimary: map['isPrimary'] ?? false,
      );
    }).toList();

    return MedicalProfile(
      fullName: data['name'] ?? data['fullName'] ?? 'Civic User',
      age: data['age'] is int ? data['age'] : int.tryParse(data['age']?.toString() ?? '21') ?? 21,
      gender: data['gender'] ?? 'Not specified',
      bloodGroup: data['bloodGroup'] ?? 'O+',
      allergies: data['allergies'] ?? 'None',
      medicalConditions: data['conditions'] ?? data['medicalConditions'] ?? 'None',
      currentMedications: data['medications'] ?? data['currentMedications'] ?? 'None',
      contacts: contacts.isNotEmpty
          ? contacts
          : [
              const EmergencyContact(
                name: 'Emergency Contact',
                relationship: 'Family',
                phone: '+91 98765 43210',
                isPrimary: true,
              )
            ],
      documents: MedicalProfile.defaultMockProfile().documents,
    );
  }

  /// Convert MedicalProfile to Firestore Map
  Map<String, dynamic> _toFirestore(MedicalProfile profile) {
    return {
      'name': profile.fullName,
      'age': profile.age,
      'gender': profile.gender,
      'bloodGroup': profile.bloodGroup,
      'allergies': profile.allergies,
      'conditions': profile.medicalConditions,
      'medications': profile.currentMedications,
      'contacts': profile.contacts
          .map((c) => {
                'name': c.name,
                'relationship': c.relationship,
                'phone': c.phone,
                'isPrimary': c.isPrimary,
              })
          .toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
