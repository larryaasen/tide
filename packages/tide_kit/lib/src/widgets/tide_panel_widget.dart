import 'package:flutter/material.dart';

import '../tide_core.dart';
import '../tide_resizer.dart';

class TidePanelWidget extends StatelessWidget {
  const TidePanelWidget({
    super.key,
    this.panelId = TideId.empty,
    this.backgroundColor = Colors.grey,
    this.position = TidePosition.left,
    this.expanded = false,
    this.minWidth = 10,
    this.maxWidth = 3000,
    this.initialWidth = 200,
    this.resizeSide,
    this.child,
  });

  final TideId panelId;
  final Color backgroundColor;
  final TidePosition position;
  final bool expanded;
  final double minWidth;
  final double maxWidth;
  final double initialWidth;

  final TidePosition? resizeSide;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final content = resizeSide != null && child != null
        ? TideResizer(
            resizeSide: resizeSide!,
            minWidth: minWidth,
            maxWidth: maxWidth,
            initialWidth: initialWidth,
            child: child!)
        : child;

    return Container(
      color: backgroundColor,
      child: content,
    );
  }
}

class TidePanelTitleBar extends StatelessWidget {
  const TidePanelTitleBar({super.key, this.title = ''});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
                color: Colors.black54,
                fontSize: 11.0,
                fontWeight: FontWeight.w400),
          )
        ],
      ),
    );
  }
}

/// A panel that displays a search field and search results.
class TideSearchPanel extends StatelessWidget {
  const TideSearchPanel(
      {super.key, this.searchFieldFocusNode, this.onChanged, this.results});

  /// The focus node that should be used for the search field.
  final FocusNode? searchFieldFocusNode;

  /// Called when the user initiates a change to the search field's value: when they have inserted or deleted text.
  final ValueChanged<String>? onChanged;

  /// The widget that displays the search results.
  final Widget? results;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TidePanelTitleBar(title: 'Search'),
        TideSearchTextField(
            focusNode: searchFieldFocusNode, onChanged: onChanged),
        if (results != null) Expanded(child: results!),
      ],
    );
  }
}

class TideSearchTextField extends StatefulWidget {
  const TideSearchTextField({
    super.key,
    this.focusNode,
    this.onChanged,
  });

  final FocusNode? focusNode;

  /// Called when the user initiates a change to the TextField's value: when they have inserted or deleted text.
  final ValueChanged<String>? onChanged;

  @override
  State<TideSearchTextField> createState() => _TideSearchTextFieldState();
}

class _TideSearchTextFieldState extends State<TideSearchTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
      child: TextField(
        autofocus: true,
        focusNode: widget.focusNode,
        cursorColor: Colors.black54,
        cursorHeight: 11.0,
        cursorWidth: 1.0,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hoverColor: Colors.white,
          fillColor: Colors.white,
          filled: true,
          alignLabelWithHint: true,
          hintText: 'Search',
          hintStyle: TextStyle(
              color: Colors.black54,
              fontSize: 12.0,
              height: 1.0,
              leadingDistribution: TextLeadingDistribution.even,
              textBaseline: TextBaseline.alphabetic),
          isDense: true,
          contentPadding: EdgeInsets.only(bottom: 10.0, top: 10.0, left: 4.0),

          // border: InputBorder.none,
        ),
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 13.0,
          height: 1.0,
          leadingDistribution: TextLeadingDistribution.even,
        ),
        onChanged: (value) => widget.onChanged?.call(value),
      ),
    );
  }
}
