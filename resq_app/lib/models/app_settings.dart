class AppSettings {
  bool sirenArmed;
  bool hapticFeedback;
  bool autoDial112;
  bool highContrastMode;
  int sosHoldDurationSeconds;
  String language;
  bool shareMedicalDataWithParamedics;

  AppSettings({
    this.sirenArmed = true,
    this.hapticFeedback = true,
    this.autoDial112 = false,
    this.highContrastMode = false,
    this.sosHoldDurationSeconds = 2,
    this.language = "English",
    this.shareMedicalDataWithParamedics = true,
  });
}
