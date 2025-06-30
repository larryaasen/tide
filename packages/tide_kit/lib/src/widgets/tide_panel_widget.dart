import 'package:flutter/material.dart';

import '../tide_core.dart';

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
    // final content = resizeSide != null && child != null
    //     ? TideResizer(
    //         resizeSide: resizeSide!,
    //         minWidth: minWidth,
    //         maxWidth: maxWidth,
    //         initialWidth: initialWidth,
    //         child: child!)
    //     : ConstrainedBox(
    //         constraints: BoxConstraints(minWidth: minWidth), child: child);

    return Container(
      color: backgroundColor,
      child: child,
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
        Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
          child: TideTextField(
              focusNode: searchFieldFocusNode,
              hintText: 'Search',
              onChanged: onChanged),
        ),
        if (results != null) Expanded(child: results!),
      ],
    );
  }
}

class TideTextField extends StatefulWidget {
  const TideTextField({
    super.key,
    this.focusNode,
    this.hintText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
  });

  final FocusNode? focusNode;
  final String? hintText;
  final TextEditingController? controller;

  /// Called when the user initiates a change to the TextField's value: when they have inserted or deleted text.
  final ValueChanged<String>? onChanged;

  /// Called when the user indicates that they are done editing the text in the field.
  final ValueChanged<String>? onSubmitted;

  @override
  State<TideTextField> createState() => _TideTextFieldState();
}

class _TideTextFieldState extends State<TideTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: true,
      controller: widget.controller,
      cursorColor: Colors.black54,
      cursorHeight: 11.0,
      cursorWidth: 1.0,
      decoration: InputDecoration(
        // border: InputBorder.none,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(2.0)),
          borderSide: BorderSide(color: Colors.transparent, width: 0.0),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(2.0)),
          borderSide: BorderSide(color: Colors.transparent, width: 0.0),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(2.0)),
          borderSide: BorderSide(color: Colors.blue, width: 1.0),
        ),
        hoverColor: Colors.white,
        fillColor: Colors.white,
        filled: true,
        alignLabelWithHint: true,
        hintText: widget.hintText,
        hintStyle: const TextStyle(
            color: Colors.black54,
            fontSize: 12.0,
            height: 1.0,
            leadingDistribution: TextLeadingDistribution.even,
            textBaseline: TextBaseline.alphabetic),
        isDense: true,
        contentPadding:
            const EdgeInsets.only(bottom: 10.0, top: 10.0, left: 4.0),

        // border: InputBorder.none,
      ),
      focusNode: widget.focusNode,
      style: const TextStyle(
        color: Colors.black54,
        fontSize: 13.0,
        height: 1.0,
        leadingDistribution: TextLeadingDistribution.even,
      ),
      onChanged: (value) => widget.onChanged?.call(value),
      onSubmitted: (value) => widget.onSubmitted?.call(value),
    );
  }
}

class TidePanelBorder extends StatelessWidget {
  const TidePanelBorder(
      {super.key, required this.isEdgeVertical, this.borderDimension = 1.0});

  final bool isEdgeVertical;
  final double borderDimension;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isEdgeVertical ? borderDimension : null,
      height: isEdgeVertical ? null : borderDimension,
      color: Colors.grey.shade300,
    );
  }
}
