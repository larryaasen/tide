import 'dart:async';

import 'package:intl/intl.dart';

/// The state that is output in the stream by [TideTimeService].
class TideTimeState {
  const TideTimeState(this.now);

  final DateTime now;

  String timeFormatted({bool use24HourFormat = false}) {
    final time = now;
    var hourValue = time.hour == 0 ? 12 : time.hour;
    if (!use24HourFormat) {
      hourValue = time.hour > 12 ? time.hour - 12 : time.hour;
    }

    final hour = hourValue.toString();
    final minutes = time.minute.toString().padLeft(2, '0');
    final seconds = time.second.toString().padLeft(2, '0');

    final amPM = use24HourFormat
        ? ''
        : time.hour >= 12
            ? ' PM'
            : ' AM';

    String timeOnly = '$hour:$minutes:$seconds$amPM';
    return timeOnly;
  }

  /// Formats the current time according to the given pattern using [intl.DateFormat].
  String formatted(String pattern) {
    final fmt = DateFormat(pattern);
    return fmt.format(now);
  }
}

/// A wall clock time service that outputs a stream.
/// Example usage:
///
/// ```dart
/// void example() {
///   final timeService = TideTimeService();
///   timeService.stream.listen(
///     (data) => print('Received: $data'),
///     onError: (error) => print('Error: $error'),
///     onDone: () => print('Stream closed'),
///   );
/// }
/// ```
class TideTimeService {
  TideTimeService() {
    _initialize();
  }

  /// Create a StreamController
  final _controller = StreamController<TideTimeState>.broadcast();

  Stream<TideTimeState> get stream => _controller.stream;
  DateTime get currentTime => DateTime.now();
  TideTimeState get currentTimeState => TideTimeState(currentTime);

  /// Update the state.
  void _updateState(TideTimeState newState) {
    // Add data to stream
    _controller.sink.add(newState);
  }

  /// Initialize this service.
  void _initialize() {
    Timer.periodic(const Duration(seconds: 1), _onTimer);
  }

  /// The timer went off.
  void _onTimer(Timer timer) {
    _updateState(currentTimeState);
  }
}
