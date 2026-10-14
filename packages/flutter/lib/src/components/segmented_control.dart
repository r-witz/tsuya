// 2 to 5 options seen together, one always selected (DESIGN.md, SegmentedControl).

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../foundation/motion.dart';
import '../foundation/pressable.dart';
import '../foundation/roving_focus.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';

/// One segment of a [SegmentedControl]: identified by [value], labelled [label] (the accessible name; shown
/// visibly unless [icon] is given, which then shows alone).
@immutable
class Segment<T> {
  /// A segment for [value], shown as [label] or, when given, [icon] alone.
  const Segment({required this.value, required this.label, this.icon});

  /// What [SegmentedControl.onChanged] is called with.
  final T value;

  /// The segment's label: its accessible name always, and its visible content unless [icon] is given.
  final String label;

  /// Shown alone instead of [label]; [label] still names it for screen readers.
  final Widget? icon;
}

/// 2 to 5 options seen together, one always selected (DESIGN.md, SegmentedControl): one tab stop with roving
/// focus; arrows both move and select, as native radios do on the web. A [TsuyaColors.fill] track with a hairline,
/// [TsuyaSpace.s4] inside; the selected segment is [TsuyaColors.fillSelected] with [TsuyaShadows.sm]. [expand]
/// shares the width between segments; otherwise each hugs its own content, until they no longer fit: they then share the
/// width in proportion to their content and labels wrap onto more lines.
class SegmentedControl<T> extends StatefulWidget {
  /// A control over [segments], [selected] chosen, named [label] for screen readers.
  const SegmentedControl({
    super.key,
    required this.label,
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.expand = false,
  });

  /// The control's accessible name.
  final String label;

  /// The segments, in order (2 to 5).
  final List<Segment<T>> segments;

  /// The chosen value.
  final T selected;

  /// Called with a segment's value when it is chosen.
  final ValueChanged<T> onChanged;

  /// Shares the width equally between segments, instead of each hugging its own content.
  final bool expand;

  @override
  State<SegmentedControl<T>> createState() => _SegmentedControlState<T>();
}

class _SegmentedControlState<T> extends State<SegmentedControl<T>> {
  int? _lastActive;

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    final colors = theme.colors;
    final selectedIndex = widget.segments.indexWhere((segment) => segment.value == widget.selected);
    final radius = BorderRadius.circular(TsuyaRadius.sm + TsuyaSpace.s4);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.label,
      role: SemanticsRole.radioGroup,
      child: RovingFocus(
        count: widget.segments.length,
        initialIndex: selectedIndex < 0 ? 0 : selectedIndex,
        labelOf: (i) => widget.segments[i].label,
        builder: (context, nodes, activeIndex) {
          // Arrows both move and select, as native radios do on the web: scheduled after this frame, since the
          // roving group is mid-rebuild and cannot be told to change the selection again right now.
          if (_lastActive != null && _lastActive != activeIndex) {
            final next = widget.segments[activeIndex].value;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              widget.onChanged(next);
            });
          }
          _lastActive = activeIndex;
          final children = [
            for (var i = 0; i < widget.segments.length; i++) _buildSegment(context, i, i == selectedIndex, nodes[i]),
          ];
          return Container(
            padding: const EdgeInsets.all(TsuyaSpace.s4),
            decoration: BoxDecoration(color: colors.fill, borderRadius: radius),
            foregroundDecoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: colors.border, strokeAlign: BorderSide.strokeAlignInside),
            ),
            child: _SegmentRow(expand: widget.expand, children: children),
          );
        },
      ),
    );
  }

  Widget _buildSegment(BuildContext context, int index, bool selected, FocusNode focusNode) {
    final theme = TsuyaTheme.of(context);
    final colors = theme.colors;
    final segment = widget.segments[index];
    final content = selected ? colors.text : colors.textMuted;
    final body = Pressable(
      onPressed: () => widget.onChanged(segment.value),
      checked: selected,
      inMutuallyExclusiveGroup: true,
      label: segment.icon != null ? segment.label : null,
      focusNode: focusNode,
      focusOnPress: true,
      child: AnimatedContainer(
        duration: motionOf(context, TsuyaDuration.fast),
        curve: TsuyaEasing.standard,
        decoration: BoxDecoration(
          color: selected ? colors.fillSelected : null,
          borderRadius: BorderRadius.circular(TsuyaRadius.sm),
          boxShadow: selected ? TsuyaShadows.of(context).sm : null,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: TsuyaSize.controlMd - 2 * TsuyaSpace.s4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: TsuyaSpace.s16),
            child: Center(
              heightFactor: 1,
              child: segment.icon != null
                  ? IconTheme(
                      data: IconThemeData(color: content),
                      child: ExcludeSemantics(child: segment.icon!),
                    )
                  : Text(segment.label, style: theme.text(TsuyaType.control).copyWith(color: content)),
            ),
          ),
        ),
      ),
    );
    return body;
  }
}

/// A row of segments, each as wide as its own content while they all fit; with [expand], sharing the whole width
/// equally, except that a segment whose content is wider keeps it (a word is not broken while another segment has
/// room to spare). When the contents do not fit (large text on a narrow screen), the segments share the available
/// width in proportion to their content, as flex items shrink on the web, and their labels wrap onto more lines.
/// The segments are as tall as the tallest (nothing overflows up to 300 %).
class _SegmentRow extends MultiChildRenderObjectWidget {
  /// A row of [children].
  const _SegmentRow({this.expand = false, required super.children});

  /// Fills the width instead of hugging the contents.
  final bool expand;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderSegmentRow(Directionality.of(context), expand);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) => (renderObject as _RenderSegmentRow)
    ..textDirection = Directionality.of(context)
    ..mainAxisSize = expand ? MainAxisSize.max : MainAxisSize.min
    ..expand = expand;
}

class _RenderSegmentRow extends RenderFlex {
  _RenderSegmentRow(TextDirection direction, this.expand)
    : super(
        direction: Axis.horizontal,
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: direction,
      );

  bool expand;

  // Equal shares of [width], except that a segment wider than its share keeps its natural width (and the others
  // share what is left equally).
  static List<double> _shares(List<double> natural, double width) {
    final shares = List<double>.of(natural);
    final open = {for (var i = 0; i < natural.length; i++) i};
    var left = width;
    while (open.isNotEmpty) {
      final share = left / open.length;
      final wide = open.where((i) => natural[i] > share).toList();
      if (wide.isEmpty) {
        for (final i in open) {
          shares[i] = share;
        }
        break;
      }
      for (final i in wide) {
        left -= natural[i];
        open.remove(i);
      }
    }
    return shares;
  }

  @override
  void performLayout() {
    final children = <RenderBox>[];
    for (var child = firstChild; child != null; child = childAfter(child)) {
      children.add(child);
    }
    final natural = [for (final child in children) child.getMaxIntrinsicWidth(double.infinity)];
    final fits = natural.fold(0.0, (sum, width) => sum + width) <= constraints.maxWidth;
    final fill = expand && constraints.hasBoundedWidth;
    // Hugging and fitting: no segment flexes. Otherwise each flexes by its share (expanded and fitting) or by its
    // natural width (not fitting).
    final weights = fits && fill ? _shares(natural, constraints.maxWidth) : natural;
    for (var i = 0; i < children.length; i++) {
      (children[i].parentData! as FlexParentData)
        ..flex = fits && !fill ? 0 : (weights[i] * 64).round().clamp(1, 1 << 24)
        ..fit = FlexFit.tight;
    }
    super.performLayout();
    // As tall as the tallest: a stretching flex would break under the unbounded height of a wrapping parent.
    final height = size.height;
    for (final child in children) {
      if (child.size.height != height) {
        child.layout(BoxConstraints.tightFor(width: child.size.width, height: height), parentUsesSize: true);
      }
    }
  }
}
