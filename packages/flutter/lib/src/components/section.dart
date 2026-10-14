// A labelled group of list rows (DESIGN.md, List, ListItem, Section).
// Semantics (the label is announced; each row keeps its own node).
import 'package:flutter/widgets.dart';

import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';

/// A labelled group of rows in a list (DESIGN.md, List, ListItem, Section): [label] above [children] (typically
/// [ListItem]s), its rows separated by 1 px hairlines — not from the label itself.
class Section extends StatelessWidget {
  /// A group labelled [label], holding [children].
  const Section({super.key, required this.label, required this.children});

  /// The group's label, shown in capitals.
  final String label;

  /// The group's rows, in order.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    final colors = theme.colors;
    return Semantics(
      container: true,
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: TsuyaSpace.s24, bottom: TsuyaSpace.s8),
            child: ExcludeSemantics(
              child: Text(label.toUpperCase(), style: theme.text(TsuyaType.label).copyWith(color: colors.textMuted)),
            ),
          ),
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) ColoredBox(color: colors.border, child: const SizedBox(height: 1)),
            children[i],
          ],
        ],
      ),
    );
  }
}
