// The dropdown panel of a Combobox (DESIGN.md, Combobox): a loading row, a "no results" row, or the
// filtered options, each with a visual-only active marker (the text field itself keeps real focus).
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import '../foundation/labels.dart';
import '../foundation/listbox.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import 'menu_panel.dart';
import 'spinner.dart';

/// The positioned panel under a `Combobox`'s field, anchored under [anchorKey] (menu panel styling): a loading row
/// (a spinner and the `loading` label) while [loading], a "no results" row when [options] is empty, or [options]
/// with [active] (an index into [options]) marked, each choosable via [onChoose] and made active by a pointer over it
/// via [onHover]. [rowKeys] lets the caller scroll
/// an option into view: one [GlobalKey] per [ListboxOption.value], filled in as rows are built. Empty when
/// [anchorKey] is not yet laid out.
Widget comboboxPanel<T>(
  BuildContext context, {
  required GlobalKey anchorKey,
  required bool loading,
  required List<ListboxOption<T>> options,
  required int? active,
  required ValueChanged<ListboxOption<T>> onChoose,
  required ValueChanged<int> onHover,
  required Map<T, GlobalKey> rowKeys,
}) {
  final anchor = anchorKey.currentContext?.findRenderObject();
  if (anchor is! RenderBox || !anchor.attached) return const SizedBox.shrink();
  final Widget content;
  if (loading) {
    content = _statusRow(context, TsuyaLabels.of(context).loading, spinner: true);
  } else if (options.isEmpty) {
    content = _statusRow(context, TsuyaLabels.of(context).noResults, spinner: false);
  } else {
    content = SingleChildScrollView(
      child: Semantics(
        role: SemanticsRole.list,
        explicitChildNodes: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < options.length; i++)
              _ComboboxRow<T>(
                option: options[i],
                active: i == active,
                onChoose: onChoose,
                onHover: () => onHover(i),
                rowKey: rowKeys.putIfAbsent(options[i].value, GlobalKey.new),
              ),
          ],
        ),
      ),
    );
  }
  return AnchoredPanel(anchor: anchor, child: content);
}

Widget _statusRow(BuildContext context, String text, {required bool spinner}) {
  final colors = TsuyaTheme.of(context).colors;
  return Padding(
    padding: const EdgeInsets.all(TsuyaSpace.s12),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (spinner) ...[
          const ExcludeSemantics(child: Spinner(size: SpinnerSize.sm)),
          const SizedBox(width: TsuyaSpace.s8),
        ],
        Text(text, style: TsuyaTheme.of(context).text(TsuyaType.body).copyWith(color: colors.textMuted)),
      ],
    ),
  );
}

class _ComboboxRow<T> extends StatelessWidget {
  const _ComboboxRow({
    required this.option,
    required this.active,
    required this.onChoose,
    required this.onHover,
    required this.rowKey,
  });

  final ListboxOption<T> option;
  final bool active;
  final ValueChanged<ListboxOption<T>> onChoose;
  final VoidCallback onHover;
  final GlobalKey rowKey;

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    final colors = theme.colors;
    return Semantics(
      role: SemanticsRole.listItem,
      focused: active,
      enabled: !option.disabled,
      child: MouseRegion(
        onHover: option.disabled ? null : (_) => onHover(),
        child: GestureDetector(
          onTap: option.disabled ? null : () => onChoose(option),
          child: Container(
            key: rowKey,
            padding: const EdgeInsets.symmetric(horizontal: TsuyaSpace.s12, vertical: TsuyaSpace.s8),
            color: active ? colors.fill : null,
            child: Text(
              option.label,
              style: theme.text(TsuyaType.body).copyWith(color: option.disabled ? colors.textMuted : colors.text),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
