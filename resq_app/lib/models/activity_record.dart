enum ActivityStatus { completed, cancelled, inProgress }

class ActivityRecord {
  final String id;
  final String title;
  final String subtitle;
  final String location;
  final String timeFormatted;
  final ActivityStatus status;
  final String vehicleNumber;
  final String driverName;
  final int responseTimeMinutes;

  const ActivityRecord({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.timeFormatted,
    required this.status,
    required this.vehicleNumber,
    required this.driverName,
    required this.responseTimeMinutes,
  });

  static List<ActivityRecord> mockHistory() {
    return const [
      ActivityRecord(
        id: "RQ-8841",
        title: "Accident Trauma Dispatch",
        subtitle: "Bystander assistance for bike collision",
        location: "Sector 62, Noida",
        timeFormatted: "Today • 8:42 PM",
        status: ActivityStatus.completed,
        vehicleNumber: "MH 12 AB 4521",
        driverName: "Rahul Patil",
        responseTimeMinutes: 6,
      ),
      ActivityRecord(
        id: "RQ-7910",
        title: "Medical Emergency Alert",
        subtitle: "Severe acute breathing distress",
        location: "Indirapuram, Ghaziabad",
        timeFormatted: "Yesterday • 4:15 PM",
        status: ActivityStatus.cancelled,
        vehicleNumber: "UP 14 BX 9021",
        driverName: "Amit Verma",
        responseTimeMinutes: 4,
      ),
      ActivityRecord(
        id: "RQ-6402",
        title: "Bystander Good Samaritan Request",
        subtitle: "Elderly pedestrian fall & triage",
        location: "Electronic City Metro Gate 3",
        timeFormatted: "12 Sep 2026 • 11:20 AM",
        status: ActivityStatus.completed,
        vehicleNumber: "DL 1C K 1104",
        driverName: "Sanjay Kumar",
        responseTimeMinutes: 7,
      ),
    ];
  }
}
