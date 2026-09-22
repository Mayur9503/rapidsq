import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ambulance_unit.dart';

class FirebaseAmbulanceService {
  FirebaseFirestore? get _firestore {
    try {
      return Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null;
    } catch (_) {
      return null;
    }
  }

  CollectionReference? get _ambulancesRef => _firestore?.collection('ambulances');

  /// Fetch specific ambulance unit by ID
  Future<AmbulanceUnit?> getAmbulance(String ambulanceId) async {
    final ref = _ambulancesRef;
    if (ref == null) return null;
    try {
      final doc = await ref.doc(ambulanceId).get();
      if (doc.exists && doc.data() != null) {
        return _fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Stream ambulance raw document map in real-time
  Stream<Map<String, dynamic>?> streamAmbulanceDoc(String ambulanceId) {
    final ref = _ambulancesRef;
    if (ref == null) return const Stream.empty();
    return ref.doc(ambulanceId).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data() as Map<String, dynamic>;
      }
      return null;
    });
  }

  /// Stream ambulance unit telemetry in real-time
  Stream<AmbulanceUnit?> streamAmbulance(String ambulanceId) {
    final ref = _ambulancesRef;
    if (ref == null) return const Stream.empty();
    return ref.doc(ambulanceId).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return _fromFirestore(snapshot.data() as Map<String, dynamic>, snapshot.id);
      }
      return null;
    });
  }

  /// Seed initial mock ambulance into Firebase if absent (convenience for demo)
  Future<void> seedDefaultAmbulanceIfMissing() async {
    final ref = _ambulancesRef;
    if (ref == null) return;
    try {
      final doc = await ref.doc('ALS-402').get();
      if (!doc.exists) {
        await ref.doc('ALS-402').set({
          'driverId': 'DRV-102',
          'driverName': 'Rahul Patil',
          'driverPhone': '+91 98765 12345',
          'vehicleNumber': 'MH 12 AB 4521',
          'unitType': 'Advanced Life Support (ALS)',
          'status': 'AVAILABLE',
          'latitude': 28.6340,
          'longitude': 77.3710,
          'heading': 220.0,
          'hospitalName': 'Fortis Emergency Trauma Center',
          'etaMinutes': 5,
          'distanceKm': 1.8,
          'lastLocationUpdate': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // Non-blocking fallback
    }
  }

  AmbulanceUnit _fromFirestore(Map<String, dynamic> data, String id) {
    return AmbulanceUnit(
      id: id,
      vehicleNumber: data['vehicleNumber'] ?? 'MH 12 AB 4521',
      driverName: data['driverName'] ?? 'Rahul Patil',
      driverPhone: data['driverPhone'] ?? '+91 98765 12345',
      unitType: data['unitType'] ?? 'Advanced Life Support (ALS)',
      etaMinutes: data['etaMinutes'] is int ? data['etaMinutes'] : 5,
      distanceKm: (data['distanceKm'] as num?)?.toDouble() ?? 1.8,
      hospitalName: data['hospitalName'] ?? 'Fortis Emergency Trauma Center',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 28.6340,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 77.3710,
      heading: (data['heading'] as num?)?.toDouble() ?? 220.0,
    );
  }
}
