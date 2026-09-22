class EmergencyLocation {
  final String title;
  final String subtitle;
  final double latitude;
  final double longitude;
  final String accuracy;

  const EmergencyLocation({
    required this.title,
    required this.subtitle,
    required this.latitude,
    required this.longitude,
    this.accuracy = "±3m",
  });

  static const EmergencyLocation defaultUserLocation = EmergencyLocation(
    title: "Sector 62, Noida, UP",
    subtitle: "DLF Tech Park area, Near Gate 4",
    latitude: 28.6280,
    longitude: 77.3649,
    accuracy: "±3m",
  );
}

enum ConsciousnessState { conscious, unconscious, unknown }

enum EmergencyCategory {
  selfSOS,
  bystanderAccident,
  cardiac,
  trauma,
  breathing,
  general
}

enum EmergencyServiceType {
  ambulance,
  womenSafety,
  fireBrigade,
}

extension EmergencyServiceTypeExt on EmergencyServiceType {
  String get key {
    switch (this) {
      case EmergencyServiceType.ambulance:
        return 'ambulance';
      case EmergencyServiceType.womenSafety:
        return 'women_safety';
      case EmergencyServiceType.fireBrigade:
        return 'fire_brigade';
    }
  }

  String get displayName {
    switch (this) {
      case EmergencyServiceType.ambulance:
        return 'Ambulance';
      case EmergencyServiceType.womenSafety:
        return 'Women Safety';
      case EmergencyServiceType.fireBrigade:
        return 'Fire Brigade';
    }
  }

  String get subtitle {
    switch (this) {
      case EmergencyServiceType.ambulance:
        return 'Medical Emergency Dispatch';
      case EmergencyServiceType.womenSafety:
        return 'Personal Safety / Danger Alert';
      case EmergencyServiceType.fireBrigade:
        return 'Fire & Heavy Rescue Squad';
    }
  }

  String get vehicleLabel {
    switch (this) {
      case EmergencyServiceType.ambulance:
        return 'Ambulance Unit #402';
      case EmergencyServiceType.womenSafety:
        return 'Safety Patrol Unit #108';
      case EmergencyServiceType.fireBrigade:
        return 'Fire Engine Squad #05';
    }
  }

  static EmergencyServiceType fromKey(String? key) {
    if (key == 'women_safety') return EmergencyServiceType.womenSafety;
    if (key == 'fire_brigade') return EmergencyServiceType.fireBrigade;
    return EmergencyServiceType.ambulance;
  }
}

class EmergencyRequest {
  final String id;
  final EmergencyLocation location;
  final EmergencyServiceType serviceType;
  final EmergencyCategory category;
  final ConsciousnessState consciousness;
  final List<String> visibleTraumas;
  final String? voiceNoteDuration;
  final String? additionalNotes;
  final String priority;
  final DateTime timestamp;
  final bool isForSelf;
  final DateTime? offerExpiresAt;
  final int acceptanceTimeoutSeconds;

  EmergencyRequest({
    required this.id,
    required this.location,
    this.serviceType = EmergencyServiceType.ambulance,
    this.category = EmergencyCategory.selfSOS,
    this.consciousness = ConsciousnessState.conscious,
    this.visibleTraumas = const [],
    this.voiceNoteDuration,
    this.additionalNotes,
    this.priority = 'CRITICAL',
    DateTime? timestamp,
    this.isForSelf = true,
    this.offerExpiresAt,
    this.acceptanceTimeoutSeconds = 6,
  }) : timestamp = timestamp ?? DateTime.now();

  EmergencyRequest copyWith({
    String? id,
    EmergencyLocation? location,
    EmergencyServiceType? serviceType,
    EmergencyCategory? category,
    ConsciousnessState? consciousness,
    List<String>? visibleTraumas,
    String? voiceNoteDuration,
    String? additionalNotes,
    String? priority,
    DateTime? timestamp,
    bool? isForSelf,
    DateTime? offerExpiresAt,
    int? acceptanceTimeoutSeconds,
  }) {
    return EmergencyRequest(
      id: id ?? this.id,
      location: location ?? this.location,
      serviceType: serviceType ?? this.serviceType,
      category: category ?? this.category,
      consciousness: consciousness ?? this.consciousness,
      visibleTraumas: visibleTraumas ?? this.visibleTraumas,
      voiceNoteDuration: voiceNoteDuration ?? this.voiceNoteDuration,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      priority: priority ?? this.priority,
      timestamp: timestamp ?? this.timestamp,
      isForSelf: isForSelf ?? this.isForSelf,
      offerExpiresAt: offerExpiresAt ?? this.offerExpiresAt,
      acceptanceTimeoutSeconds: acceptanceTimeoutSeconds ?? this.acceptanceTimeoutSeconds,
    );
  }
}
