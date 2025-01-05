import 'package:flutter/material.dart';

import 'tide_notifications.dart';

class NotificationsCenter extends StatefulWidget {
  final TideNotificationService notificationService;

  const NotificationsCenter(
      {super.key, required this.notificationService, required this.child});

  final Widget child;

  @override
  State<NotificationsCenter> createState() => _NotificationsCenterState();
}

class _NotificationsCenterState extends State<NotificationsCenter> {
  bool _isVisible = true;

  void toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TideNotificationServiceState>(
      valueListenable: widget.notificationService.state,
      builder: (context, state, child) {
        final isEmpty = state.notifications.isEmpty && !_isVisible;
        if (isEmpty) return const SizedBox.shrink();

        return Stack(
          children: [
            widget.child,
            if (_isVisible)
              Positioned(
                  bottom: 13.0, right: 13.0, child: _notifications(state)),
          ],
        );
      },
    );
  }

  Widget _container(Widget child) {
    return Material(
        color: Colors.transparent,
        child: Container(
          width: 450.0,
          // padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6.0,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ));
  }

  Widget _notification(
      TideNotification notification, bool addBottomDecoration) {
    const backgroundColor = Color(0xFFF3F3F3);
    final content = Container(
      color: backgroundColor,
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Column(
        children: [
          Container(
            alignment: AlignmentDirectional.center,
            constraints: const BoxConstraints(minHeight: 40.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                iconForSeverity(notification.severity),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    notification.message,
                    style: const TextStyle(fontSize: 12.0),
                  ),
                ),
                if (notification.allowClose)
                  IconButton(
                    icon: const Icon(Icons.close, size: 14.0),
                    onPressed: () {
                      widget.notificationService
                          .removeNotification(notification.id);
                    },
                  ),
              ],
            ),
          ),
          if (notification.progressInfinite)
            LinearProgressIndicator(
              color: Colors.grey.shade500,
              minHeight: 1.0,
              value: null,
              backgroundColor: Colors.transparent,
            ),
          if (!notification.progressInfinite && addBottomDecoration)
            Divider(
              height: 0.5,
              color: Colors.grey.shade300,
            ),
        ],
      ),
    );

    return content;
  }

  Icon iconForSeverity(TideNotificationSeverity severity) {
    switch (severity) {
      case TideNotificationSeverity.info:
      case TideNotificationSeverity.none:
        return const Icon(Icons.info_outlined, color: Colors.blue, size: 18.0);
      case TideNotificationSeverity.warning:
        return Icon(Icons.warning_amber,
            color: Colors.yellow.shade800, size: 18.0);
      case TideNotificationSeverity.error:
        return Icon(Icons.error_outline,
            color: Colors.red.shade400, size: 18.0);
    }
  }

  Widget _notifications(TideNotificationServiceState notificationsState) {
    return _container(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: notificationsState.notifications.length,
            itemBuilder: (context, index) {
              final notification = notificationsState.notifications[index];
              final addBottomDecoration =
                  index != (notificationsState.notifications.length - 1);
              return _notification(notification, addBottomDecoration);
            },
          ),
        ],
      ),
    );
  }
}
