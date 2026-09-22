class AmbulanceUnit {
  final String id;
  final String vehicleNumber;
  final String driverName;
  final String driverPhone;
  final String unitType;
  final int etaMinutes;
  final double distanceKm;
  final String hospitalName;
  final double latitude;
  final double longitude;
  final double heading;

  const AmbulanceUnit({
    required this.id,
    required this.vehicleNumber,
    required this.driverName,
    required this.driverPhone,
    required this.unitType,
    required this.etaMinutes,
    required this.distanceKm,
    required this.hospitalName,
    required this.latitude,
    required this.longitude,
    this.heading = 45.0,
  });

  static const AmbulanceUnit mockUnit = AmbulanceUnit(
    id: "ALS-402",
    vehicleNumber: "MH 12 AB 4521",
    driverName: "Rahul Patil",
    driverPhone: "+91 98765 12345",
    unitType: "Advanced Life Support (ALS)",
    etaMinutes: 5,
    distanceKm: 1.8,
    hospitalName: "Fortis Emergency Trauma Center",
    latitude: 28.6340,
    longitude: 77.3710,
    heading: 220.0,
  );
}
