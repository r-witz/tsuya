// The app bar of a website or a desktop app (DESIGN.md, TopBar, ScreenBar).
//
// The Svelte `links` carry an `href`; Flutter has no routing opinion at this layer, so a link is named and
// fires a callback instead (`onPressed`), as every other control in this package does.
//
// Below the tablet width the links move into a menu from a plain icon button, as DESIGN.md asks: a Popover, at the
// end of the button, as Svelte's `Popover.Root` and `Popover.Content`.

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../foundation/anchored_position.dart';
import '../foundation/labels.dart';
import '../foundation/overlay_show.dart';
import '../foundation/pressable.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import '../foundation/touch_platform.dart';
import '../material/glass.dart';
import 'glyphs.dart';
import 'icon_button.dart';
import 'popover.dart';

// The menu's rows, 220 wide with the popover's own padding around them.
const _kMenuWidth = 220 - 2 * TsuyaSpace.s16;

/// A navigation link of a [TopBar]: labelled [label], [current] when it names the page already shown.
@immutable
class TopBarLink {
  /// A link labelled [label], firing [onPressed].
  const TopBarLink({required this.label, this.current = false, required this.onPressed});

  /// The link's accessible name and visible text.
  final String label;

  /// Whether it names the page already shown: [TsuyaColors.fillStrong], [TsuyaColors.text].
  final bool current;

  /// Called when the link is pressed.
  final VoidCallback onPressed;
}

/// The app bar of a website or a desktop app (DESIGN.md, TopBar): glass, at least [TsuyaSize.bar] tall,
/// [TsuyaRadius.md], floating [TsuyaSpace.s12] from the top and sides, [TsuyaShadows.md]. [start] (a brand or a
/// back button), [links], [center] (a search field) and [end] (icon buttons). Below [TsuyaBreakpoint.tablet] the
/// links move into a menu opened from a plain icon button at the end, named by the `more` label. Too wide for the
/// room (a large text scale), the links and [center] scroll sideways. When [start] and [end] do not fit side by side, the bar grows rows instead:
/// [start], [end], then the links and [center].
class TopBar extends StatefulWidget {
  /// A bar with [start], [links], [center] and [end].
  const TopBar({super.key, this.start, this.links, this.center, this.end});

  /// A brand or a back button, at the start.
  final Widget? start;

  /// Navigation links, centred; below [TsuyaBreakpoint.tablet], in a menu at the end instead.
  final List<TopBarLink>? links;

  /// A search field, centred alongside [links].
  final Widget? center;

  /// Icon buttons, at the end.
  final Widget? end;

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  final _triggerKey = GlobalKey();
  final _triggerFocus = FocusNode(debugLabel: 'TopBar menu button');
  // What closes the open menu: from a link, or when the button goes away.
  VoidCallback? _closeMenu;
  bool _open = false;
  bool _openAtPointerDown = false;

  // set as the bar is laid out: the width it is given, its container's (DESIGN.md, Layout), as the web reads it
  bool _narrow = false;

  @override
  void dispose() {
    _closeMenu?.call();
    _triggerFocus.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_openAtPointerDown) {
      // an outside press already closed the menu as the pointer went down: the button toggles
      _openAtPointerDown = false;
      return;
    }
    _open ? _closeMenu?.call() : _show();
  }

  void _show() {
    final anchor = _triggerKey.currentContext;
    if (anchor == null) return;
    // requested here so the button reliably has the focus for the popover to give it back
    _triggerFocus.requestFocus();
    setState(() => _open = true);
    Popover.show(
      anchor,
      label: TsuyaLabels.of(context).more,
      align: AnchorAlign.end,
      builder: (menuContext) {
        _closeMenu = tsuyaOverlayCloser(menuContext);
        return Semantics(
          container: true,
          role: SemanticsRole.navigation,
          child: SizedBox(
            width: _kMenuWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final link in widget.links!)
                  _TopBarLinkRow(
                    link: link,
                    menu: true,
                    onPressed: () {
                      link.onPressed();
                      _closeMenu?.call();
                      _triggerFocus.requestFocus();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      _closeMenu = null;
      if (mounted) setState(() => _open = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final links = widget.links;
    return LayoutBuilder(builder: (context, constraints) => _bar(links, constraints.maxWidth));
  }

  Widget _bar(List<TopBarLink>? links, double width) {
    final narrow = links != null && width < TsuyaBreakpoint.tablet;
    // the button is the menu's anchor: gone, the menu goes with it
    if (_narrow && !narrow) _closeMenu?.call();
    _narrow = narrow;
    return Container(
      margin: const EdgeInsets.fromLTRB(TsuyaSpace.s12, TsuyaSpace.s12, TsuyaSpace.s12, 0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: TsuyaSize.bar),
        child: Glass(
          borderRadius: BorderRadius.circular(TsuyaRadius.md),
          shadow: GlassShadow.md,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: TsuyaSpace.s12),
            child: _TopBarLayout(
              hasMiddle: (links != null && !narrow) || widget.center != null,
              start: widget.start ?? const SizedBox.shrink(),
              // Wider than the room, the links and the centre scroll sideways; centred when they fit.
              middle: LayoutBuilder(
                builder: (context, box) => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: box.maxWidth),
                    child: Center(
                      heightFactor: 1,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (links != null && !narrow)
                            Semantics(
                              container: true,
                              role: SemanticsRole.navigation,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (var i = 0; i < links.length; i++) ...[
                                    if (i > 0) const SizedBox(width: TsuyaSpace.s4),
                                    _TopBarLinkRow(link: links[i], menu: false, onPressed: links[i].onPressed),
                                  ],
                                ],
                              ),
                            ),
                          if (widget.center != null) widget.center!,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              end: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.end != null) widget.end!,
                  if (links != null)
                    // Always there (empty when wide): the menu's anchor stays in the tree as the layout changes.
                    Shortcuts(
                      // Escape on the button while the menu is open (a press leaves the focus there)
                      shortcuts: {if (_open) const SingleActivator(LogicalKeyboardKey.escape): const DismissIntent()},
                      // declared only while open, or Escape meant for a layer around the bar would stop here
                      child: Actions(
                        actions: {
                          if (_open)
                            DismissIntent: CallbackAction<DismissIntent>(
                              onInvoke: (_) {
                                _closeMenu?.call();
                                return null;
                              },
                            ),
                        },
                        child: Listener(
                          key: _triggerKey,
                          onPointerDown: (_) => _openAtPointerDown = _open,
                          child: narrow
                              ? IconButton(
                                  focusNode: _triggerFocus,
                                  icon: const Glyph(TsuyaGlyph.menu),
                                  label: TsuyaLabels.of(context).more,
                                  kind: IconButtonKind.plain,
                                  expanded: _open,
                                  onPressed: _toggle,
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The three parts of a [TopBar]: the start (a brand), the middle (links, a search field) and the end (buttons), in
/// that order, on one row: the start and the end at their own width, the middle taking what is left. When the start
/// and the end do not fit together (a labelled button at a large text scale on a narrow screen) the bar grows to
/// rows instead, the start, the end, then the middle, each as wide as the bar (nothing overflows).
class _TopBarLayout extends MultiChildRenderObjectWidget {
  /// A layout of [start], [middle] and [end]; [hasMiddle] says whether [middle] shows anything.
  _TopBarLayout({required this.hasMiddle, required Widget start, required Widget middle, required Widget end})
    : super(children: [start, middle, end]);

  /// Whether the middle takes room; when not, it takes no row of its own.
  final bool hasMiddle;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderTopBarLayout(Directionality.of(context), hasMiddle);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) => (renderObject as _RenderTopBarLayout)
    ..textDirection = Directionality.of(context)
    ..hasMiddle = hasMiddle;
}

class _RenderTopBarLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  _RenderTopBarLayout(this._textDirection, this._hasMiddle);

  TextDirection _textDirection;
  bool _hasMiddle;

  set hasMiddle(bool value) {
    if (value == _hasMiddle) return;
    _hasMiddle = value;
    markNeedsLayout();
  }

  set textDirection(TextDirection value) {
    if (value == _textDirection) return;
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MultiChildLayoutParentData) child.parentData = MultiChildLayoutParentData();
  }

  // Lays the parts out, through [layout] (a real or a dry layout), and returns the bar's size; [place] says where
  // each part goes, in left-to-right x.
  Size _layout(
    BoxConstraints constraints,
    Size Function(RenderBox, BoxConstraints) layout, [
    void Function(RenderBox, Offset)? place,
  ]) {
    final start = firstChild!;
    final middle = childAfter(start)!;
    final end = childAfter(middle)!;
    final width = constraints.maxWidth;
    final loose = BoxConstraints(maxWidth: width, maxHeight: constraints.maxHeight);
    final startSize = layout(start, loose);
    final endSize = layout(end, loose);
    final oneRow = startSize.width + endSize.width <= width;
    final hasMiddle = _hasMiddle;
    final middleWidth = oneRow ? width - startSize.width - endSize.width : width;
    final middleSize = hasMiddle
        ? layout(middle, BoxConstraints(minWidth: middleWidth, maxWidth: middleWidth, maxHeight: constraints.maxHeight))
        : layout(middle, BoxConstraints.tight(Size.zero));
    if (oneRow) {
      final height = constraints.constrainHeight(
        [startSize.height, endSize.height, middleSize.height].reduce((a, b) => a > b ? a : b),
      );
      place?.call(start, Offset(0, (height - startSize.height) / 2));
      place?.call(middle, Offset(startSize.width, (height - middleSize.height) / 2));
      place?.call(end, Offset(width - endSize.width, (height - endSize.height) / 2));
      return Size(width, height);
    }
    // rows: the start at the start edge, the end at the end edge, the middle, if any, below
    const pad = (TsuyaSize.bar - TsuyaSize.target) / 2;
    final rows = [
      (start, startSize, 0.0),
      (end, endSize, width - endSize.width),
      if (hasMiddle) (middle, middleSize, 0.0),
    ];
    var y = pad;
    for (final (child, size, x) in rows) {
      place?.call(child, Offset(x, y));
      y += size.height + TsuyaSpace.s8;
    }
    return Size(width, constraints.constrainHeight(y - TsuyaSpace.s8 + pad));
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) => _layout(constraints, (child, c) => child.getDryLayout(c));

  @override
  void performLayout() {
    size = _layout(
      constraints,
      (child, c) {
        child.layout(c, parentUsesSize: true);
        return child.size;
      },
      (child, offset) => (child.parentData! as MultiChildLayoutParentData).offset = Offset(
        _textDirection == TextDirection.rtl ? constraints.maxWidth - offset.dx - child.size.width : offset.dx,
        offset.dy,
      ),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) => defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}

/// One link of a [TopBar]: a row of [TsuyaSize.controlSm] ([TsuyaSize.target] on touch) in the bar, of
/// [TsuyaSize.controlMd] and the full width in the menu. The fill is drawn by the row itself, inside the
/// [Pressable], so it is as tall as the row and not just as the text.
class _TopBarLinkRow extends StatelessWidget {
  /// A row for [link], [menu] when it is in the menu rather than the bar.
  const _TopBarLinkRow({required this.link, required this.menu, required this.onPressed});

  /// The link shown.
  final TopBarLink link;

  /// Whether it is in the menu.
  final bool menu;

  /// Called on a press.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    final colors = theme.colors;
    final radius = BorderRadius.circular(TsuyaRadius.sm);
    final minHeight = menu
        ? TsuyaSize.controlMd
        : touchPlatform
        ? TsuyaSize.target
        : TsuyaSize.controlSm;
    return Pressable(
      onPressed: onPressed,
      selected: link.current,
      borderRadius: radius,
      feedback: PressFeedback.highlight,
      child: DecoratedBox(
        decoration: BoxDecoration(color: link.current ? colors.fillStrong : null, borderRadius: radius),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: TsuyaSpace.s12),
            // in the menu, as wide as the list (Pressable loosens what it is given); in the bar, as wide as the text
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: menu ? null : 1,
              heightFactor: 1,
              child: Text(
                link.label,
                style: theme
                    .text(menu ? TsuyaType.body : TsuyaType.control)
                    .copyWith(color: link.current ? colors.text : colors.textMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
