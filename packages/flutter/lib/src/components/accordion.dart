// Rows that open their content below, one or several at a time (DESIGN.md, Accordion).
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import '../foundation/motion.dart';
import '../foundation/presence.dart';
import '../foundation/pressable.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import 'glyphs.dart';

/// One row of an [Accordion]: identified by [value], headed by [label], holding [content] below it while open.
@immutable
class AccordionItemData {
  /// A row for [value], headed [label], opening [content].
  const AccordionItemData({required this.value, required this.label, required this.content, this.disabled = false});

  /// What [Accordion.onChanged] adds or removes.
  final String value;

  /// The row's header, in [TsuyaType.bodyStrong] (ListItem styling): shown, and read for screen readers.
  final String label;

  /// Shown below the header, [TsuyaSpace.s16] padded, while the row is open.
  final Widget content;

  /// Excluded from toggling (not toggled and not focusable: the header is skipped by Tab, as a native disabled button
  /// is).
  final bool disabled;
}

/// Rows that open their content below, one at a time or several (DESIGN.md, Accordion): each header is a button in
/// a heading, with a chevron that turns 180° while open; the content's height animates over [TsuyaDuration.base]
/// (instant under reduced motion). [multiple] false (the default) keeps at most one [value] open at a time: opening
/// a row closes the one already open.
class Accordion extends StatelessWidget {
  /// An accordion over [items], the rows named in [value] open.
  const Accordion({
    super.key,
    required this.items,
    this.multiple = false,
    required this.value,
    required this.onChanged,
    this.headingLevel = 3,
  });

  /// The rows, in order.
  final List<AccordionItemData> items;

  /// Lets several rows stay open together; otherwise opening one closes the others.
  final bool multiple;

  /// The open rows' values.
  final List<String> value;

  /// Called with the next list of open values when a row is toggled.
  final ValueChanged<List<String>> onChanged;

  /// The level of the heading each header sits in.
  final int headingLevel;

  void _toggle(String target) {
    final open = List<String>.of(value);
    if (open.remove(target)) {
      onChanged(open);
      return;
    }
    if (!multiple) open.clear();
    open.add(target);
    onChanged(open);
  }

  @override
  Widget build(BuildContext context) {
    final colors = TsuyaTheme.of(context).colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) ColoredBox(color: colors.border, child: const SizedBox(height: 1)),
          _AccordionRow(
            item: items[i],
            open: value.contains(items[i].value),
            headingLevel: headingLevel,
            onToggle: () => _toggle(items[i].value),
          ),
        ],
      ],
    );
  }
}

class _AccordionRow extends StatelessWidget {
  const _AccordionRow({required this.item, required this.open, required this.headingLevel, required this.onToggle});

  final AccordionItemData item;
  final bool open;
  final int headingLevel;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    final colors = theme.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Pressable(
          onPressed: item.disabled ? null : onToggle,
          expanded: open,
          feedback: PressFeedback.highlight,
          // The heading level merges into the button's own node (named by its text), so the header is one node
          // read once, not a heading around a button that both say its label.
          // The minimum height is inside the Pressable, whose drawing is loosened: outside it the highlight would
          // stop at the content's height instead of filling the row.
          child: Semantics(
            headingLevel: headingLevel,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: TsuyaSize.row),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: TsuyaSpace.s8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.label,
                          style: theme.text(TsuyaType.bodyStrong).copyWith(color: colors.text),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: TsuyaSpace.s12),
                      AnimatedRotation(
                        turns: open ? 0.5 : 0,
                        duration: motionOf(context, TsuyaDuration.base),
                        curve: TsuyaEasing.standard,
                        child: Glyph(TsuyaGlyph.chevronDown, size: TsuyaSize.iconSm, color: colors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Presence(
          visible: open,
          builder: (context, animation) => Semantics(
            container: true,
            explicitChildNodes: true,
            role: SemanticsRole.region,
            label: item.label,
            child: SizeTransition(
              sizeFactor: animation,
              alignment: const AlignmentDirectional(-1, -1),
              child: Padding(padding: const EdgeInsets.all(TsuyaSpace.s16), child: item.content),
            ),
          ),
        ),
      ],
    );
  }
}
