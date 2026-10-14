// A lasting state, in line with the page (DESIGN.md, Banner).

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../foundation/labels.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import 'glyphs.dart';
import 'icon_button.dart';

/// The colour family of a [Banner].
enum BannerTone {
  /// Neutral news: [TsuyaColors.info].
  info,

  /// Something went well: [TsuyaColors.success].
  success,

  /// Something needs attention: [TsuyaColors.warning].
  warning,

  /// Something failed: [TsuyaColors.danger].
  danger,
}

// DESIGN.md, Banner: the fill is the status colour at 13 %, its ring at 32 %.
const _fillOpacity = 0.13;
const _ringOpacity = 0.32;

/// A lasting state — offline, a sync error, a trial ending (DESIGN.md, Banner): a status icon, a [title], a
/// [message] and [actions] at the end, under the text when narrow. The fill is [tone]'s colour at 13 % with a 1 px
/// ring at 32 %, never a coloured side stripe. [onClose] adds a close button. It does not announce itself: it is
/// part of the page, not an interruption (use a [Toast] for that).
class Banner extends StatelessWidget {
  /// A banner of [tone] titled [title].
  const Banner({
    super.key,
    required this.tone,
    required this.title,
    this.message,
    this.actions = const [],
    this.onClose,
  });

  /// Which status it shows.
  final BannerTone tone;

  /// What the state is, in [TsuyaType.bodyStrong].
  final String title;

  /// A sentence of detail under the title, in [TsuyaColors.textMuted].
  final String? message;

  /// Buttons at the end of the banner, usually small ones.
  final List<Widget> actions;

  /// Shows a close button, called when it is pressed.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    final colors = theme.colors;
    final color = switch (tone) {
      BannerTone.info => colors.info,
      BannerTone.success => colors.success,
      BannerTone.warning => colors.warning,
      BannerTone.danger => colors.danger,
    };
    final glyph = switch (tone) {
      BannerTone.info => TsuyaGlyph.info,
      BannerTone.success => TsuyaGlyph.check,
      BannerTone.warning || BannerTone.danger => TsuyaGlyph.alert,
    };
    const radius = BorderRadius.all(Radius.circular(TsuyaRadius.md));
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: theme.text(TsuyaType.bodyStrong).copyWith(color: colors.text)),
        if (message != null) ...[
          const SizedBox(height: TsuyaSpace.s4),
          Text(message!, style: theme.text(TsuyaType.small).copyWith(color: colors.textMuted)),
        ],
      ],
    );
    final buttons = Wrap(spacing: TsuyaSpace.s8, runSpacing: TsuyaSpace.s8, children: actions);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: _fillOpacity),
          borderRadius: radius,
          border: Border.all(
            color: color.withValues(alpha: _ringOpacity),
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: TsuyaSpace.s16, vertical: TsuyaSpace.s12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: Glyph(glyph, size: TsuyaSize.icon, color: color),
              ),
              const SizedBox(width: TsuyaSpace.s12),
              Expanded(
                child: actions.isEmpty ? text : _BannerActionsLayout(text: text, actions: buttons),
              ),
              if (onClose != null) ...[
                const SizedBox(width: TsuyaSpace.s12),
                IconButton(
                  icon: const Glyph(TsuyaGlyph.close),
                  label: TsuyaLabels.of(context).close,
                  kind: IconButtonKind.plain,
                  size: IconButtonSize.sm,
                  onPressed: onClose,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// The width from which the actions may join the text on its row (the Svelte Banner's own container breakpoint,
// 480 px).
const _inlineActionsWidth = 480.0;

// What the text keeps of its row at least, for the actions to join it: a legible line. The Svelte Banner decides on
// the width alone, but a browser's text zoom wraps what Flutter's text scale would overflow, so this decides on the
// measured size.
const _inlineTextWidth = 160.0;

/// [text] with [actions] at its end, centred across, when the row is [_inlineActionsWidth] wide or more and holds
/// the actions at their natural width beside at least [_inlineTextWidth] of the text; otherwise [actions] under it,
/// wrapping within the width.
class _BannerActionsLayout extends MultiChildRenderObjectWidget {
  /// A layout of [text] and [actions].
  _BannerActionsLayout({required Widget text, required Widget actions}) : super(children: [text, actions]);

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderBannerActions(Directionality.of(context));

  @override
  void updateRenderObject(BuildContext context, covariant RenderObject renderObject) =>
      (renderObject as _RenderBannerActions).textDirection = Directionality.of(context);
}

class _RenderBannerActions extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ContainerBoxParentData<RenderBox>>,
        RenderBoxContainerDefaultsMixin<RenderBox, ContainerBoxParentData<RenderBox>> {
  _RenderBannerActions(this._textDirection);

  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value == _textDirection) return;
    _textDirection = value;
    markNeedsLayout();
  }

  RenderBox get _text => firstChild!;
  RenderBox get _actions => lastChild!;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MultiChildLayoutParentData) child.parentData = MultiChildLayoutParentData();
  }

  @override
  double computeMinIntrinsicWidth(double height) => _text.getMinIntrinsicWidth(height);

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _text.getMaxIntrinsicWidth(height) + TsuyaSpace.s16 + _actions.getMaxIntrinsicWidth(height);

  @override
  double computeMinIntrinsicHeight(double width) => _text.getMinIntrinsicHeight(width);

  @override
  double computeMaxIntrinsicHeight(double width) => _text.getMaxIntrinsicHeight(width);

  @override
  Size computeDryLayout(BoxConstraints constraints) => _layout(constraints, ChildLayoutHelper.dryLayoutChild).size;

  @override
  void performLayout() {
    final result = _layout(constraints, ChildLayoutHelper.layoutChild);
    size = result.size;
    (_text.parentData! as ContainerBoxParentData<RenderBox>).offset = result.text;
    (_actions.parentData! as ContainerBoxParentData<RenderBox>).offset = result.actions;
  }

  ({Size size, Offset text, Offset actions}) _layout(BoxConstraints constraints, ChildLayouter layoutChild) {
    final width = constraints.maxWidth;
    final natural = layoutChild(_actions, const BoxConstraints());
    final textWidth = math.min(_text.getMaxIntrinsicWidth(double.infinity), _inlineTextWidth);
    final inline = width >= _inlineActionsWidth && natural.width + TsuyaSpace.s16 + textWidth <= width;
    if (inline) {
      final text = layoutChild(_text, BoxConstraints(maxWidth: width - TsuyaSpace.s16 - natural.width));
      final height = text.height > natural.height ? text.height : natural.height;
      final rtl = _textDirection == TextDirection.rtl;
      return (
        size: constraints.constrain(Size(width, height)),
        text: Offset(rtl ? width - text.width : 0, (height - text.height) / 2),
        actions: Offset(rtl ? 0 : width - natural.width, (height - natural.height) / 2),
      );
    }
    final text = layoutChild(_text, BoxConstraints(maxWidth: width));
    final actions = layoutChild(_actions, BoxConstraints(maxWidth: width));
    final top = text.height + TsuyaSpace.s12;
    return (
      size: constraints.constrain(Size(width, top + actions.height)),
      text: _textDirection == TextDirection.rtl ? Offset(width - text.width, 0) : Offset.zero,
      actions: _textDirection == TextDirection.rtl ? Offset(width - actions.width, top) : Offset(0, top),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) => defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
