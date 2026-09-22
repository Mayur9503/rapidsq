enum EmergencyState {
  idle,
  sosCountdown,
  searching,
  ambulanceAssigned,
  enRoute,
  arriving,
  arrived,
  completed,
  cancelled,
  errorState,
}

enum ErrorStateType {
  noAmbulanceAvailable,
  networkUnavailable,
  locationPermissionDenied,
  requestCancelled,
}

enum VoiceRecordState {
  idle,
  recording,
  recorded,
  playing,
}
