// The navigation of a desktop shell (DESIGN.md, Sidebar).
//
// Collapsed, an item's label (and a group's) stays only as its accessible name (`Pressable.label` /
// `Semantics.label`), not drawn at all, and shows as a Tooltip at the item's end, as on Svelte. The Tooltip is
// always there, enabled only while collapsed, so an item that collapses its sidebar keeps its place in the tree
// and its focus.
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import '../foundation/anchored_position.dart';
import '../foundation/pressable.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import '../foundation/touch_platform.dart';
import 'tooltip.dart';

/// The sidebar's width (DESIGN.md, Sidebar).
const _kWidth = 240.0;

/// Its collapsed width, icons only (DESIGN.md, Sidebar).
const _kCollapsedWidth = 72.0;

class _SidebarScope extends InheritedWidget {
  const _SidebarScope({required this.collapsed, required super.child});

  final bool collapsed;

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_SidebarScope>()?.collapsed ?? false;

  @override
  bool updateShouldNotify(_SidebarScope oldWidget) => collapsed != oldWidget.collapsed;
}

/// The navigation of a desktop shell (DESIGN.md, Sidebar): [_kWidth] wide, [TsuyaSpace.s12] around its [children]
/// ([SidebarItem]s and [SidebarGroup]s); it replaces the tab bar from [TsuyaBreakpoint.desktop] wide. [collapsed],
/// it shows icons only, [_kCollapsedWidth] wide.
class Sidebar extends StatelessWidget {
  /// A sidebar over [children], named [label] for screen readers.
  const Sidebar({super.key, this.collapsed = false, this.label, required this.children});

  /// Shows the icons only, [_kCollapsedWidth] wide.
  final bool collapsed;

  /// The sidebar's own accessible name, if it needs one.
  final String? label;

  /// [SidebarItem]s and [SidebarGroup]s, in order.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final gapped = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        // two groups in a row keep an extra space-16 apart; anything else, just the base gap.
        final extra = children[i] is SidebarGroup && children[i - 1] is SidebarGroup;
        gapped.add(SizedBox(height: TsuyaSpace.s4 + (extra ? TsuyaSpace.s16 : 0)));
      }
      gapped.add(children[i]);
    }
    return _SidebarScope(
      collapsed: collapsed,
      child: Semantics(
        container: true,
        role: SemanticsRole.navigation,
        label: label,
        child: SizedBox(
          width: collapsed ? _kCollapsedWidth : _kWidth,
          child: Padding(
            padding: const EdgeInsets.all(TsuyaSpace.s12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: gapped),
          ),
        ),
      ),
    );
  }
}

/// A group of [SidebarItem]s under its [label] (DESIGN.md, Sidebar), in [TsuyaType.label]; collapsed, the label
/// is read only.
class SidebarGroup extends StatelessWidget {
  /// A group named [label] over [children].
  const SidebarGroup({super.key, required this.label, required this.children});

  /// The group's heading, shown above [children] and naming the group for screen readers.
  final String label;

  /// The group's [SidebarItem]s, in order.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final collapsed = _SidebarScope.of(context);
    final theme = TsuyaTheme.of(context);
    return Semantics(
      container: true,
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!collapsed)
            Padding(
              padding: const EdgeInsets.fromLTRB(TsuyaSpace.s12, TsuyaSpace.s8, TsuyaSpace.s12, TsuyaSpace.s4),
              child: ExcludeSemantics(
                child: Text(label, style: theme.text(TsuyaType.label).copyWith(color: theme.colors.textMuted)),
              ),
            ),
          for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(height: TsuyaSpace.s4), children[i]],
        ],
      ),
    );
  }
}

/// A sidebar item (DESIGN.md, Sidebar): [TsuyaSize.controlSm] tall ([TsuyaSize.target] on touch),
/// [TsuyaRadius.sm], [icon] and [label] in [TsuyaType.control] [TsuyaColors.textMuted], [count] at the end; the
/// [current] one in [TsuyaColors.text] on [TsuyaColors.fillStrong]. Collapsed, the icon only, still named [label]
/// ([count] is left out while collapsed, drawn and named alike); its label shows as a [Tooltip] at its end.
class SidebarItem extends StatelessWidget {
  /// An item labelled [label], shown over [icon], [current] when it names the page already shown.
  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    this.count,
    this.current = false,
    this.onPressed,
  });

  /// Drawn at [TsuyaSize.icon].
  final Widget icon;

  /// The item's label: shown unless the sidebar is collapsed, and always its accessible name (with [count], when
  /// there is one: "Albums 12").
  final String label;

  /// A number at the end (such as unread items); hidden, but not its own name, while collapsed.
  final int? count;

  /// Whether it names the page already shown.
  final bool current;

  /// Called on a press; null disables it.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final collapsed = _SidebarScope.of(context);
    final theme = TsuyaTheme.of(context);
    final colors = theme.colors;
    final radius = BorderRadius.circular(TsuyaRadius.sm);
    final content = current ? colors.text : colors.textMuted;
    final count = this.count;
    final accessibleLabel = collapsed || count == null ? label : '$label $count';
    return Tooltip(
      message: label,
      side: AnchorSide.end,
      // it repeats the item's own name
      describe: false,
      enabled: collapsed,
      child: Pressable(
        onPressed: onPressed,
        selected: current,
        label: accessibleLabel,
        borderRadius: radius,
        feedback: PressFeedback.highlight,
        // the height is the drawing's own, inside Pressable: its minimum is a target that centres what is drawn
        child: DecoratedBox(
          decoration: BoxDecoration(color: current ? colors.fillStrong : null, borderRadius: radius),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: touchPlatform ? TsuyaSize.target : TsuyaSize.controlSm),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: TsuyaSpace.s12),
              child: ExcludeSemantics(
                child: Row(
                  mainAxisAlignment: collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                  children: [
                    IconTheme(
                      data: IconThemeData(size: TsuyaSize.icon, color: content),
                      child: icon,
                    ),
                    if (!collapsed) ...[
                      const SizedBox(width: TsuyaSpace.s12),
                      Expanded(
                        child: Text(
                          label,
                          style: theme.text(TsuyaType.control).copyWith(color: content),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (count != null)
                        Text(
                          '$count',
                          style: theme
                              .text(TsuyaType.control)
                              .copyWith(color: content, fontFeatures: const [FontFeature.tabularFigures()]),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
