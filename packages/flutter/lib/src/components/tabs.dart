// A row of text tabs (DESIGN.md, Tabs).
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import '../foundation/motion.dart';
import '../foundation/pressable.dart';
import '../foundation/roving_focus.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import '../material/accent.dart';

/// One tab of a [Tabs] row: identified by [value], labelled [label].
@immutable
class TabItem<T> {
  /// A tab for [value], labelled [label].
  const TabItem({required this.value, required this.label, this.disabled = false});

  /// What [Tabs.onChanged] is called with.
  final T value;

  /// The tab's label: shown in [TsuyaType.bodyStrong], and read for screen readers.
  final String label;

  /// Excluded from arrows, Home, End and a press.
  final bool disabled;
}

/// A row of text tabs (DESIGN.md, Tabs): one tab stop with roving focus; arrows both move and select (as native
/// radios do on the web) unless [manual], in which only Enter, Space or a press select. A 2 px accent bar slides
/// under the selected tab over [TsuyaDuration.fast] (instant under reduced motion). Scrolls sideways when the tabs
/// do not fit. While [selected] is null the first tab counts as selected, but [onChanged] is only called when a tab
/// is actually chosen. Pair with [TabView] for the panels.
class Tabs<T> extends StatefulWidget {
  /// A row named [label] (the tab list's accessible name) over [tabs], [selected] chosen.
  const Tabs({
    super.key,
    required this.label,
    required this.tabs,
    required this.selected,
    required this.onChanged,
    this.manual = false,
  });

  /// The tab list's accessible name.
  final String label;

  /// The tabs, in order.
  final List<TabItem<T>> tabs;

  /// The selected tab's value; the first tab while null.
  final T? selected;

  /// Called with a tab's value when it is chosen.
  final ValueChanged<T> onChanged;

  /// Arrows move focus only; Enter, Space or a press select. Default false: arrows select as they move.
  final bool manual;

  @override
  State<Tabs<T>> createState() => _TabsState<T>();
}

class _TabsState<T> extends State<Tabs<T>> {
  final _stackKey = GlobalKey();
  List<GlobalKey> _tabKeys = [];
  int? _lastActive;
  Rect? _barRect;

  @override
  void initState() {
    super.initState();
    _tabKeys = [for (final _ in widget.tabs) GlobalKey()];
    _scheduleMeasure();
  }

  @override
  void didUpdateWidget(Tabs<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabs.length != oldWidget.tabs.length) _tabKeys = [for (final _ in widget.tabs) GlobalKey()];
    final moved = widget.selected != oldWidget.selected || widget.tabs.length != oldWidget.tabs.length;
    _scheduleMeasure(scroll: moved);
  }

  T _effectiveSelected() => widget.selected ?? widget.tabs.first.value;

  int _selectedIndex() => widget.tabs.indexWhere((tab) => tab.value == _effectiveSelected());

  // Measures the selected tab's rect relative to the row (for the sliding bar) and, when [scroll], scrolls it into
  // view (only when the selection or the tabs change, so a rebuild does not undo the user's own scrolling); an
  // AnimatedPositioned then animates the bar from its last rect to this one (instant under reduced motion).
  void _scheduleMeasure({bool scroll = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final index = _selectedIndex();
      if (index < 0) return;
      final stackBox = _stackKey.currentContext?.findRenderObject();
      final tabContext = _tabKeys[index].currentContext;
      final tabBox = tabContext?.findRenderObject();
      if (stackBox is! RenderBox || tabBox is! RenderBox || !stackBox.attached || !tabBox.attached) return;
      final rect = tabBox.localToGlobal(Offset.zero, ancestor: stackBox) & tabBox.size;
      if (rect != _barRect) setState(() => _barRect = rect);
      if (scroll && tabContext != null) Scrollable.ensureVisible(tabContext, alignment: 0.5);
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = _effectiveSelected();
    final rect = _barRect;
    // The row sits inside a horizontally scrolling view, which is its own semantics boundary (an ancestor of the
    // tabBar node below): the tabBar role requires every one of its *direct* semantics children to be a tab, so it
    // wraps the row itself rather than the scroll view around it.
    // IntrinsicHeight keeps the row at its content's height (at least control-md, enforced below) instead of
    // stretching to fill a taller ambient constraint, as a horizontal scroll view otherwise would.
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: TsuyaSize.controlMd),
      child: IntrinsicHeight(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Stack(
            key: _stackKey,
            clipBehavior: Clip.none,
            children: [
              Semantics(
                container: true,
                explicitChildNodes: true,
                label: widget.label,
                role: SemanticsRole.tabBar,
                child: RovingFocus(
                  count: widget.tabs.length,
                  initialIndex: _selectedIndex() < 0 ? 0 : _selectedIndex(),
                  labelOf: (i) => widget.tabs[i].label,
                  disabledOf: (i) => widget.tabs[i].disabled,
                  builder: (context, nodes, activeIndex) {
                    if (_lastActive != null && _lastActive != activeIndex) {
                      if (!widget.manual) {
                        final next = widget.tabs[activeIndex].value;
                        // Not when the active tab only followed a selection the app made itself.
                        if (next != _effectiveSelected()) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) widget.onChanged(next);
                          });
                        }
                      }
                      _scheduleMeasure();
                    }
                    _lastActive = activeIndex;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < widget.tabs.length; i++)
                          _Tab(
                            measureKey: _tabKeys[i],
                            label: widget.tabs[i].label,
                            selected: widget.tabs[i].value == selected,
                            focusNode: nodes[i],
                            onPressed: widget.tabs[i].disabled ? null : () => widget.onChanged(widget.tabs[i].value),
                          ),
                      ],
                    );
                  },
                ),
              ),
              if (rect != null)
                AnimatedPositioned(
                  duration: motionOf(context, TsuyaDuration.fast),
                  curve: TsuyaEasing.standard,
                  left: rect.left,
                  top: rect.bottom - 2,
                  width: rect.width,
                  height: 2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Accent.of(context),
                      borderRadius: BorderRadius.circular(TsuyaRadius.full),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The panel of a [Tabs] row (DESIGN.md, Tabs): shown only while its own tab is [selected] — otherwise nothing
/// builds, so a hidden panel's [child] does no work either.
class TabView<T> extends StatelessWidget {
  /// A panel for [value], named [label] (the same text as its [TabItem.label]), shown while [selected] equals it.
  const TabView({super.key, required this.value, required this.selected, required this.label, required this.child});

  /// The tab this panel belongs to.
  final T value;

  /// The selected tab's value, as given to the paired [Tabs].
  final T? selected;

  /// The panel's accessible name (its tab's label).
  final String label;

  /// The panel's content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (value != selected) return const SizedBox.shrink();
    return Semantics(
      container: true,
      explicitChildNodes: true,
      role: SemanticsRole.tabPanel,
      label: label,
      child: child,
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.measureKey,
    required this.label,
    required this.selected,
    required this.focusNode,
    required this.onPressed,
  });

  final Key measureKey;
  final String label;
  final bool selected;
  final FocusNode focusNode;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    final colors = theme.colors;
    return Pressable(
      key: measureKey,
      onPressed: onPressed,
      role: SemanticsRole.tab,
      selected: selected,
      focusNode: focusNode,
      focusOnPress: true,
      child: Padding(
        // Centred by the row's own cross-axis alignment: a plain Padding (not Container's `alignment`, which
        // expands to fill rather than shrink-wrap) keeps the tab at its content's own height.
        padding: const EdgeInsets.symmetric(horizontal: TsuyaSpace.s12),
        child: Text(
          label,
          style: theme.text(TsuyaType.bodyStrong).copyWith(color: selected ? colors.text : colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
      ),
    );
  }
}
