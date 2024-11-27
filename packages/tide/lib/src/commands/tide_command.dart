import '../tide.dart';
import '../tide_core.dart';

typedef TideCommandHandler = void Function(TideCommand command,
    TideCommandParams commandParams, TideServicesAccessor accessor);
typedef TideCommandHandlersMap = Map<String, TideCommandHandler>;
typedef TideCommandParams = Map<String, Object>;
typedef TideCommandsMap = Map<String, TideCommand>;

/// Commands are runnable actions defined by an ID and a title.
class TideCommand {
  TideCommand({required this.id, this.title});

  final TideId id;
  final String? title;

  @override
  String toString() {
    return '{id: $id, title: $title}';
  }
}

class TideCommandRegistry {
  final _commands = TideCommandsMap();
  final _handlers = TideCommandHandlersMap(); // maybe at this to TideCommand.

  /// Connects a command with a handler function that can interact with the services.
  void registerCommand(
      TideId commandId, String title, TideCommandHandler handler) {
    if (_commands.containsKey(commandId.id)) {
      throw Exception('Command already registered: $commandId');
    }
    _commands[commandId.id] = TideCommand(id: commandId, title: title);
    _handlers[commandId.id] = handler;
  }

  TideCommand getCommand(TideId commandId) {
    final command = _commands[commandId.id];
    if (command == null) {
      throw Exception('Command not found: $commandId');
    }
    return command;
  }

  void executeCommand(TideId commandId, TideCommandParams commandParams,
      TideServicesAccessor accessor) {
    final handler = _handlers[commandId.id];
    final command = _commands[commandId.id];
    if (handler == null) {
      throw Exception('Tide: Command handler not found: $commandId');
    }
    if (command == null) {
      throw Exception('Tide: Command not found: $commandId');
    }
    Tide.log('Tide: execute handler for $command');

    handler(command, commandParams, accessor);
  }

  void deleteCommand(TideId commandId) {
    _commands.remove(commandId.id);
    _handlers.remove(commandId.id);
  }

  TideCommandsMap getCommands() {
    final commands = TideCommandsMap();
    for (final key in _commands.keys) {
      final command = _commands[key];
      if (command != null) {
        commands[key] = command;
      }
    }
    return commands;
  }
}

/// Commands are runnable actions defined by an ID and the function to be executed
abstract class TideCommandContribution {
  TideCommandContribution();

  void registerCommands(TideCommandRegistry registry);
}
