// The phone shell (DESIGN.md, TabBar, Screen).
//
// The dock floats as a true overlay (never leaving room for itself in the content's own flow), unlike the Svelte
// `position: sticky` dock, which only overlaps content while scrolling and clears it once the page's own flow runs
// out. To still land the same outcome (the last row rests clear of the dock, not forever behind it), `builder`'s
// padding reserves the dock's own height as laid out (it grows with the text scale), plus the
// space-24 of the Svelte Screen.
import 'package:flutter/widgets.dart';

import '../foundation/dock_inset.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import '../material/surface.dart';

/// The phone shell (DESIGN.md, Screen): a [TsuyaSurface] ([ambient] or the neutral glow, with [grain]); [builder]
/// builds the scrolling content, padded by the [EdgeInsets] it is given (the safe areas, the [TsuyaSpace.s20] side
/// margins, and room for [dock], at whatever height it takes); [dock] floats [TsuyaSpace.s12] from the edges above
/// the safe area, the content fading into [TsuyaColors.bg] under it. On Flutter, also the keyboard: the
/// content's own height shrinks by [MediaQuery.viewInsetsOf]'s bottom inset, so a focused field's own "scroll into
/// view" lands it above the keyboard instead of under it.
class Screen extends StatefulWidget {
  /// A shell lit by [ambient] (or the neutral glow without one), [builder] building the scrolling content,
  /// [dock] floating over it.
  const Screen({super.key, this.ambient, this.grain = GrainMode.bg, required this.builder, this.dock});

  /// The leading content's picture, lighting the top; without one, the neutral glow.
  final ImageProvider? ambient;

  /// Where the grain is drawn.
  final GrainMode grain;

  /// Builds the scrolling content (a [ListView] or a [CustomScrollView], say) padded by the given [EdgeInsets].
  /// Leave its own `controller` unset so it picks up the nearest [PrimaryScrollController] — the one [Screen]
  /// itself sets up — letting [dock]'s tab bar scroll it to the top.
  final Widget Function(BuildContext context, EdgeInsets padding) builder;

  /// A tab bar, floating over the content.
  final Widget? dock;

  @override
  State<Screen> createState() => _ScreenState();
}

const _content = #content;
const _dock = #dock;

class _ScreenState extends State<Screen> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = TsuyaTheme.of(context).colors;
    final safe = MediaQuery.paddingOf(context);
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final dock = widget.dock;
    return TsuyaSurface(
      ambient: widget.ambient,
      grain: widget.grain,
      child: PrimaryScrollController(
        controller: _controller,
        // PrimaryScrollController only reaches a controller-less scrollable on mobile platforms by default; the
        // dock's tap-to-top must work on desktop and web too.
        automaticallyInheritForPlatforms: TargetPlatform.values.toSet(),
        child: CustomMultiChildLayout(
          delegate: _ScreenLayout(keyboard: keyboard),
          children: [
            LayoutId(
              id: _content,
              // The layout hands the dock's height over in the constraints (see [_ScreenLayout]), so the padding is
              // that of the dock as laid out in this very frame, whatever the text scale made of it.
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final dockHeight = dock == null ? 0.0 : constraints.maxHeight - constraints.minHeight;
                  final padding = EdgeInsets.fromLTRB(
                    TsuyaSpace.s20 + safe.left,
                    safe.top,
                    TsuyaSpace.s20 + safe.right,
                    // the dock's height already counts the safe area it pads itself by
                    (dock == null ? safe.bottom : dockHeight) + TsuyaSpace.s24,
                  );
                  return SizedBox(
                    height: constraints.minHeight,
                    // what is shown from inside (a Toast) clears the dock too
                    child: DockInset(
                      height: dock == null ? 0 : dockHeight - safe.bottom,
                      child: Builder(builder: (context) => widget.builder(context, padding)),
                    ),
                  );
                },
              ),
            ),
            if (dock != null)
              // Full width, down to the screen's bottom edge, as the web `.t-screen-dock` and its `::before`: the fade
              // covers the whole width and the margins (12 plus the safe areas) pad the dock inside it.
              LayoutId(
                id: _dock,
                // Passthrough, not Stack's default loose: the padded dock (a non-positioned child here) must keep
                // the tight width the layout already gives it.
                child: Stack(
                  fit: StackFit.passthrough,
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -TsuyaSpace.s24,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [colors.bg.withValues(alpha: 0), colors.bg],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        TsuyaSpace.s12 + safe.left,
                        0,
                        TsuyaSpace.s12 + safe.right,
                        TsuyaSpace.s12 + safe.bottom,
                      ),
                      child: dock,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Lays the dock out first, at the bottom, whatever height it takes (it grows with the text scale), then the content
/// over the screen above the keyboard. The content's constraints carry the dock's height as their slack
/// (`maxHeight - minHeight`), which is how it reaches the content's [LayoutBuilder] in the same layout pass: a value
/// read from a later frame would leave the last rows under the dock for that frame.
class _ScreenLayout extends MultiChildLayoutDelegate {
  _ScreenLayout({required this.keyboard});

  final double keyboard;

  @override
  void performLayout(Size size) {
    var dockHeight = 0.0;
    if (hasChild(_dock)) {
      final loose = BoxConstraints(minWidth: size.width, maxWidth: size.width, maxHeight: size.height);
      dockHeight = layoutChild(_dock, loose).height;
      positionChild(_dock, Offset(0, size.height - dockHeight));
    }
    final height = (size.height - keyboard).clamp(0.0, size.height);
    layoutChild(
      _content,
      BoxConstraints(minWidth: size.width, maxWidth: size.width, minHeight: height, maxHeight: height + dockHeight),
    );
    positionChild(_content, Offset.zero);
  }

  @override
  bool shouldRelayout(_ScreenLayout oldDelegate) => keyboard != oldDelegate.keyboard;
}
