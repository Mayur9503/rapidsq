import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/emergency_request.dart';
import '../models/activity_record.dart';

class FirebaseIncidentService {
  FirebaseFirestore? get _firestore {
    try {
      return Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null;
    } catch (_) {
      return null;
    }
  }

  CollectionReference? get _emergenciesRef => _firestore?.collection('emergencies');

  /// Create a real emergency incident in emergencies/{incidentId}
  Future<String> createIncident({
    required String userId,
    required EmergencyLocation location,
    EmergencyServiceType serviceType = EmergencyServiceType.ambulance,
    EmergencyCategory category = EmergencyCategory.selfSOS,
    ConsciousnessState consciousness = ConsciousnessState.conscious,
    List<String> visibleTraumas = const [],
    String? voiceNoteDuration,
    String? additionalNotes,
    bool isForSelf = true,
    String severity = 'CRITICAL',
  }) async {
    final ref = _emergenciesRef;
    if (ref == null) return 'RQ-OFFLINE';

    try {
      final docRef = ref.doc();
      final incidentId = 'RQ-${docRef.id.substring(0, 6).toUpperCase()}';

      final data = {
        'incidentId': incidentId,
        'userId': userId,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'locationTitle': location.title,
        'locationSubtitle': location.subtitle,
        'status': 'SEARCHING',
        'serviceType': serviceType.key,
        'priority': severity,
        'severity': severity,
        'category': category.name,
        'consciousness': consciousness.name,
        'visibleTraumas': visibleTraumas,
        'voiceNoteDuration': voiceNoteDuration,
        'description': additionalNotes ?? (isForSelf ? 'Self emergency SOS trigger' : 'Bystander assisted dispatch'),
        'isForSelf': isForSelf,
        'assignedAmbulanceId': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(data);

      // Log initial event: SOS_CREATED
      await logIncidentEvent(
        docRef.id,
        type: 'SOS_CREATED',
        metadata: {
          'category': category.name,
          'latitude': location.latitude,
          'longitude': location.longitude,
        },
      );

      // Log secondary event: SEARCH_STARTED
      await logIncidentEvent(
        docRef.id,
        type: 'SEARCH_STARTED',
        metadata: {'broadcastRadiusKm': 3.5},
      );

      return docRef.id;
    } catch (e) {
      throw 'Failed to create emergency incident: $e';
    }
  }

  /// Append event to incident_events/{incidentId}/{eventId}
  Future<void> logIncidentEvent(
    String incidentDocId, {
    required String type,
    Map<String, dynamic>? metadata,
  }) async {
    final ref = _emergenciesRef;
    if (ref == null) return;
    try {
      await ref
          .doc(incidentDocId)
          .collection('incident_events')
          .add({
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
        'metadata': metadata ?? {},
      });
    } catch (e) {
      // Non-critical telemetry logging error
    }
  }

  /// Update status of an incident (e.g. ASSIGNED, EN_ROUTE, ARRIVING, ARRIVED, COMPLETED, CANCELLED)
  Future<void> updateIncidentStatus(
    String incidentDocId,
    String status, {
    String? assignedAmbulanceId,
  }) async {
    final ref = _emergenciesRef;
    if (ref == null) return;

    try {
      final updates = <String, dynamic>{
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (assignedAmbulanceId != null) {
        updates['assignedAmbulanceId'] = assignedAmbulanceId;
      }

      await ref.doc(incidentDocId).update(updates);

      // Log event
      await logIncidentEvent(
        incidentDocId,
        type: 'STATUS_$status',
        metadata: {'status': status, 'ambulanceId': assignedAmbulanceId},
      );
    } catch (e) {
      throw 'Failed to update incident status: $e';
    }
  }

  /// Get incident document by ID
  Future<Map<String, dynamic>?> getIncident(String incidentDocId) async {
    final ref = _emergenciesRef;
    if (ref == null) return null;
    try {
      final doc = await ref.doc(incidentDocId).get();
      if (doc.exists && doc.data() != null) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Stream active incident document in real-time
  Stream<DocumentSnapshot?> streamIncident(String incidentDocId) {
    final ref = _emergenciesRef;
    if (ref == null) return const Stream.empty();
    return ref.doc(incidentDocId).snapshots();
  }

  /// Fetch user history of incidents as ActivityRecord items
  Stream<List<ActivityRecord>> streamUserIncidents(String userId) {
    final ref = _emergenciesRef;
    if (ref == null) return const Stream.empty();

    return ref
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final statusStr = (data['status'] ?? 'COMPLETED').toString().toUpperCase();

        ActivityStatus status = ActivityStatus.inProgress;
        if (statusStr == 'COMPLETED') {
          status = ActivityStatus.completed;
        } else if (statusStr == 'CANCELLED') {
          status = ActivityStatus.cancelled;
        }

        final ts = data['createdAt'] as Timestamp?;
        final timeStr = ts != null
            ? '${ts.toDate().day}/${ts.toDate().month} • ${ts.toDate().hour}:${ts.toDate().minute.toString().padLeft(2, '0')}'
            : 'Recent';

        final sType = (data['serviceType'] ?? 'ambulance').toString();
        String title = 'Medical SOS Dispatch';
        String subtitle = data['description'] ?? 'Priority ambulance emergency dispatch';

        if (sType == 'women_safety') {
          title = 'Women Safety SOS';
          subtitle = data['description'] ?? 'Personal safety response patrol';
        } else if (sType == 'fire_brigade') {
          title = 'Fire Brigade Dispatch';
          subtitle = data['description'] ?? 'Fire squad & heavy rescue dispatch';
        } else if (data['category'] == 'bystanderAccident') {
          title = 'Bystander Emergency Request';
        }

        return ActivityRecord(
          id: data['incidentId'] ?? doc.id,
          title: title,
          subtitle: subtitle,
          location: data['locationTitle'] ?? 'Sector 62, Noida',
          timeFormatted: timeStr,
          status: status,
          vehicleNumber: data['assignedAmbulanceId'] ?? 'ResQ Unit #402',
          driverName: 'Assigned Unit',
          responseTimeMinutes: 5,
        );
      }).toList();
    });
  }
}
