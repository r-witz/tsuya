// Content that rises from the bottom, or comes from the end edge (DESIGN.md, Sheet).
import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import '../foundation/modal_scrim.dart';
import '../foundation/motion.dart';
import '../foundation/overlay_show.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import '../material/glass.dart';

/// Where a [Sheet] comes from.
enum SheetSide {
  /// Rises from the bottom, at most tablet wide: the phone's sheet.
  bottom,

  /// Comes from the end edge (the right, or the left in right-to-left), 400 wide and full height: a desktop panel.
  end,
}

// a drag down past a third of the sheet's height closes it.
const _commitFraction = 1 / 3;

// "a fling" has no set speed; the Svelte Sheet commits past 0.5 px/ms, here 500 px/s.
const _flingVelocity = 500.0;

// the side variant is 400 wide.
const _sideWidth = 400.0;

class _SheetScope extends InheritedWidget {
  const _SheetScope({required this.side, required super.child});

  final SheetSide side;

  @override
  bool updateShouldNotify(_SheetScope oldWidget) => side != oldWidget.side;
}

/// Content that rises from the bottom (DESIGN.md, Sheet): a box with its top corners [TsuyaRadius.lg], a handle
/// to drag down on touch, and [child] padded [TsuyaSpace.s24]; on glass when [glass], the surface otherwise. Show
/// it with [Sheet.show], which also gives it its scrim, Escape and press-outside dismissal, and its focus trap.
/// [label] names it for a screen reader.
class Sheet extends StatefulWidget {
  /// A sheet named [label] showing [child].
  const Sheet({super.key, required this.label, required this.child, this.glass = false});

  /// The accessible name: what the sheet is about.
  final String label;

  /// The sheet's content.
  final Widget child;

  /// Glass instead of the surface, for a sheet that opens from glass.
  final bool glass;

  /// Shows [builder]'s sheet above everything, over a scrim, sliding in over [TsuyaDuration.sheet]; completes with
  /// what [close] gives, or null once dismissed (Escape, a press on the scrim, a drag down on touch). [side]
  /// chooses the bottom sheet or the desktop panel. [barrierLabel] names the scrim for a screen reader.
  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    String? barrierLabel,
    SheetSide side = SheetSide.bottom,
  }) => showTsuyaOverlay<T>(
    context: context,
    transitionDuration: TsuyaDuration.sheet,
    builder: (context, animation, wrap, close) {
      final slide = animation.drive(CurveTween(curve: TsuyaEasing.emphasized));
      return _SheetScope(
        side: side,
        child: Stack(
          children: [
            ModalScrim(opacity: slide, barrierLabel: barrierLabel, onDismiss: close),
            LayoutBuilder(
              builder: (context, constraints) {
                final inset = MediaQuery.viewInsetsOf(context).bottom;
                final panel = wrap(
                  SlideTransition(
                    position: slide.drive(
                      Tween(
                        begin: side == SheetSide.bottom ? const Offset(0, 1) : const Offset(1, 0),
                        end: Offset.zero,
                      ),
                    ),
                    textDirection: Directionality.of(context),
                    child: Builder(builder: builder),
                  ),
                );
                if (side == SheetSide.end) {
                  return Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: SizedBox(width: _sideWidth, height: constraints.maxHeight, child: panel),
                  );
                }
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: inset),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: TsuyaBreakpoint.tablet,
                        maxHeight: constraints.maxHeight - inset - TsuyaSpace.s48,
                      ),
                      child: panel,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    },
  );

  /// Closes the sheet [context] belongs to, completing [Sheet.show]'s future with [result].
  static void close<T>(BuildContext context, [T? result]) => closeTsuyaOverlay(context, result);

  @override
  State<Sheet> createState() => _SheetState();
}

class _SheetState extends State<Sheet> {
  double _drag = 0;
  bool _dragging = false;
  double? _startY;
  VelocityTracker? _tracker;
  double _height = 0;

  void _down(PointerDownEvent event) {
    // a touch or a pen drags; a mouse does not (DESIGN.md, Sheet)
    if (event.kind == PointerDeviceKind.mouse) return;
    _startY = event.position.dy;
    _tracker = VelocityTracker.withKind(event.kind)..addPosition(event.timeStamp, event.position);
    _height = context.size?.height ?? 0;
    setState(() => _dragging = true);
  }

  void _move(PointerMoveEvent event) {
    final start = _startY;
    if (start == null) return;
    _tracker?.addPosition(event.timeStamp, event.position);
    setState(() => _drag = (event.position.dy - start).clamp(0, double.infinity));
  }

  void _end(PointerEvent event) {
    final start = _startY;
    final tracker = _tracker;
    if (start == null || tracker == null) return;
    final distance = (event.position.dy - start).clamp(0, double.infinity);
    final commit =
        event is PointerUpEvent &&
        (distance > _height * _commitFraction || tracker.getVelocity().pixelsPerSecond.dy > _flingVelocity);
    _startY = null;
    _tracker = null;
    // committed: the sheet leaves from where the finger left it; otherwise it snaps back
    setState(() {
      _dragging = false;
      if (!commit) _drag = 0;
    });
    if (commit) closeTsuyaOverlay(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    final colors = theme.colors;
    final scope = context.getInheritedWidgetOfExactType<_SheetScope>();
    final side = scope?.side ?? SheetSide.bottom;
    final bottom = side == SheetSide.bottom;
    final radius = bottom ? const BorderRadius.vertical(top: Radius.circular(TsuyaRadius.lg)) : BorderRadius.zero;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final body = Flexible(
      child: SingleChildScrollView(
        padding: bottom
            ? EdgeInsets.fromLTRB(TsuyaSpace.s24, 0, TsuyaSpace.s24, TsuyaSpace.s32 + safeBottom)
            : const EdgeInsets.all(TsuyaSpace.s24),
        child: widget.child,
      ),
    );
    final content = Column(
      mainAxisSize: bottom ? MainAxisSize.min : MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (bottom)
          ExcludeSemantics(
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: scope == null ? null : _down,
              onPointerMove: _move,
              onPointerUp: _end,
              onPointerCancel: _end,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: TsuyaSpace.s12),
                child: Center(
                  child: SizedBox(
                    width: TsuyaSpace.s32,
                    height: TsuyaSpace.s4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.borderStrong,
                        borderRadius: BorderRadius.circular(TsuyaRadius.full),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        body,
      ],
    );
    final box = widget.glass
        ? Glass(borderRadius: radius, shadow: GlassShadow.lg, child: content)
        : DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: radius,
              border: Border.all(color: colors.border, strokeAlign: BorderSide.strokeAlignOutside),
              boxShadow: theme.shadows.lg,
            ),
            child: content,
          );
    return Semantics(
      role: SemanticsRole.dialog,
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: widget.label,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: _drag),
        duration: _dragging ? Duration.zero : motionOf(context, TsuyaDuration.fast),
        curve: TsuyaEasing.standard,
        builder: (context, offset, child) => Transform.translate(offset: Offset(0, offset), child: child),
        child: box,
      ),
    );
  }
}
