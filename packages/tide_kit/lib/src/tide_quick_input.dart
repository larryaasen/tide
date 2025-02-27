import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme/tide_theme.dart';
import 'tide.dart';
import 'tide_core.dart';
import 'widgets/tide_panel_widget.dart';

class TideQuickPickItem {
  TideQuickPickItem(
      {required this.label, this.leadingIcon, this.showSeparator = false});

  /// The label to display for the item.
  final String label;

  /// An icon to display to the left of the label.
  final IconData? leadingIcon;

  final bool showSeparator;
}

/// A way to gather user input.
class TideQuickInput {
  TideQuickInput({this.title});

  /// The title of the quick input.
  final String? title;
}

/// A way to gather user input from a list of items.
class TideQuickPick extends TideQuickInput {
  TideQuickPick({
    this.value = '',
    this.placeholder,
    this.items = const [],
    this.onDidAccept,
  });

  /// The current value of the quick pick input.
  final String value;

  /// The placeholder text to display in the quick pick input.
  final String? placeholder;

  /// The items to display in the quick pick.
  final List<TideQuickPickItem> items;

  /// Event called when the user submits the input.
  final void Function(TideQuickPickItem item)? onDidAccept;
}

/// A way to gather user input from a [TextField].
class TideQuickInputBox extends TideQuickInput {
  TideQuickInputBox({
    super.title,
    this.value = '',
    this.placeholder,
    this.prompt,
    this.onDidChangeValue,
    this.onDidAccept,
  });

  /// The current value of the quick input box.
  final String value;

  /// The placeholder text to display in the quick input box.
  final String? placeholder;

  /// The text to show below the input box.
  final String? prompt;

  /// Callback called when the input value changes.
  final void Function(String value)? onDidChangeValue;

  /// Event called when the user submits the input.
  final void Function(String value)? onDidAccept;
}

class TideQuickInputBoxWidget extends StatefulWidget {
  const TideQuickInputBoxWidget(this.inputBox, {super.key});

  final TideQuickInputBox inputBox;

  static Future<T?> show<T>(BuildContext context, TideQuickInputBox inputBox) {
    return showDialog<T>(
      barrierColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return TideQuickInputBoxWidget(inputBox);
      },
    );
  }

  @override
  State<TideQuickInputBoxWidget> createState() =>
      _TideQuickInputBoxWidgetState();
}

class _TideQuickInputBoxWidgetState extends State<TideQuickInputBoxWidget> {
  final _controller = TextEditingController();

  @override
  void initState() {
    _controller.text = widget.inputBox.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final prompt = widget.inputBox.prompt ?? '';
    final title = widget.inputBox.title ?? '';
    return AlertDialog(
      title: title.isNotEmpty ? Text(title) : null,
      alignment: Alignment.topCenter,
      backgroundColor: const Color(0xFFF3F3F3),
      contentPadding: const EdgeInsets.all(8.0),
      insetPadding: const EdgeInsets.all(0.0),
      elevation: 4.0,
      shadowColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TideTextField(
            controller: _controller,
            hintText: widget.inputBox.placeholder,
            onChanged: (value) => widget.inputBox.onDidChangeValue?.call(value),
            onSubmitted: (value) {
              widget.inputBox.onDidAccept?.call(value);
              Navigator.of(context).pop();
            },
          ),
          if (prompt.isNotEmpty) ...[
            const SizedBox(height: 8.0),
            Text(prompt, style: const TextStyle(color: Colors.black54)),
          ],
        ],
      ),
    );
  }
}

class TideQuickPickWidget extends StatefulWidget {
  const TideQuickPickWidget(this.quickPick, {super.key});

  final TideQuickPick quickPick;

  static Future<T?> show<T>(BuildContext context, TideQuickPick quickPick) {
    return showDialog<T>(
      barrierColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return TideQuickPickWidget(quickPick);
      },
    );
  }

  @override
  State<TideQuickPickWidget> createState() => _TideQuickPickWidgetState();
}

class _TideQuickPickWidgetState extends State<TideQuickPickWidget> {
  final _controller = TextEditingController();

  TideQuickPickItem? _selectedItem;
  int? _selectedIndex;

  @override
  void initState() {
    _controller.text = widget.quickPick.value;
    _selectedItem =
        widget.quickPick.items.isNotEmpty ? widget.quickPick.items.first : null;
    _selectedIndex = widget.quickPick.items.isNotEmpty ? 0 : null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.quickPick.title ?? '';
    /*
    return AlertDialog(
      title: Text("Select an Item"),
      content: Container(
        width: double.maxFinite, // Ensures it takes full width
        child: SizedBox(
          height: 200, // Fixed height to prevent intrinsic dimension error
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 10,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text("Item $index"),
              );
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Close"),
        ),
      ],
    );
    */

    return AlertDialog(
        scrollable: true,
        title: title.isNotEmpty ? Text(title) : null,
        alignment: Alignment.topCenter,
        backgroundColor: const Color(0xFFF3F3F3),
        contentPadding: const EdgeInsets.all(8.0),
        insetPadding: const EdgeInsets.all(0.0),
        elevation: 4.0,
        shadowColor: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        content: _content(context));
  }

  Widget _content(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;

    final child = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: windowSize.width * 0.75,
        maxHeight: windowSize.height * 0.75,
      ),
      child: Column(
        children: [
          ..._headerItems(),
          const SizedBox(height: 8.0),
          Expanded(
            child: SingleChildScrollView(
                child: Column(children: _buildListItems(_selectedItem))),
          ),
        ],
      ),
    );

    return TideSelectionActionDetector(
      child: child,
      onDownArrow: () {
        setState(() {
          if (_selectedIndex != null) {
            _selectedIndex = _selectedIndex == widget.quickPick.items.length - 1
                ? 0
                : _selectedIndex! + 1;
            _selectedItem = widget.quickPick.items[_selectedIndex!];
          }
        });
      },
      onUpArrow: () {
        setState(() {
          if (_selectedIndex != null) {
            _selectedIndex = _selectedIndex == 0
                ? widget.quickPick.items.length - 1
                : _selectedIndex! - 1;
            _selectedItem = widget.quickPick.items[_selectedIndex!];
          }
        });
      },
      onEnter: () {
        if (_selectedItem != null) {
          widget.quickPick.onDidAccept?.call(_selectedItem!);
          Navigator.of(context).pop();
        }
      },
    );
  }

  List<Widget> _headerItems() {
    return [
      TideTextField(
        controller: _controller,
        hintText: widget.quickPick.placeholder,
        onSubmitted: (value) {
          if (_selectedItem != null) {
            widget.quickPick.onDidAccept?.call(_selectedItem!);
            Navigator.of(context).pop();
          }
        },
      ),
    ];
  }

  List<Widget> _buildListItems(TideQuickPickItem? selectedItem) {
    final items = widget.quickPick.items.map((item) {
      final selected = item == selectedItem;
      final child = TideQuickPickItemWidget(item: item, selected: selected);
      final inkWell = InkWell(
        onTap: () {
          if (_selectedItem != null) {
            widget.quickPick.onDidAccept?.call(_selectedItem!);
            Navigator.of(context).pop();
          }
        },
        child: child,
      );
      return inkWell;
    }).toList();
    return items;
  }
}

class TideQuickPickItemWidget extends StatelessWidget {
  const TideQuickPickItemWidget(
      {super.key, required this.item, this.selected = false});

  final TideQuickPickItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = TideTheme.of(context);
    theme.quickPick.itemSelectedBackgroundColor;
    return Container(
      color: selected
          ? theme.quickPick.itemSelectedBackgroundColor
          : theme.quickPick.itemUnselectedBackgroundColor,
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 4.0),
              if (item.leadingIcon != null)
                Icon(item.leadingIcon,
                    size: 20.0,
                    color: selected
                        ? theme.quickPick.itemSelectedForegroundColor
                        : theme.quickPick.itemUnselectedForegroundColor),
              if (item.leadingIcon == null) const SizedBox(width: 20.0),
              const SizedBox(width: 2.0),
              if (item.label.isNotEmpty)
                Text(item.label,
                    style: TextStyle(
                        color: selected
                            ? theme.quickPick.itemSelectedForegroundColor
                            : theme.quickPick.itemUnselectedForegroundColor)),
            ],
          ),
          if (item.showSeparator)
            DividerTheme(
              data: theme.quickPick.itemDividerTheme,
              child: const Divider(),
            ),
        ],
      ),
    );
  }
}

class TideSelectionActionDetector extends StatelessWidget {
  const TideSelectionActionDetector({
    super.key,
    required this.child,
    this.onDownArrow,
    this.onUpArrow,
    this.onEnter,
  });

  final Widget child;
  final void Function()? onDownArrow;
  final void Function()? onUpArrow;
  final void Function()? onEnter;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      key: const Key('TideSelectionActionDetector.FocusableActionDetector'),
      autofocus: true,
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.arrowDown):
            const TideLogicalKeyIntent(LogicalKeyboardKey.arrowDown),
        LogicalKeySet(LogicalKeyboardKey.arrowUp):
            const TideLogicalKeyIntent(LogicalKeyboardKey.arrowUp),
        LogicalKeySet(LogicalKeyboardKey.enter):
            const TideLogicalKeyIntent(LogicalKeyboardKey.enter)
      },
      actions: <Type, Action<Intent>>{
        TideLogicalKeyIntent: CallbackAction<TideLogicalKeyIntent>(
          onInvoke: (TideLogicalKeyIntent intent) {
            Tide.log(intent.key);
            if (intent.key == LogicalKeyboardKey.arrowDown) {
              onDownArrow?.call();
            }
            if (intent.key == LogicalKeyboardKey.arrowUp) {
              onUpArrow?.call();
            }
            if (intent.key == LogicalKeyboardKey.enter) {
              onEnter?.call();
            }

            return null;
          },
        ),
      },
      child: FocusScope(
        key: const Key('TideSelectionActionDetector.FocusScope'),
        child: child,
      ),
    );
  }
}
