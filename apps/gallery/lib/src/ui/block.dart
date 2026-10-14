// What the blocks share: a scrolling screen that adapts to its width, and the widths themselves (DESIGN.md, Layout:
// breakpoints are minimum widths of the container, not of the device).
import 'package:flutter/widgets.dart';
import 'package:tsuya/tsuya.dart';

/// The layout a block width calls for.
enum Layout {
  /// Below `tablet`.
  phone,

  /// From `tablet`, below `desktop`.
  tablet,

  /// From `desktop`.
  desktop;

  /// The layout of a container [width] wide.
  static Layout of(double width) => width >= TsuyaBreakpoint.desktop
      ? desktop
      : width >= TsuyaBreakpoint.tablet
      ? tablet
      : phone;

  /// The side gutter of the content column.
  double get gutter => switch (this) {
    phone => TsuyaContainer.gutterPhone,
    tablet => TsuyaContainer.gutterTablet,
    desktop => TsuyaContainer.gutterDesktop,
  };
}

/// A screen of a block: the surface (lit by [ambient], or the glow), [dock] floating over it, and [builder]'s content
/// in a column of at most [TsuyaContainer.maxWidth], given the layout of the width it has.
class BlockScreen extends StatelessWidget {
  /// A screen showing what [builder] makes.
  const BlockScreen({
    super.key,
    this.ambient,
    this.dock,
    this.maxWidth = TsuyaContainer.maxWidth,
    required this.builder,
  });

  /// The leading content's picture.
  final ImageProvider? ambient;

  /// A tab bar, on a phone.
  final Widget? dock;

  /// The widest the content column gets.
  final double maxWidth;

  /// The content, given the layout of the screen's width.
  final Widget Function(BuildContext context, Layout layout) builder;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final layout = Layout.of(constraints.maxWidth);
      return Screen(
        ambient: ambient,
        dock: layout == Layout.phone ? dock : null,
        builder: (context, padding) => SingleChildScrollView(
          // the phone shell's own 20 margin stays; the wider layouts add up to their gutter
          padding: padding
              .copyWith(top: padding.top + TsuyaSpace.s24)
              .add(EdgeInsets.symmetric(horizontal: layout.gutter - TsuyaSpace.s16)),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: builder(context, layout),
            ),
          ),
        ),
      );
    },
  );
}

/// A shadow under a cover (DESIGN.md, Layout: a cover with `shadow-lg`).
Widget coverShadow(BuildContext context, {required double radius, required Widget child}) => DecoratedBox(
  decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius), boxShadow: TsuyaTheme.of(context).shadows.lg),
  child: child,
);
