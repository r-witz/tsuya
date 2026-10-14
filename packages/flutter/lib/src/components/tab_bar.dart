// The tab bar of the phone shell (DESIGN.md, TabBar, Screen).
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import '../foundation/motion.dart';
import '../foundation/pressable.dart';
import '../foundation/roving_focus.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import '../material/accent.dart';
import '../material/glass.dart';
import 'badge.dart';

/// A badge pinned to a [TabBarItem]'s icon: a count (shown as "99+" above 99) or a [dot], and what it means
/// ([label], read after the tab's own label: "Inbox, 3 new"). Purely decorative otherwise.
@immutable
class TabBarBadge {
  /// A badge of [count] or a [dot], meaning [label].
  const TabBarBadge({this.count, this.dot = false, required this.label});

  /// Shown as "99+" above 99; ignored when [dot] is true.
  final int? count;

  /// A plain dot instead of a count.
  final bool dot;

  /// What the badge means, read after the tab's own label.
  final String label;
}

/// One tab of a [TabBar]: identified by [value], labelled [label], shown over [icon].
@immutable
class TabBarItem<T> {
  /// A tab for [value], labelled [label], shown over [icon], with an optional [badge].
  const TabBarItem({required this.value, required this.label, required this.icon, this.badge});

  /// What [TabBar.onSelect] is called with.
  final T value;

  /// The tab's label: shown in [TsuyaType.micro] under the icon, and read for screen readers (before [badge]'s
  /// own meaning, when there is one).
  final String label;

  /// Drawn at [TsuyaSize.iconLg]: [TsuyaColors.accent] (by way of [Accent.of]) when current, otherwise
  /// [TsuyaColors.textMuted].
  final Widget icon;

  /// Pinned to the icon's corner; never read itself.
  final TabBarBadge? badge;
}

/// The tab bar of the phone shell (DESIGN.md, TabBar, Screen): glass, at least [TsuyaSize.dock] tall,
/// [TsuyaRadius.lg], [items] sharing its width equally; each an icon over a [TsuyaType.micro] label (one line,
/// ellipsis). The current tab draws its icon in the accent, its label at weight 700, over a
/// [TsuyaColors.fillStrong] capsule. One tab stop: arrows move focus; Enter, Space or a press choose (choosing a
/// tab changes the screen, so moving focus alone does not). A press on the already-current tab instead scrolls the
/// nearest [PrimaryScrollController] to the top (instant under reduced motion) — [Screen] sets one up around its
/// own content. While [current] is null, the first tab counts as current. Put it in a [Screen]'s `dock`.
class TabBar<T> extends StatelessWidget {
  /// A bar over [items], [current] chosen; [label] names the bar itself for screen readers, if it needs one.
  const TabBar({super.key, required this.items, this.current, required this.onSelect, this.label});

  /// The tabs, in order (3 to 5).
  final List<TabBarItem<T>> items;

  /// The current tab's value; the first tab counts as current while this is null.
  final T? current;

  /// Called with a tab's value when it is chosen (never on a focus move, and not when the current tab is pressed
  /// again — that scrolls to the top instead).
  final ValueChanged<T> onSelect;

  /// The bar's own accessible name, if it needs one; Svelte's forwards one the same optional way.
  final String? label;

  T? _currentValue() => current ?? (items.isEmpty ? null : items.first.value);

  int _currentIndex() => items.indexWhere((item) => item.value == _currentValue());

  void _choose(BuildContext context, TabBarItem<T> item) {
    if (item.value != _currentValue()) {
      onSelect(item.value);
      return;
    }
    final controller = PrimaryScrollController.maybeOf(context);
    if (controller == null || !controller.hasClients) return;
    final duration = motionOf(context, TsuyaDuration.base);
    // ScrollPositionWithSingleContext.animateTo asserts a positive duration rather than jumping for a zero one.
    if (duration == Duration.zero) {
      controller.jumpTo(0);
    } else {
      controller.animateTo(0, duration: duration, curve: TsuyaEasing.standard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentValue();
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: TsuyaSize.dock),
      child: Glass(
        borderRadius: BorderRadius.circular(TsuyaRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(TsuyaSpace.s4),
          child: Semantics(
            container: true,
            explicitChildNodes: true,
            label: label,
            role: SemanticsRole.tabBar,
            child: RovingFocus(
              count: items.length,
              initialIndex: _currentIndex() < 0 ? 0 : _currentIndex(),
              labelOf: (i) => items[i].label,
              builder: (context, nodes, activeIndex) => Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: _TabBarButton<T>(
                        item: items[i],
                        selected: items[i].value == current,
                        focusNode: nodes[i],
                        onPressed: () => _choose(context, items[i]),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabBarButton<T> extends StatelessWidget {
  const _TabBarButton({required this.item, required this.selected, required this.focusNode, required this.onPressed});

  final TabBarItem<T> item;
  final bool selected;
  final FocusNode focusNode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    final colors = theme.colors;
    final badge = item.badge;
    final radius = BorderRadius.circular(TsuyaRadius.full);
    return Pressable(
      onPressed: onPressed,
      role: SemanticsRole.tab,
      selected: selected,
      label: badge == null ? item.label : '${item.label}, ${badge.label}',
      focusNode: focusNode,
      focusOnPress: true,
      borderRadius: radius,
      feedback: PressFeedback.highlight,
      child: DecoratedBox(
        decoration: BoxDecoration(color: selected ? colors.fillStrong : null, borderRadius: radius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: TsuyaSpace.s4, vertical: TsuyaSpace.s8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              pinBadge(
                context,
                ExcludeSemantics(
                  child: SizedBox.square(
                    dimension: TsuyaSize.iconLg,
                    child: IconTheme(
                      data: IconThemeData(
                        size: TsuyaSize.iconLg,
                        color: selected ? Accent.of(context) : colors.textMuted,
                      ),
                      child: item.icon,
                    ),
                  ),
                ),
                switch (badge) {
                  TabBarBadge(dot: true) => const Badge.dot(),
                  TabBarBadge(:final int count) => Badge.count(count),
                  _ => null,
                },
              ),
              const SizedBox(height: TsuyaSpace.s4),
              ExcludeSemantics(
                child: Text(
                  item.label,
                  style: theme
                      .text(TsuyaType.micro)
                      .copyWith(
                        color: selected ? colors.text : colors.textMuted,
                        fontWeight: selected ? FontWeight.w700 : null,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
