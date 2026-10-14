// The menu panel chrome (DESIGN.md, Menu), reused wherever a floating panel of rows is needed before
// the Menu component itself exists (the text field's own context menu, Select, Combobox), and the panel anchored to
// the control that opens it: a menu's, a popover's, a select's and a combobox's.
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../foundation/anchored_position.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import '../material/glass.dart';

/// The menu panel chrome (DESIGN.md, Menu): [TsuyaRadius.md], [padding] ([TsuyaSpace.s4]) around [child], a surface
/// with a hairline and [TsuyaShadows.lg], or glass when [glass]. Shared by [Select], [Combobox] and the text
/// field's own context menu.
Widget menuPanel(BuildContext context, {required Widget child, bool glass = false, double padding = TsuyaSpace.s4}) {
  final theme = TsuyaTheme.of(context);
  const radius = BorderRadius.all(Radius.circular(TsuyaRadius.md));
  final padded = Padding(padding: EdgeInsets.all(padding), child: child);
  if (glass) return Glass(borderRadius: radius, shadow: GlassShadow.lg, child: padded);
  return DecoratedBox(
    decoration: BoxDecoration(
      color: theme.colors.surface,
      borderRadius: radius,
      border: Border.all(color: theme.colors.border, strokeAlign: BorderSide.strokeAlignOutside),
      boxShadow: theme.shadows.lg,
    ),
    child: padded,
  );
}

/// A [menuPanel] of [child] against [anchor], positioned in the overlay's stack: [anchoredPosition] places it on
/// [side], lined up by [align], no taller than the room there and no wider than the view less its margins. A panel
/// with an [estimate] takes its content's size (a menu's, a popover's), at least [minWidth] wide when given: placed
/// by [estimate] until its first frame measures it. One without is as wide as [anchor] (a select's, a combobox's
/// listbox, which scrolls) and placed as if 320 tall. [wrap] goes around the panel inside its position (the
/// overlay's layer, or a dismissable one), and [opacity] fades it.
class AnchoredPanel extends StatefulWidget {
  /// A panel of [child] against [anchor].
  const AnchoredPanel({
    super.key,
    required this.anchor,
    required this.child,
    this.side = AnchorSide.bottom,
    this.align = AnchorAlign.start,
    this.estimate,
    this.minWidth,
    this.padding = TsuyaSpace.s4,
    this.opacity,
    this.wrap,
  });

  /// The box of the control that opens the panel.
  final RenderBox anchor;

  /// The panel's content.
  final Widget child;

  /// The side of [anchor] the panel prefers.
  final AnchorSide side;

  /// How the panel lines up with [anchor] along that side.
  final AnchorAlign align;

  /// The panel's size until it is measured, for a panel that takes its content's size.
  final Size? estimate;

  /// The least width of a panel that takes its content's size, which is then as wide as its widest row.
  final double? minWidth;

  /// Around [child], inside the chrome.
  final double padding;

  /// Fades the panel.
  final Animation<double>? opacity;

  /// Goes around the panel, inside its position.
  final Widget Function(Widget panel)? wrap;

  @override
  State<AnchoredPanel> createState() => _AnchoredPanelState();
}

class _AnchoredPanelState extends State<AnchoredPanel> {
  final _panelKey = GlobalKey();
  Size? _measured;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.estimate != null) WidgetsBinding.instance.addPostFrameCallback(_measure);
  }

  void _measure(Duration _) {
    final box = _panelKey.currentContext?.findRenderObject();
    if (!mounted || box is! RenderBox || !box.attached) return;
    if (box.size != _measured) setState(() => _measured = box.size);
  }

  @override
  Widget build(BuildContext context) {
    final anchor = widget.anchor.localToGlobal(Offset.zero) & widget.anchor.size;
    final viewport = MediaQuery.sizeOf(context);
    final maxWidth = anchoredMaxWidth(viewport);
    final estimate = widget.estimate;
    final size = estimate == null ? Size(math.min(anchor.width, maxWidth), 320) : _measured ?? estimate;
    final position = anchoredPosition(
      anchor: anchor,
      size: size,
      viewport: viewport,
      side: widget.side,
      alignment: widget.align,
      direction: Directionality.of(context),
    );
    Widget panel = menuPanel(context, padding: widget.padding, child: widget.child);
    if (estimate != null) panel = KeyedSubtree(key: _panelKey, child: panel);
    final opacity = widget.opacity;
    if (opacity != null) panel = FadeTransition(opacity: opacity, child: panel);
    final minWidth = widget.minWidth;
    // IntrinsicWidth both hugs the content and, in doing so, gives the Row inside each of a menu's rows a bounded
    // width to lay out its Expanded label against — Positioned leaves it unbounded.
    if (minWidth != null) panel = IntrinsicWidth(child: panel);
    panel = ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: position.maxHeight,
        minWidth: math.min(minWidth ?? 0, maxWidth),
        maxWidth: maxWidth,
      ),
      child: panel,
    );
    return Positioned(
      left: position.offset.dx,
      top: position.offset.dy,
      width: estimate == null ? size.width : null,
      child: widget.wrap?.call(panel) ?? panel,
    );
  }
}
