import '../commands/tide_command.dart';

/// The command service that is created when [Tide] is initialized.
/// To use a different command service, create a class that extends
/// [TideCommandService] and register it before [Tide] is initialized.
class TideCommandService {
  final registry = TideCommandRegistry();
}
