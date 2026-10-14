// A secondary button that opens a Menu (DESIGN.md, Menu).
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'menu.dart';
import 'opener_button.dart';

class _ArrowIntent extends Intent {
  const _ArrowIntent(this.fromEnd);

  final bool fromEnd;
}

/// A secondary button that opens a [Menu] of [items] (DESIGN.md, Menu): a press, Enter or Space opens it on its
/// first item, the up arrow on its last; [icon] is optional, before [label].
class MenuButton extends StatefulWidget {
  /// A menu button labelled [label], opening [items].
  const MenuButton({
    super.key,
    this.icon,
    required this.label,
    required this.items,
    this.focusNode,
    this.autofocus = false,
  });

  /// Before the label; never read itself.
  final Widget? icon;

  /// The button's one-line label.
  final String label;

  /// The menu's items, opened in this order.
  final List<MenuItem> items;

  /// The node to track the button's focus with, when the caller manages one.
  final FocusNode? focusNode;

  /// Focuses it as soon as it is built.
  final bool autofocus;

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  FocusNode? _ownFocusNode;
  bool _open = false;

  FocusNode get _focusNode => widget.focusNode ?? (_ownFocusNode ??= FocusNode(debugLabel: 'MenuButton'));

  @override
  void dispose() {
    _ownFocusNode?.dispose();
    super.dispose();
  }

  void _show({bool fromEnd = false}) {
    if (_open) return;
    // requested here, not left to the tap itself, so the opener reliably has focus for Menu.show to capture and
    // restore it to, matching how a native button keeps focus after being clicked.
    _focusNode.requestFocus();
    setState(() => _open = true);
    Menu.show(context, items: widget.items, fromEnd: fromEnd).whenComplete(() {
      if (mounted) setState(() => _open = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.arrowDown): _ArrowIntent(false),
        SingleActivator(LogicalKeyboardKey.arrowUp): _ArrowIntent(true),
      },
      child: Actions(
        actions: {
          _ArrowIntent: CallbackAction<_ArrowIntent>(
            onInvoke: (intent) {
              if (!_open) _show(fromEnd: intent.fromEnd);
              return null;
            },
          ),
        },
        child: OpenerButton(
          icon: widget.icon,
          label: widget.label,
          open: _open,
          onPressed: _show,
          focusNode: _focusNode,
          autofocus: widget.autofocus,
        ),
      ),
    );
  }
}
