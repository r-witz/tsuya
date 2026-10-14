// A single-selection group of radios (DESIGN.md, RadioGroup).
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import '../foundation/motion.dart';
import '../foundation/pressable.dart';
import '../foundation/roving_focus.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import '../material/accent.dart';

/// One radio of a [RadioGroup]: identified by [value], labelled [label].
@immutable
class RadioOption<T> {
  /// An option for [value], shown as [label].
  const RadioOption({required this.value, required this.label});

  /// What [RadioGroup.onChanged] is called with.
  final T value;

  /// The radio's label.
  final String label;
}

/// A single-selection group of radios (DESIGN.md, RadioGroup): one tab stop with roving focus; arrows both move
/// and select, as native radios do on the web. Each radio is a 20 circle with a 1.5 px [TsuyaColors.borderStrong]
/// boundary; selected: accent fill with an 8 px [TsuyaColors.onAccent] dot.
class RadioGroup<T> extends StatefulWidget {
  /// A group of [options], [value] selected, named [label] for screen readers.
  const RadioGroup({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.options,
  });

  /// The group's accessible name.
  final String label;

  /// The selected value, or null when nothing is selected yet.
  final T? value;

  /// Called with an option's value when it is selected.
  final ValueChanged<T> onChanged;

  /// The radios, in order.
  final List<RadioOption<T>> options;

  @override
  State<RadioGroup<T>> createState() => _RadioGroupState<T>();
}

class _RadioGroupState<T> extends State<RadioGroup<T>> {
  int? _lastActive;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = widget.options.indexWhere((option) => option.value == widget.value);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.label,
      role: SemanticsRole.radioGroup,
      child: RovingFocus(
        count: widget.options.length,
        axis: Axis.vertical,
        initialIndex: selectedIndex < 0 ? 0 : selectedIndex,
        labelOf: (i) => widget.options[i].label,
        builder: (context, nodes, activeIndex) {
          // Arrows both move and select, as native radios do on the web: schedule the choice after this frame,
          // since the roving group is mid-rebuild and cannot be told to change the selection again right now.
          if (_lastActive != null && _lastActive != activeIndex) {
            final next = widget.options[activeIndex].value;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              widget.onChanged(next);
            });
          }
          _lastActive = activeIndex;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < widget.options.length; i++) ...[
                if (i > 0) const SizedBox(height: TsuyaSpace.s8),
                _Radio(
                  label: widget.options[i].label,
                  selected: i == selectedIndex,
                  onPressed: () => widget.onChanged(widget.options[i].value),
                  focusNode: nodes[i],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.label, required this.selected, required this.onPressed, required this.focusNode});

  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final FocusNode focusNode;

  static const _diameter = 20.0;

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    final colors = theme.colors;
    return Pressable(
      onPressed: onPressed,
      checked: selected,
      inMutuallyExclusiveGroup: true,
      focusNode: focusNode,
      focusOnPress: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            width: _diameter,
            height: _diameter,
            duration: motionOf(context, TsuyaDuration.fast),
            curve: TsuyaEasing.standard,
            decoration: BoxDecoration(shape: BoxShape.circle, color: selected ? Accent.of(context) : null),
            foregroundDecoration: selected
                ? null
                : BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.borderStrong,
                      width: 1.5,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                  ),
            child: selected
                ? Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: colors.onAccent),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: TsuyaSpace.s12),
          Flexible(
            child: Text(label, style: theme.text(TsuyaType.body).copyWith(color: colors.text)),
          ),
        ],
      ),
    );
  }
}
