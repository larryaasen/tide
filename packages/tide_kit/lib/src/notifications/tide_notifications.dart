import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../tide.dart';
import '../tide_core.dart';

/// The severity of a notification.
enum TideNotificationSeverity { none, info, warning, error }

/// A notification is a rich interactive message that is briefly displayed over the workbench.
class TideNotification extends Equatable {
  /// Creates a new notification that can be displayed on the workbench.
  TideNotification({
    String? id,
    required this.message,
    required this.severity,
    this.autoTimeout = false,
    this.allowClose = true,
    DateTime? createdDate,
    this.progressInfinite = false,
  }) {
    this.id = id ?? TideId.uuid;
    this.createdDate = createdDate ?? DateTime.now();
  }

  /// A unique identifier for the notification.
  late final String id;

  /// The message to be displayed.
  final String message;

  /// The severity of the notification.
  final TideNotificationSeverity severity;

  /// The notification will be automatically removed after  seconds.
  final bool autoTimeout;

  /// The date/time when the notification was created. This will be set automatically
  /// if not provided.
  late final DateTime? createdDate;

  /// Allow the notification to be closed/removed by the user.
  final bool allowClose;

  /// Causes a progress bar to spin infinitley.
  final bool progressInfinite;

  @override
  List<Object?> get props => [
        id,
        message,
        severity,
        autoTimeout,
        createdDate,
        allowClose,
        progressInfinite
      ];

  TideNotification copyWith({
    String? id,
    String? message,
    TideNotificationSeverity? severity,
    bool? autoTimeout,
    bool? allowClose,
    DateTime? createdDate,
    bool? progressInfinite,
  }) {
    return TideNotification(
      id: id ?? this.id,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      autoTimeout: autoTimeout ?? this.autoTimeout,
      allowClose: allowClose ?? this.allowClose,
      createdDate: createdDate ?? this.createdDate,
      progressInfinite: progressInfinite ?? this.progressInfinite,
    );
  }
}

class TideNotificationServiceState extends Equatable {
  const TideNotificationServiceState({this.notifications = const []});

  final List<TideNotification> notifications;

  TideNotificationServiceState copyWith({
    List<TideNotification>? notifications,
  }) {
    return TideNotificationServiceState(
      notifications: notifications ?? this.notifications,
    );
  }

  @override
  List<Object?> get props => [notifications];
}

/// A service that can be used to display notifications on the workbench.
class TideNotificationService {
  final state = ValueNotifier<TideNotificationServiceState>(
      const TideNotificationServiceState());

  // Expired notifications timer.
  Timer? _timer;

  void updateState(TideNotificationServiceState newState) {
    state.value = newState;
  }

  TideNotification notify(TideNotification notification) {
    final currentState = state.value;
    final newList = List<TideNotification>.from(currentState.notifications)
      ..add(notification);

    updateState(currentState.copyWith(notifications: newList));

    Tide.log(
        "Tide: TideNotificationService added notification: ${notification.message}");

    _startTimerIfNeeded();

    return notification;
  }

  void _startTimerIfNeeded() {
    if (state.value.notifications.any((n) => n.autoTimeout)) {
      _timer ??= Timer.periodic(const Duration(seconds: 1), _timerFired);
    }
  }

  void _timerFired(timer) {
    final now = DateTime.now();

    final toBeRemoved = <TideNotification>[];

    // Find expired notifications to be removed.
    for (var notification in state.value.notifications) {
      if (notification.autoTimeout) {
        final diff = now.difference(notification.createdDate!);
        if (diff.inSeconds >= 3) {
          toBeRemoved.add(notification);
        }
      }
    }

    // Remove expired notifications.
    for (var notification in toBeRemoved) {
      removeNotification(notification.id);
    }

    // Cancel the timer if not needed anymore.
    if (!state.value.notifications
        .any((notification) => notification.autoTimeout)) {
      _timer?.cancel();
      _timer = null;
    }
  }

  TideNotification info(
    String message, {
    /// Allow the notification to be closed/removed by the user.
    bool allowClose = true,

    /// The notification will be automatically removed after 3 seconds.
    bool autoTimeout = false,
  }) {
    return notify(TideNotification(
      message: message,
      severity: TideNotificationSeverity.info,
      allowClose: allowClose,
      autoTimeout: autoTimeout,
    ));
  }

  TideNotification warning(
    String message, {
    /// Allow the notification to be closed/removed by the user.
    bool allowClose = true,

    /// The notification will be automatically removed after 3 seconds.
    bool autoTimeout = false,
  }) {
    return notify(TideNotification(
      message: message,
      severity: TideNotificationSeverity.warning,
      allowClose: allowClose,
      autoTimeout: autoTimeout,
    ));
  }

  TideNotification error(
    String message, {
    /// Allow the notification to be closed/removed by the user.
    bool allowClose = true,

    /// The notification will be automatically removed after 3 seconds.
    bool autoTimeout = false,
  }) {
    return notify(TideNotification(
      message: message,
      severity: TideNotificationSeverity.error,
      allowClose: allowClose,
      autoTimeout: autoTimeout,
    ));
  }

  /// Display a temporary message on the status bar.
  TideNotification status() {
    throw UnimplementedError();
  }

  void removeNotification(String id) {
    final currentState = state.value;
    final newList = List<TideNotification>.from(currentState.notifications)
      ..removeWhere((notification) => notification.id == id);
    updateState(currentState.copyWith(notifications: newList));
    Tide.log("Tide: TideNotificationService removed notification: $id");
  }

  bool notificationExists(String id) {
    return state.value.notifications
        .any((notification) => notification.id == id);
  }
}
