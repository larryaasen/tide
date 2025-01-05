import 'package:upgrader/upgrader.dart';

/// A class that indicates which OS this code is running on.
class TideOS {
  final upgrader = UpgraderOS();

  /// The current OS name.
  get current => upgrader.current;

  /// The current OS name.
  get currentTypeFormatted => upgrader.currentTypeFormatted;

  get operatingSystem => upgrader.operatingSystem;

  get operatingSystemVersion => upgrader.operatingSystemVersion;
}

extension UpgraderOSTideExtension on UpgraderOS {
  /// Get the current OS type formatted, such as 'Android', 'iOS', etc.
  String get currentTypeFormatted {
    return switch (currentOSType) {
      UpgraderOSType.android => 'Android',
      UpgraderOSType.fuchsia => 'Fuchsia',
      UpgraderOSType.ios => 'iOS',
      UpgraderOSType.linux => 'Linux',
      UpgraderOSType.macos => 'macOS',
      UpgraderOSType.web => 'Web',
      UpgraderOSType.windows => 'Windows',
    };
  }
}
