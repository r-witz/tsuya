// A filter or sort token, alone or in a group (DESIGN.md, Chip).
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import '../foundation/pressable.dart';
import '../foundation/roving_focus.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import '../material/accent.dart';
import 'control_body.dart';

/// A filter or sort token (DESIGN.md, Chip): [TsuyaSize.controlSm] tall, [TsuyaRadius.sm], a [TsuyaColors.fill]
/// with a hairline; accent-filled with [TsuyaColors.onAccent] content when [selected]. A glass variant over
/// content.
class Chip extends StatelessWidget {
  /// A chip labelled [label].
  const Chip({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
    this.icon,
    this.glass = false,
    this.focusNode,
    this.autofocus = false,
    this.checked = false,
  });

  /// The chip's one-line label; ellipsized if it must.
  final String label;

  /// Whether it is chosen.
  final bool selected;

  /// Called on a press; null disables it.
  final VoidCallback? onPressed;

  /// Before the label, in [TsuyaColors.textMuted] (or on-accent when [selected]).
  final Widget? icon;

  /// Control glass instead of the fill and hairline.
  final bool glass;

  /// The node to track focus with, when the caller manages one ([ChipGroup] sets its own).
  final FocusNode? focusNode;

  /// Focuses it as soon as it is built.
  final bool autofocus;

  /// Announces it as one radio of a mutually exclusive group rather than a toggle, as a single-select [ChipGroup]
  /// does ("selected" rather than "pressed").
  final bool checked;

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    final colors = theme.colors;
    final (fill, border, content, iconColor) = selected
        ? (Accent.of(context), null, colors.onAccent, colors.onAccent)
        : (colors.fill, colors.border, colors.text, colors.textMuted);
    final radius = BorderRadius.circular(TsuyaRadius.sm);
    return Pressable(
      onPressed: onPressed,
      toggled: checked ? null : selected,
      checked: checked ? selected : null,
      inMutuallyExclusiveGroup: checked,
      borderRadius: radius,
      focusNode: focusNode,
      focusOnPress: focusNode != null,
      autofocus: autofocus,
      child: ControlBody(
        fill: fill,
        border: border,
        radius: radius,
        glass: glass,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: TsuyaSize.controlSm),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: TsuyaSpace.s12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon case final icon?) ...[
                  IconTheme(
                    data: IconThemeData(color: iconColor, size: TsuyaSize.iconSm),
                    child: ExcludeSemantics(child: icon),
                  ),
                  const SizedBox(width: TsuyaSpace.s8),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: theme.text(TsuyaType.control).copyWith(color: content),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One chip of a [ChipGroup]: identified by [value], labelled [label], with an optional [icon].
@immutable
class ChipOption<T> {
  /// An option for [value], shown as [label].
  const ChipOption({required this.value, required this.label, this.icon});

  /// What [ChipGroup.onChanged] is called with.
  final T value;

  /// The chip's label.
  final String label;

  /// The chip's icon.
  final Widget? icon;
}

/// A sideways-scrolling row of [Chip]s (DESIGN.md, Chip: ChipGroup), one tab stop with roving focus: arrow keys
/// move between [chips], Space or Enter chooses. [multiple] allows more than one chosen at once and changes only
/// how each is announced (a toggle button, or one radio of a mutually exclusive group). [value] holds the chosen
/// values; [onChanged] is called with the next set on a choice.
class ChipGroup<T> extends StatelessWidget {
  /// A group of [chips], [value] chosen, named [label] for screen readers.
  const ChipGroup({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.chips,
    this.multiple = false,
  });

  /// The group's accessible name.
  final String label;

  /// The chosen values.
  final Set<T> value;

  /// Called with the next chosen set when a chip is pressed.
  final ValueChanged<Set<T>> onChanged;

  /// The chips, in order.
  final List<ChipOption<T>> chips;

  /// Whether more than one chip can be chosen at once.
  final bool multiple;

  void _choose(T chosen) {
    if (!multiple) {
      onChanged({chosen});
      return;
    }
    final next = Set<T>.of(value);
    if (!next.remove(chosen)) next.add(chosen);
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    explicitChildNodes: true,
    label: label,
    role: multiple ? null : SemanticsRole.radioGroup,
    child: RovingFocus(
      count: chips.length,
      labelOf: (i) => chips[i].label,
      builder: (context, nodes, activeIndex) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < chips.length; i++) ...[
              if (i > 0) const SizedBox(width: TsuyaSpace.s8),
              Chip(
                label: chips[i].label,
                icon: chips[i].icon,
                selected: value.contains(chips[i].value),
                onPressed: () => _choose(chips[i].value),
                focusNode: nodes[i],
                checked: !multiple,
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
