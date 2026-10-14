// Actions anchored to the control that opens them (DESIGN.md, Menu).

import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../foundation/anchored_position.dart';
import '../foundation/focus_ring.dart';
import '../foundation/overlay_show.dart';
import '../foundation/roving_focus.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import 'glyphs.dart';
import 'menu_panel.dart';

// A reasonable guess at the panel's rendered size, before the first frame measures the real one: only its height
// feeds the flip/clamp decision (a side's room only depends on the anchor's position and the floating element's
// length along that axis), so the width here is never used for that, only as a placeholder until corrected.
Size _estimate(List<MenuItem> items) {
  final height =
      TsuyaSpace.s8 +
      items.fold(
        0.0,
        (sum, item) => sum + (item.separator ? TsuyaSpace.s8 : (item.heading ? 28 : TsuyaSize.controlMd)),
      );
  return Size(220, height);
}

/// Actions anchored to the control that opens them (DESIGN.md, Menu). Opens under [anchor] aligned to its end
/// edge, above when there is no room; the first item is focused ([fromEnd]: the last), arrows wrap, Home, End and
/// type-ahead move, Enter and Space choose; Escape, Tab and an outside press close it, and focus returns to
/// [anchor]. [barrierLabel] names an invisible full-screen control behind the panel that closes it, for a screen
/// reader; without one, it carries no label.
abstract final class Menu {
  /// Shows a menu of [items] anchored to [anchor]'s own render box.
  static Future<void> show(
    BuildContext anchor, {
    required List<MenuItem> items,
    String? barrierLabel,
    bool fromEnd = false,
  }) {
    final anchorBox = anchor.findRenderObject();
    if (anchorBox is! RenderBox || !anchorBox.attached) return Future<void>.value();
    final opener = FocusManager.instance.primaryFocus;
    return showTsuyaOverlay<void>(
      context: anchor,
      modal: false,
      anchorBox: anchorBox,
      transitionDuration: TsuyaDuration.fast,
      builder: (context, animation, wrap, close) {
        void afterClose() {
          if (opener != null && (opener.context?.mounted ?? false)) opener.requestFocus();
          close();
        }

        return Stack(
          children: [
            if (barrierLabel != null)
              Positioned.fill(
                child: Semantics(
                  button: true,
                  label: barrierLabel,
                  child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: afterClose),
                ),
              ),
            AnchoredPanel(
              anchor: anchorBox,
              align: AnchorAlign.end,
              estimate: _estimate(items),
              minWidth: 220,
              opacity: animation,
              wrap: wrap,
              child: _MenuPanel(
                items: items,
                fromEnd: fromEnd,
                onChoose: (item) {
                  afterClose();
                  item.onSelect?.call();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// One entry of a [Menu]: an action (with [onSelect]), a [MenuItem.radio] option, a [MenuItem.label] over a few
/// items, or [MenuItem.separator] between groups.
@immutable
class MenuItem {
  /// An action labelled [label]; [onSelect] runs after the menu has closed and focus has returned to its opener.
  const MenuItem({
    required this.label,
    required this.onSelect,
    this.icon,
    this.shortcut,
    this.checked,
    this.destructive = false,
    this.disabled = false,
  }) : radio = false,
       heading = false,
       separator = false;

  /// An option of which one in a run of radio items is [checked], announced as a radio menu item and ticked at the end
  /// when it is. Choosing it runs [onSelect] (the caller moves the check), after the menu has closed.
  const MenuItem.radio({
    required this.label,
    required this.onSelect,
    required bool this.checked,
    this.icon,
    this.shortcut,
    this.disabled = false,
  }) : radio = true,
       heading = false,
       destructive = false,
       separator = false;

  /// A heading over a few items, in [TsuyaType.caption] and [TsuyaColors.textMuted]. It is not an item: focus,
  /// arrows and type-ahead pass it, and it cannot be chosen.
  const MenuItem.label(this.label)
    : onSelect = null,
      icon = null,
      shortcut = null,
      checked = null,
      destructive = false,
      disabled = false,
      radio = false,
      heading = true,
      separator = false;

  /// A hairline between groups of items, as before a [destructive] one.
  const MenuItem.separator()
    : label = '',
      onSelect = null,
      icon = null,
      shortcut = null,
      checked = null,
      destructive = false,
      disabled = false,
      radio = false,
      heading = false,
      separator = true;

  /// The item's label; read by a screen reader, matched by type-ahead.
  final String label;

  /// Called after the menu has closed; null for a separator.
  final VoidCallback? onSelect;

  /// Before the label, in [TsuyaColors.textMuted].
  final Widget? icon;

  /// Shown at the end in [TsuyaType.mono]; seen, not read.
  final String? shortcut;

  /// Ticked at the end when true, and announced as a checkbox item (a radio item for [MenuItem.radio]) when not null.
  final bool? checked;

  /// In [TsuyaColors.danger]; put it last, after a [MenuItem.separator].
  final bool destructive;

  /// Takes focus but cannot be chosen.
  final bool disabled;

  /// Whether this is a [MenuItem.radio] option.
  final bool radio;

  /// Whether this is a [MenuItem.label] heading rather than an item.
  final bool heading;

  /// Whether this is [MenuItem.separator] rather than an action.
  final bool separator;

  /// Whether it is an entry that takes focus and can be chosen, rather than a [MenuItem.separator] or a
  /// [MenuItem.label].
  bool get isItem => !separator && !heading;
}

class _MenuPanel extends StatefulWidget {
  const _MenuPanel({required this.items, required this.fromEnd, required this.onChoose});

  final List<MenuItem> items;
  final bool fromEnd;
  final ValueChanged<MenuItem> onChoose;

  @override
  State<_MenuPanel> createState() => _MenuPanelState();
}

class _MenuPanelState extends State<_MenuPanel> {
  bool _focused = false;

  List<int> get _focusable => [
    for (var i = 0; i < widget.items.length; i++)
      if (widget.items[i].isItem) i,
  ];

  void _focusFirst(List<FocusNode> nodes) {
    if (_focused || nodes.isEmpty) return;
    _focused = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) (widget.fromEnd ? nodes.last : nodes.first).requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final focusable = _focusable;
    return Semantics(
      role: SemanticsRole.menu,
      explicitChildNodes: true,
      child: RovingFocus(
        count: focusable.length,
        axis: Axis.vertical,
        labelOf: (i) => widget.items[focusable[i]].label,
        disabledOf: (i) => widget.items[focusable[i]].disabled,
        disabledFocusable: true,
        builder: (context, nodes, active) {
          _focusFirst(nodes);
          var next = 0;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final item in widget.items)
                if (item.separator)
                  const _MenuSeparatorRow()
                else if (item.heading)
                  _MenuLabelRow(label: item.label)
                else
                  _MenuItemRow(item: item, focusNode: nodes[next++], onChoose: () => widget.onChoose(item)),
            ],
          );
        },
      ),
    );
  }
}

class _ChooseIntent extends Intent {
  const _ChooseIntent();
}

/// One action, checkbox or radio row of a [Menu], managed by its [RovingFocus]: [focusNode] is the node
/// [Menu] already built for it; this only draws the row and answers Enter, Space and a press by calling [onChoose]
/// (ignored while [MenuItem.disabled], which still lets the row take focus). An icon in text-muted, the label, a
/// shortcut in mono (seen, not read) and a tick when checked; destructive in danger; filled on hover or press, ringed
/// on focus.
class _MenuItemRow extends StatefulWidget {
  /// A row for [item], focused through [focusNode].
  const _MenuItemRow({required this.item, required this.focusNode, required this.onChoose});

  /// What the row shows and announces.
  final MenuItem item;

  /// The node [RovingFocus] manages for this row.
  final FocusNode focusNode;

  /// Called on a choice; not called while [MenuItem.disabled].
  final VoidCallback onChoose;

  @override
  State<_MenuItemRow> createState() => _MenuItemRowState();
}

class _MenuItemRowState extends State<_MenuItemRow> {
  static const _keys = <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.enter): _ChooseIntent(),
    SingleActivator(LogicalKeyboardKey.numpadEnter): _ChooseIntent(),
    SingleActivator(LogicalKeyboardKey.space): _ChooseIntent(),
  };

  bool _hovered = false;
  bool _focused = false;

  void _choose() {
    if (!widget.item.disabled) widget.onChoose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final theme = TsuyaTheme.of(context);
    final colors = theme.colors;
    final content = item.destructive ? colors.danger : colors.text;
    final highlight = _hovered;
    return Semantics(
      role: switch ((item.checked, item.radio)) {
        (null, _) => SemanticsRole.menuItem,
        (_, true) => SemanticsRole.menuItemRadio,
        (_, false) => SemanticsRole.menuItemCheckbox,
      },
      label: item.label,
      checked: item.checked,
      inMutuallyExclusiveGroup: item.radio ? true : null,
      enabled: !item.disabled,
      child: FocusRing(
        focused: _focused,
        borderRadius: BorderRadius.circular(TsuyaRadius.sm),
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: item.disabled ? null : _choose,
            // Shortcuts looks up the tree from the focused widget for a Shortcuts ancestor: it has to sit above
            // Focus, not below it, or Enter and Space on this row's own node never reach it.
            child: Shortcuts(
              shortcuts: _keys,
              child: Actions(
                actions: {_ChooseIntent: CallbackAction<_ChooseIntent>(onInvoke: (_) => _choose())},
                child: Focus(
                  focusNode: widget.focusNode,
                  onFocusChange: (focused) => setState(() => _focused = focused),
                  child: Opacity(
                    opacity: item.disabled ? TsuyaState.disabledOpacity : 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: highlight ? colors.fill : null,
                        borderRadius: BorderRadius.circular(TsuyaRadius.sm),
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: TsuyaSize.controlMd),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: TsuyaSpace.s12),
                          child: Row(
                            children: [
                              if (item.icon != null) ...[
                                ExcludeSemantics(
                                  child: IconTheme(
                                    data: IconThemeData(color: colors.textMuted, size: TsuyaSize.icon),
                                    child: item.icon!,
                                  ),
                                ),
                                const SizedBox(width: TsuyaSpace.s12),
                              ],
                              Expanded(
                                child: ExcludeSemantics(
                                  child: Text(
                                    item.label,
                                    style: theme.text(TsuyaType.body).copyWith(color: content),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              if (item.shortcut != null) ...[
                                const SizedBox(width: TsuyaSpace.s12),
                                ExcludeSemantics(
                                  child: Text(
                                    item.shortcut!,
                                    style: theme.text(TsuyaType.mono).copyWith(color: colors.textMuted),
                                  ),
                                ),
                              ],
                              if (item.checked ?? false) ...[
                                const SizedBox(width: TsuyaSpace.s12),
                                ExcludeSemantics(
                                  child: Glyph(TsuyaGlyph.check, size: TsuyaSize.iconSm, color: content),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A hairline between groups of items of a [Menu], as before a destructive one.
class _MenuSeparatorRow extends StatelessWidget {
  /// A separator row.
  const _MenuSeparatorRow();

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: TsuyaSpace.s4),
      color: TsuyaTheme.of(context).colors.border,
    ),
  );
}

/// A heading over a few items of a [Menu]: [TsuyaType.caption] in [TsuyaColors.textMuted]. Not an item: it
/// is no stop of the roving focus, and a press on it does nothing.
class _MenuLabelRow extends StatelessWidget {
  /// A heading reading [label].
  const _MenuLabelRow({required this.label});

  /// The heading.
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(TsuyaSpace.s12, TsuyaSpace.s8, TsuyaSpace.s12, TsuyaSpace.s4),
      // at the start edge, in line with the items' labels, whatever the panel's alignment of its rows
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(label, style: theme.text(TsuyaType.caption).copyWith(color: theme.colors.textMuted)),
      ),
    );
  }
}
