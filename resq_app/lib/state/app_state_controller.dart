import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/emergency_request.dart';
import '../models/ambulance_unit.dart';
import '../models/medical_profile.dart';
import '../models/activity_record.dart';
import '../models/app_settings.dart';
import '../services/firebase_auth_service.dart';
import '../services/firebase_profile_service.dart';
import '../services/firebase_incident_service.dart';
import '../services/firebase_ambulance_service.dart';
import '../services/firebase_messaging_service.dart';
import '../services/device_location_service.dart';
import '../services/fastapi_backend_service.dart';
import 'emergency_enums.dart';
import 'app_mode.dart';

class AppStateController extends ChangeNotifier {
  // Application Mode: Firebase Live Mode vs Mock Demo Mode
  AppMode _appMode = AppMode.firebase;
  AppMode get appMode => _appMode;

  void setAppMode(AppMode mode) {
    _appMode = mode;
    if (mode == AppMode.firebase) {
      _assignedUnit = const AmbulanceUnit(
        id: 'main',
        vehicleNumber: 'Unit #402',
        driverName: 'Assigned Responder',
        driverPhone: '+91 98765 40200',
        unitType: 'Advanced Life Support (ALS)',
        hospitalName: 'City Emergency Base',
        etaMinutes: 4,
        distanceKm: 1.2,
        latitude: 28.6340,
        longitude: 77.3710,
      );
    }
    notifyListeners();
  }

  // Selected Emergency Service Type
  EmergencyServiceType _selectedService = EmergencyServiceType.ambulance;
  EmergencyServiceType get selectedService => _selectedService;

  void setSelectedService(EmergencyServiceType service) {
    _selectedService = service;
    notifyListeners();
  }

  // Backend & Firebase Service Layer
  final FastApiBackendService backendService = FastApiBackendService();
  final FirebaseAuthService authService = FirebaseAuthService();
  final FirebaseProfileService profileService = FirebaseProfileService();
  final FirebaseIncidentService incidentService = FirebaseIncidentService();
  final FirebaseAmbulanceService ambulanceService = FirebaseAmbulanceService();
  final FirebaseMessagingService messagingService = FirebaseMessagingService();

  // Active Incident Document in Firestore
  String? _activeIncidentDocId;
  String? get activeIncidentDocId => _activeIncidentDocId;

  // Ambulance Driver Status: AVAILABLE, OFFERED, BUSY, OFFLINE
  String _ambulanceStatus = 'AVAILABLE';
  String get ambulanceStatus => _ambulanceStatus;
  set ambulanceStatus(String status) {
    _ambulanceStatus = status;
    notifyListeners();
  }

  void setAmbulanceStatus(String status) {
    _ambulanceStatus = status;
    notifyListeners();
  }

  // Current Emergency State
  EmergencyState _state = EmergencyState.idle;
  EmergencyState get state => _state;
  bool get hasActiveEmergency => _state != EmergencyState.idle;

  ErrorStateType? _errorType;
  ErrorStateType? get errorType => _errorType;

  // Active Emergency Payload
  EmergencyRequest? _currentRequest;
  EmergencyRequest? get currentRequest => _currentRequest;
  set currentRequest(EmergencyRequest? req) {
    _currentRequest = req;
    notifyListeners();
  }

  // Assigned Ambulance Unit
  AmbulanceUnit _assignedUnit = AmbulanceUnit.mockUnit;
  AmbulanceUnit get assignedUnit => _assignedUnit;

  // Active Role: 'user' or 'rider' or null
  String? _userRole;
  String? get userRole => _userRole;

  void setUserRole(String role) {
    _userRole = role.toLowerCase();
    if (_userRole == 'rider') {
      _listenToRiderAmbulance();
    }
    notifyListeners();
  }

  Future<void> _registerRiderFcmAndPresence(String uid) async {
    try {
      final fcmToken = await messagingService.getDeviceToken();
      await profileService.registerRiderInAmbulance(
        uid,
        name: authService.currentUser?.displayName ?? 'Assigned Responder',
        phone: authService.currentUser?.phoneNumber ?? '+91 98765 40200',
        email: authService.currentUser?.email,
        fcmToken: fcmToken,
      );

      if (fcmToken != null && fcmToken.isNotEmpty) {
        final token = await authService.currentUser?.getIdToken();
        await backendService.registerFcmToken(
          fcmToken: fcmToken,
          idToken: token,
        );
      }

      _fcmTokenRefreshSubscription?.cancel();
      _fcmTokenRefreshSubscription = messagingService.onTokenRefresh?.listen((newToken) async {
        if (_userRole == 'rider') {
          await profileService.registerRiderInAmbulance(uid, fcmToken: newToken);
          final idToken = await authService.currentUser?.getIdToken();
          await backendService.registerFcmToken(fcmToken: newToken, idToken: idToken);
        }
      });
    } catch (e) {
      debugPrint('Rider FCM registration notice: $e');
    }
  }

  Future<void> selectRole(String role) async {
    final uid = authService.currentUserId;
    if (uid != null && _appMode == AppMode.firebase) {
      await profileService.setUserRole(uid, role);
      if (role.toLowerCase() == 'rider') {
        await _registerRiderFcmAndPresence(uid);
      }
    }
    setUserRole(role);
  }

  /// Sign out and clear session
  Future<void> signOut() async {
    _userRole = null;
    _activeIncidentDocId = null;
    _riderAmbulanceSubscription?.cancel();
    _activeIncidentSubscription?.cancel();
    _incidentHistorySubscription?.cancel();
    _fcmTokenRefreshSubscription?.cancel();
    _fcmMessageSubscription?.cancel();
    await authService.signOut();
    resetToIdle();
  }

  // Medical Profile
  late MedicalProfile _medicalProfile;
  MedicalProfile get medicalProfile => _medicalProfile;

  // App Settings
  final AppSettings _settings = AppSettings();
  AppSettings get settings => _settings;

  // Activity Records
  List<ActivityRecord> _activityHistory = ActivityRecord.mockHistory();
  List<ActivityRecord> get activityHistory => List.unmodifiable(_activityHistory);

  // Current User Location
  EmergencyLocation _userLocation = EmergencyLocation.defaultUserLocation;
  EmergencyLocation get userLocation => _userLocation;

  // Voice recording simulation
  VoiceRecordState _voiceState = VoiceRecordState.idle;
  VoiceRecordState get voiceState => _voiceState;
  int _voiceDurationSeconds = 0;
  int get voiceDurationSeconds => _voiceDurationSeconds;

  Timer? _countdownTimer;
  Timer? _autoTransitionTimer;
  Timer? _voiceTimer;
  StreamSubscription? _authSubscription;
  StreamSubscription? _incidentHistorySubscription;
  StreamSubscription? _riderAmbulanceSubscription;
  StreamSubscription? _activeIncidentSubscription;
  StreamSubscription? _fcmTokenRefreshSubscription;
  StreamSubscription? _fcmMessageSubscription;

  int _sosCountdownRemaining = 5;
  int get sosCountdownRemaining => _sosCountdownRemaining;

  AppStateController() {
    _medicalProfile = MedicalProfile.defaultMockProfile();
    try {
      if (Firebase.apps.isEmpty) {
        _appMode = AppMode.mock;
      }
    } catch (_) {
      _appMode = AppMode.mock;
    }
    _initFirebaseBindings();
  }

  void _initFirebaseBindings() {
    try {
      _authSubscription = authService.authStateChanges.listen((user) async {
        if (user != null) {
          // Read user role from Firestore
          final role = await profileService.getUserRole(user.uid);
          if (role != null && role.isNotEmpty) {
            _userRole = role.toLowerCase();
          }

          if (_userRole == 'rider') {
            _listenToRiderAmbulance();
            _registerRiderFcmAndPresence(user.uid);
          } else {
            await loadUserProfileFromFirebase(user.uid);
            _listenToUserIncidents(user.uid);
          }
        } else {
          _userRole = null;
          _medicalProfile = MedicalProfile.defaultMockProfile();
          _activityHistory = ActivityRecord.mockHistory();
          _riderAmbulanceSubscription?.cancel();
          _activeIncidentSubscription?.cancel();
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('Firebase Auth stream init fallback: $e');
    }
  }

  void _listenToRiderAmbulance() {
    _riderAmbulanceSubscription?.cancel();
    if (_appMode == AppMode.firebase) {
      try {
        _riderAmbulanceSubscription = ambulanceService.streamAmbulanceDoc('main').listen((doc) async {
          if (doc != null) {
            final status = doc['status'] as String? ?? 'AVAILABLE';
            _ambulanceStatus = status;

            if (status == 'OFFERED') {
              final incidentId = doc['offeredIncidentId'] as String?;
              if (incidentId != null && (_currentRequest == null || _currentRequest!.id != incidentId)) {
                final incidentDoc = await incidentService.getIncident(incidentId);
                if (incidentDoc != null) {
                  final lat = (incidentDoc['latitude'] as num?)?.toDouble() ?? 28.6280;
                  final lng = (incidentDoc['longitude'] as num?)?.toDouble() ?? 77.3649;
                  final serviceKey = incidentDoc['serviceType'] as String? ?? 'ambulance';
                  final desc = incidentDoc['description'] as String?;
                  final priority = incidentDoc['priority'] as String? ?? 'CRITICAL';
                  final offerExpiresAtStr = incidentDoc['offerExpiresAt'] as String?;
                  final offerExpiresAt = offerExpiresAtStr != null ? DateTime.tryParse(offerExpiresAtStr) : null;
                  final timeoutSec = (incidentDoc['acceptanceTimeoutSeconds'] as num?)?.toInt() ?? 6;

                  _currentRequest = EmergencyRequest(
                    id: incidentId,
                    location: EmergencyLocation(
                      title: incidentDoc['locationTitle'] ?? 'User Emergency Location',
                      subtitle: incidentDoc['locationSubtitle'] ?? 'Coordinates: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
                      latitude: lat,
                      longitude: lng,
                    ),
                    serviceType: EmergencyServiceTypeExt.fromKey(serviceKey),
                    priority: priority,
                    additionalNotes: desc,
                    offerExpiresAt: offerExpiresAt,
                    acceptanceTimeoutSeconds: timeoutSec,
                  );
                }
              }
            } else if (status == 'BUSY') {
              final incidentId = doc['activeIncidentId'] as String? ?? doc['offeredIncidentId'] as String?;
              if (incidentId != null && (_currentRequest == null || _currentRequest!.id != incidentId)) {
                final incidentDoc = await incidentService.getIncident(incidentId);
                if (incidentDoc != null) {
                  final lat = (incidentDoc['latitude'] as num?)?.toDouble() ?? 28.6280;
                  final lng = (incidentDoc['longitude'] as num?)?.toDouble() ?? 77.3649;
                  final serviceKey = incidentDoc['serviceType'] as String? ?? 'ambulance';
                  final desc = incidentDoc['description'] as String?;
                  final priority = incidentDoc['priority'] as String? ?? 'CRITICAL';

                  _currentRequest = EmergencyRequest(
                    id: incidentId,
                    location: EmergencyLocation(
                      title: incidentDoc['locationTitle'] ?? 'User Emergency Location',
                      subtitle: incidentDoc['locationSubtitle'] ?? 'Coordinates: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
                      latitude: lat,
                      longitude: lng,
                    ),
                    serviceType: EmergencyServiceTypeExt.fromKey(serviceKey),
                    priority: priority,
                    additionalNotes: desc,
                  );
                }
              }
            } else if (status == 'AVAILABLE') {
              _currentRequest = null;
            }
            notifyListeners();
          }
        }, onError: (e) {
          debugPrint('Rider stream notice: $e');
        });
      } catch (e) {
        debugPrint('Failed to attach rider ambulance stream: $e');
      }
    }
  }

  void _listenToActiveIncident(String incidentId) {
    _activeIncidentSubscription?.cancel();
    if (_appMode == AppMode.firebase) {
      try {
        _activeIncidentSubscription = incidentService.streamIncident(incidentId).listen((snap) {
          if (snap != null && snap.exists) {
            final data = snap.data() as Map<String, dynamic>?;
            if (data != null) {
              final status = (data['status'] as String? ?? '').toUpperCase();
              if (status == 'ASSIGNED') {
                final driverName = data['assignedDriverName'] ?? 'Assigned Responder';
                final vehicle = data['assignedAmbulanceId'] ?? 'Unit #402';
                _assignedUnit = AmbulanceUnit(
                  id: 'ALS-402',
                  vehicleNumber: vehicle,
                  driverName: driverName,
                  driverPhone: '+91 98765 40200',
                  unitType: 'ALS Emergency Unit',
                  hospitalName: 'District Emergency Center',
                  etaMinutes: 4,
                  distanceKm: 1.8,
                  latitude: (data['latitude'] as num?)?.toDouble() ?? 28.6280,
                  longitude: (data['longitude'] as num?)?.toDouble() ?? 77.3649,
                );
                assignAmbulance();
              } else if (status == 'WAITING_FOR_RESPONDER' || status == 'FAILED') {
                _state = EmergencyState.errorState;
                _errorType = ErrorStateType.noAmbulanceAvailable;
                notifyListeners();
              }
            }
          }
        }, onError: (e) {
          debugPrint('Active incident stream notice: $e');
        });
      } catch (e) {
        debugPrint('Failed to stream active incident: $e');
      }
    }
  }

  void _listenToUserIncidents(String uid) {
    _incidentHistorySubscription?.cancel();
    if (_appMode == AppMode.firebase) {
      try {
        _incidentHistorySubscription = incidentService.streamUserIncidents(uid).listen((records) {
          if (records.isNotEmpty) {
            _activityHistory = records;
            notifyListeners();
          }
        }, onError: (e) {
          debugPrint('Incident history stream error: $e');
        });
      } catch (e) {
        debugPrint('Failed to attach incident history stream: $e');
      }
    }
  }

  /// Load medical profile from Firestore for logged in user
  Future<void> loadUserProfileFromFirebase(String uid) async {
    try {
      final remoteProfile = await profileService.getMedicalProfile(uid);
      if (remoteProfile != null) {
        _medicalProfile = remoteProfile;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Could not fetch remote medical profile: $e');
    }
  }

  /// Save medical profile to Firebase and update local state
  Future<void> saveMedicalProfile(MedicalProfile updated) async {
    _medicalProfile = updated;
    notifyListeners();

    if (_appMode == AppMode.firebase && authService.isAuthenticated) {
      final uid = authService.currentUserId!;
      await profileService.saveMedicalProfile(uid, updated);
    }
  }

  void setUserLocation(EmergencyLocation location) {
    _userLocation = location;
    notifyListeners();
  }

  // FLOW 1: Trigger SOS Countdown
  void triggerSOS({
    bool isForSelf = true,
    EmergencyCategory category = EmergencyCategory.selfSOS,
    EmergencyServiceType? serviceType,
  }) {
    final sType = serviceType ?? _selectedService;
    _currentRequest = EmergencyRequest(
      id: 'RQ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      location: _userLocation,
      serviceType: sType,
      isForSelf: isForSelf,
      category: category,
    );
    _sosCountdownRemaining = 5;
    _state = EmergencyState.sosCountdown;
    notifyListeners();

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_sosCountdownRemaining > 1) {
        _sosCountdownRemaining--;
        notifyListeners();
      } else {
        _sosCountdownRemaining = 0;
        timer.cancel();
        sendSOSNow();
      }
    });
  }

  void cancelSOSCountdown() {
    _countdownTimer?.cancel();
    _state = EmergencyState.idle;
    notifyListeners();
  }

  // FLOW 3: Dedicated 1-Tap Women Safety Emergency Activation
  Future<void> triggerWomenSafetyEmergency({String? message}) async {
    _selectedService = EmergencyServiceType.womenSafety;
    _currentRequest = EmergencyRequest(
      id: 'RQ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      location: _userLocation,
      serviceType: EmergencyServiceType.womenSafety,
      category: EmergencyCategory.selfSOS,
      priority: 'CRITICAL',
      additionalNotes: message ?? 'Women Safety Emergency: Immediate personal danger dispatch requested',
      isForSelf: true,
    );
    // 1-tap activation without countdown delay for immediate safety
    await sendSOSNow();
  }

  // FLOW 4: Dedicated Fire Brigade Emergency Activation
  Future<void> triggerFireBrigadeEmergency({required String fireType, String? notes}) async {
    _selectedService = EmergencyServiceType.fireBrigade;
    final combinedNotes = notes != null && notes.isNotEmpty
        ? 'Fire Incident ($fireType): $notes'
        : 'Fire Incident ($fireType)';

    _currentRequest = EmergencyRequest(
      id: 'RQ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      location: _userLocation,
      serviceType: EmergencyServiceType.fireBrigade,
      category: EmergencyCategory.selfSOS,
      priority: 'HIGH',
      additionalNotes: combinedNotes,
      isForSelf: true,
    );
    await sendSOSNow();
  }

  // Send SOS to SEARCHING
  Future<void> sendSOSNow() async {
    _countdownTimer?.cancel();
    _state = EmergencyState.searching;
    notifyListeners();

    final activeServiceType = _currentRequest?.serviceType ?? _selectedService;
    final activePriority = _currentRequest?.priority ?? 'CRITICAL';

    // In Firebase Mode: acquire real phone GPS coordinates & create incident through FastAPI backend
    if (_appMode == AppMode.firebase) {
      try {
        final realGps = await DeviceLocationService.getCurrentCoordinates();
        if (realGps != null) {
          _userLocation = realGps;
          if (_currentRequest != null) {
            _currentRequest = _currentRequest!.copyWith(location: realGps);
          }
        }
      } catch (e) {
        debugPrint('Device GPS acquisition notice: $e');
      }

      try {
        final token = await authService.currentUser?.getIdToken();
        final res = await backendService.createIncident(
          latitude: _currentRequest?.location.latitude ?? _userLocation.latitude,
          longitude: _currentRequest?.location.longitude ?? _userLocation.longitude,
          category: _currentRequest?.category.name ?? 'selfSOS',
          serviceType: activeServiceType.key,
          priority: activePriority,
          description: _currentRequest?.additionalNotes,
          locationTitle: _currentRequest?.location.title ?? _userLocation.title,
          idToken: token,
        );
        _activeIncidentDocId = res['incidentId'];
        _ambulanceStatus = 'OFFERED';
      } catch (e) {
        debugPrint('FastAPI createIncident notice: $e. Falling back to direct Firestore.');
        try {
          final uid = authService.currentUserId ?? 'anonymous_${DateTime.now().millisecondsSinceEpoch}';
          final docId = await incidentService.createIncident(
            userId: uid,
            location: _currentRequest?.location ?? _userLocation,
            serviceType: activeServiceType,
            severity: activePriority,
            category: _currentRequest?.category ?? EmergencyCategory.selfSOS,
            isForSelf: _currentRequest?.isForSelf ?? true,
            additionalNotes: _currentRequest?.additionalNotes,
          );
          _activeIncidentDocId = docId;
        } catch (err) {
          debugPrint('Firestore fallback notice: $err');
        }
      }
    }

    if (_appMode == AppMode.firebase && _activeIncidentDocId != null) {
      _listenToActiveIncident(_activeIncidentDocId!);
    } else {
      // Auto-simulate responder assignment after 3.5 seconds in mock mode
      _autoTransitionTimer?.cancel();
      _autoTransitionTimer = Timer(const Duration(milliseconds: 3500), () {
        if (_state == EmergencyState.searching) {
          assignAmbulance();
        }
      });
    }
  }

  /// Driver response to incoming emergency: ACCEPT or REJECT
  Future<void> respondToIncomingEmergency(String action) async {
    if (_appMode == AppMode.firebase) {
      try {
        final token = await authService.currentUser?.getIdToken();
        await backendService.respondToIncident(
          incidentId: _activeIncidentDocId ?? (_currentRequest?.id ?? 'RQ-DEMO'),
          action: action,
          idToken: token,
        );
      } catch (e) {
        debugPrint('FastAPI respond error: $e');
        rethrow;
      }
    }

    if (action == 'ACCEPT') {
      _ambulanceStatus = 'BUSY';
      assignAmbulance();
    } else {
      _ambulanceStatus = 'AVAILABLE';
      _state = EmergencyState.idle;
      _currentRequest = null;
      notifyListeners();
    }
  }

  /// Upload real-time ambulance GPS coordinates to FastAPI & Firestore
  Future<void> uploadAmbulanceGPS(double latitude, double longitude) async {
    if (_appMode == AppMode.firebase) {
      try {
        final token = await authService.currentUser?.getIdToken();
        await backendService.updateAmbulanceLocation(
          latitude: latitude,
          longitude: longitude,
          idToken: token,
        );
      } catch (e) {
        debugPrint('FastAPI ambulance GPS upload notice: $e');
      }
    }
  }

  /// Complete active incident as ambulance driver
  void completeEmergencyAsDriver() {
    _ambulanceStatus = 'AVAILABLE';
    transitionTo(EmergencyState.completed);
  }

  // FLOW 2: Dispatch for someone else
  Future<void> submitHelpSomeoneElse({
    required EmergencyLocation location,
    required ConsciousnessState consciousness,
    required List<String> visibleTraumas,
    required EmergencyCategory category,
    String? voiceNoteDuration,
    String? notes,
  }) async {
    _currentRequest = EmergencyRequest(
      id: 'RQ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      location: location,
      isForSelf: false,
      consciousness: consciousness,
      visibleTraumas: visibleTraumas,
      category: category,
      voiceNoteDuration: voiceNoteDuration,
      additionalNotes: notes,
    );
    _state = EmergencyState.searching;
    notifyListeners();

    if (_appMode == AppMode.firebase) {
      try {
        final uid = authService.currentUserId ?? 'anonymous_${DateTime.now().millisecondsSinceEpoch}';
        final docId = await incidentService.createIncident(
          userId: uid,
          location: location,
          category: category,
          consciousness: consciousness,
          visibleTraumas: visibleTraumas,
          voiceNoteDuration: voiceNoteDuration,
          additionalNotes: notes,
          isForSelf: false,
        );
        _activeIncidentDocId = docId;
      } catch (e) {
        debugPrint('Firebase help someone else incident creation notice: $e');
      }
    }

    _autoTransitionTimer?.cancel();
    _autoTransitionTimer = Timer(const Duration(milliseconds: 3500), () {
      if (_state == EmergencyState.searching) {
        assignAmbulance();
      }
    });
  }

  void assignAmbulance() {
    _state = EmergencyState.ambulanceAssigned;
    if (_appMode == AppMode.firebase && _activeIncidentDocId != null) {
      incidentService.updateIncidentStatus(
        _activeIncidentDocId!,
        'ASSIGNED',
        assignedAmbulanceId: _assignedUnit.id,
      );
    }
    notifyListeners();
  }

  void transitionTo(EmergencyState targetState) {
    _autoTransitionTimer?.cancel();
    _state = targetState;
    if (_appMode == AppMode.firebase && _activeIncidentDocId != null) {
      incidentService.updateIncidentStatus(
        _activeIncidentDocId!,
        targetState.name.toUpperCase(),
      );
    }
    if (targetState == EmergencyState.completed) {
      _recordCompletedActivity();
    }
    notifyListeners();
  }

  void triggerError(ErrorStateType type) {
    _autoTransitionTimer?.cancel();
    _countdownTimer?.cancel();
    _errorType = type;
    _state = EmergencyState.errorState;
    notifyListeners();
  }

  void cancelEmergency() {
    _autoTransitionTimer?.cancel();
    _countdownTimer?.cancel();
    _errorType = ErrorStateType.requestCancelled;
    _state = EmergencyState.cancelled;
    if (_appMode == AppMode.firebase && _activeIncidentDocId != null) {
      incidentService.updateIncidentStatus(
        _activeIncidentDocId!,
        'CANCELLED',
      );
    }
    notifyListeners();
  }

  void resetToIdle() {
    _autoTransitionTimer?.cancel();
    _countdownTimer?.cancel();
    _state = EmergencyState.idle;
    _errorType = null;
    _currentRequest = null;
    _activeIncidentDocId = null;
    _voiceState = VoiceRecordState.idle;
    _voiceDurationSeconds = 0;
    notifyListeners();
  }

  // Voice Simulation
  void startVoiceRecording() {
    _voiceState = VoiceRecordState.recording;
    _voiceDurationSeconds = 0;
    notifyListeners();

    _voiceTimer?.cancel();
    _voiceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_voiceDurationSeconds < 15) {
        _voiceDurationSeconds++;
        notifyListeners();
      } else {
        timer.cancel();
        _voiceState = VoiceRecordState.recorded;
        notifyListeners();
      }
    });
  }

  void stopVoiceRecording() {
    _voiceTimer?.cancel();
    _voiceState = VoiceRecordState.recorded;
    notifyListeners();
  }

  void resetVoiceRecording() {
    _voiceTimer?.cancel();
    _voiceDurationSeconds = 0;
    _voiceState = VoiceRecordState.idle;
    notifyListeners();
  }

  void toggleVoicePlayback() {
    if (_voiceState == VoiceRecordState.playing) {
      _voiceState = VoiceRecordState.recorded;
    } else {
      _voiceState = VoiceRecordState.playing;
    }
    notifyListeners();
  }

  void updateMedicalProfile(MedicalProfile updated) {
    saveMedicalProfile(updated);
  }

  void _recordCompletedActivity() {
    final newRecord = ActivityRecord(
      id: _currentRequest?.id ?? 'RQ-NEW',
      title: _currentRequest?.isForSelf == false
          ? 'Bystander Triage Dispatch'
          : 'Emergency SOS Response',
      subtitle: 'Ambulance dispatch completed successfully',
      location: _currentRequest?.location.title ?? _userLocation.title,
      timeFormatted: 'Just now',
      status: ActivityStatus.completed,
      vehicleNumber: _assignedUnit.vehicleNumber,
      driverName: _assignedUnit.driverName,
      responseTimeMinutes: 5,
    );
    _activityHistory = [newRecord, ..._activityHistory];
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _autoTransitionTimer?.cancel();
    _voiceTimer?.cancel();
    _authSubscription?.cancel();
    _incidentHistorySubscription?.cancel();
    _riderAmbulanceSubscription?.cancel();
    _activeIncidentSubscription?.cancel();
    super.dispose();
  }
}
