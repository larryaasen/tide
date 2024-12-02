import 'package:flutter/material.dart';

/// A widget that displays a calendar day pane.
class TideCalendarDayPane extends StatelessWidget {
  const TideCalendarDayPane({super.key});

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final List<String> monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final String monthName = monthNames[now.month - 1]; // Get the month name
    final day = now.day;
    final date = '$monthName $day';
    final labels = [];
    for (var hour = 0; hour < 24; hour++) {
      final prefix = hour == now.hour ? '>' : '';
      if (hour == 0) {
        labels.add('${prefix}12 AM');
      } else if (hour < 12) {
        labels.add('$prefix$hour AM');
      } else if (hour == 12) {
        labels.add('${prefix}12 PM');
      } else {
        labels.add('$prefix${hour - 12} PM');
      }
    }

    final line =
        Container(height: 1, width: double.infinity, color: Colors.black12);

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date, style: Theme.of(context).textTheme.headlineMedium),
          Expanded(
            child: ListView(
              children: labels
                  .map((label) => Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                      child: Row(
                        children: [
                          Text(label,
                              style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(width: 8.0),
                          Expanded(child: line),
                        ],
                      )))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
