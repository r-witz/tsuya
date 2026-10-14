// The bordered (or pill, or glass) box around a text field's content, and its selection handles drawn as accent
// teardrops instead of the platform's own (DESIGN.md, TextField). The text field and the combobox share them.

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import '../material/accent.dart';
import '../material/glass.dart';

/// The height [TextField.search] uses: [TsuyaSize.controlSm] or [TsuyaSize.controlMd].
enum TextFieldSize {
  /// [TsuyaSize.controlSm]: the default for a search field.
  sm(TsuyaSize.controlSm),

  /// [TsuyaSize.controlMd]: the height of every other text field.
  md(TsuyaSize.controlMd);

  const TextFieldSize(this.height);

  /// The field's height.
  final double height;
}

/// The box of a [TextField]: [radius]ed, filled (or glass when [glass]), its boundary [borderColor] at
/// [borderWidth], at least [minHeight] tall, [leading] then the field's own content then [trailingItems], with
/// [placeholder] shown while [controller] is empty.
class TextFieldBox extends StatelessWidget {
  /// The chrome around a text field's own editable content.
  const TextFieldBox({
    super.key,
    required this.controller,
    required this.radius,
    required this.borderColor,
    required this.borderWidth,
    required this.glass,
    required this.minHeight,
    required this.multiline,
    required this.placeholder,
    required this.style,
    this.leading,
    required this.trailingItems,
    required this.editable,
  });

  /// Listened to, to hide [placeholder] once it holds text.
  final TextEditingController controller;

  /// The shape: [TsuyaRadius.sm], or a pill for a search field.
  final BorderRadius radius;

  /// The boundary colour: [TsuyaColors.borderStrong] at rest, the accent on focus, [TsuyaColors.danger] on error.
  final Color borderColor;

  /// 1 at rest, [TsuyaState.focusWidth] on focus or error.
  final double borderWidth;

  /// Control glass instead of a plain fill.
  final bool glass;

  /// The field's minimum height.
  final double minHeight;

  /// Lays the content out top-aligned with vertical padding, for a multi-line field.
  final bool multiline;

  /// Shown in [TsuyaColors.textMuted] while [controller] is empty.
  final String? placeholder;

  /// The text style of [placeholder] (coloured muted) and the editable content.
  final TextStyle style;

  /// Before the content, in [TsuyaColors.textMuted].
  final Widget? leading;

  /// After the content: a clear button, a reveal button, a custom trailing widget.
  final List<Widget> trailingItems;

  /// The field's own [EditableText], already wrapped in its selection gesture detector.
  final Widget editable;

  @override
  Widget build(BuildContext context) {
    final colors = TsuyaTheme.of(context).colors;
    Widget shape = DecoratedBox(
      decoration: BoxDecoration(
        color: glass ? null : colors.fill,
        borderRadius: radius,
        border: Border.all(color: borderColor, width: borderWidth, strokeAlign: BorderSide.strokeAlignInside),
      ),
      child: Container(
        constraints: BoxConstraints(minHeight: minHeight),
        padding: EdgeInsets.symmetric(horizontal: TsuyaSpace.s12, vertical: multiline ? TsuyaSpace.s12 : 0),
        child: Row(
          crossAxisAlignment: multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            if (leading case final leading?) ...[
              IconTheme(
                data: IconThemeData(color: colors.textMuted),
                child: ExcludeSemantics(child: leading),
              ),
              const SizedBox(width: TsuyaSpace.s8),
            ],
            Expanded(
              child: Stack(
                alignment: AlignmentDirectional.centerStart,
                children: [
                  ListenableBuilder(
                    listenable: controller,
                    builder: (context, _) => controller.text.isNotEmpty || placeholder == null
                        ? const SizedBox.shrink()
                        : ExcludeSemantics(
                            child: Text(
                              placeholder!,
                              style: style.copyWith(color: colors.textMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                  ),
                  editable,
                ],
              ),
            ),
            for (final item in trailingItems) ...[const SizedBox(width: TsuyaSpace.s8), item],
          ],
        ),
      ),
    );
    if (glass) shape = ControlGlass(borderRadius: radius, child: shape);
    return shape;
  }
}

/// Teardrop selection handles in the accent colour, used by every tsuya text field instead of the platform's own.
final TextSelectionControls tsuyaTextSelectionHandles = _TsuyaHandles();

class _TsuyaHandles extends TextSelectionControls with TextSelectionHandleControls {
  static const _size = TsuyaSpace.s20;

  @override
  Size getHandleSize(double textLineHeight) => const Size(_size, _size);

  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) => switch (type) {
    TextSelectionHandleType.left => const Offset(_size, 0),
    TextSelectionHandleType.right => Offset.zero,
    TextSelectionHandleType.collapsed => const Offset(_size / 2, -4),
  };

  @override
  Widget buildHandle(BuildContext context, TextSelectionHandleType type, double textLineHeight, [VoidCallback? onTap]) {
    final handle = SizedBox.square(
      dimension: _size,
      child: CustomPaint(painter: _HandlePainter(Accent.of(context))),
    );
    return switch (type) {
      TextSelectionHandleType.left => Transform.rotate(angle: math.pi / 2, child: handle),
      TextSelectionHandleType.right => handle,
      TextSelectionHandleType.collapsed => Transform.rotate(angle: math.pi / 4, child: handle),
    };
  }
}

// A circle with its top-left quarter squared off: the resulting point touches the text.
class _HandlePainter extends CustomPainter {
  _HandlePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    canvas.drawPath(
      Path()
        ..addOval(Rect.fromCircle(center: Offset(r, r), radius: r))
        ..addRect(Rect.fromLTWH(0, 0, r, r)),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_HandlePainter old) => old.color != color;
}
