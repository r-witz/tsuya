// Options, an active descendant, selection, type-ahead, groups and an empty state (DESIGN.md, Foundations:
// Accessibility). Reused by Select, Combobox and CommandPalette.
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'type_ahead.dart';

/// One option of a [Listbox].
@immutable
class ListboxOption<T> {
  /// An option named [label], identified by [value].
  const ListboxOption({required this.value, required this.label, this.disabled = false, this.group});

  /// What [Listbox.onSelected] is called with.
  final T value;

  /// Shown by the item, and matched against type-ahead.
  final String label;

  /// Excluded from navigation and selection.
  final bool disabled;

  /// Clusters this option under a heading with the others that share it. Options sharing a group should be
  /// adjacent; [Listbox] draws a heading whenever the group changes from the option before.
  final String? group;
}

/// A list of options with one active descendant: the list itself holds keyboard focus, and the
/// active option is marked rather than truly focused, as `aria-activedescendant` does on the web. Arrow keys move the
/// active option (stopping at the ends), Home and End jump to the ends, typing searches by label, and Enter or Space
/// selects. [multiple] changes only how selection is announced (checked, not just selected); the caller still owns
/// [selected] and decides what [onSelected] does to it.
class Listbox<T> extends StatefulWidget {
  /// A listbox of [options], with [selected] marked and [onSelected] called on a choice.
  const Listbox({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.multiple = false,
    required this.itemBuilder,
    this.groupBuilder,
    this.empty,
    this.focusNode,
    this.autofocus = false,
  });

  /// The options, in order; options sharing a [ListboxOption.group] should be adjacent.
  final List<ListboxOption<T>> options;

  /// The currently selected values.
  final Set<T> selected;

  /// Called with an option's value when it is chosen.
  final ValueChanged<T> onSelected;

  /// Whether more than one option can be selected at once (changes only the semantics reported).
  final bool multiple;

  /// Builds one option's row.
  final Widget Function(BuildContext context, ListboxOption<T> option, {required bool active, required bool selected})
  itemBuilder;

  /// Builds a group heading, called with [ListboxOption.group].
  final Widget Function(BuildContext context, String group)? groupBuilder;

  /// Shown instead of the list when [options] is empty.
  final Widget? empty;

  /// The node the list itself is focused with, when the caller manages one.
  final FocusNode? focusNode;

  /// Focuses the list as soon as it is built.
  final bool autofocus;

  @override
  State<Listbox<T>> createState() => _ListboxState<T>();
}

class _ListboxState<T> extends State<Listbox<T>> {
  late final FocusNode _focusNode;
  bool _ownsFocusNode = false;
  late int _active = _firstEnabled();
  final _typeAhead = TypeAhead();

  int _firstEnabled() {
    final index = widget.options.indexWhere((o) => !o.disabled);
    return index < 0 ? 0 : index;
  }

  @override
  void initState() {
    super.initState();
    final given = widget.focusNode;
    if (given == null) {
      _focusNode = FocusNode(debugLabel: 'Listbox');
      _ownsFocusNode = true;
    } else {
      _focusNode = given;
    }
  }

  @override
  void didUpdateWidget(Listbox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_active >= widget.options.length) _active = _firstEnabled();
  }

  @override
  void dispose() {
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _moveTo(int index) {
    if (index < 0 || index >= widget.options.length || widget.options[index].disabled) return;
    setState(() => _active = index);
  }

  void _move(int delta) {
    // past a disabled option, and stopping at the ends
    var next = _active + delta;
    while (next >= 0 && next < widget.options.length && widget.options[next].disabled) {
      next += delta;
    }
    _moveTo(next);
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    if (widget.options.isEmpty) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown) {
      _move(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _move(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.home) {
      _moveTo(widget.options.indexWhere((o) => !o.disabled));
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end) {
      _moveTo(widget.options.lastIndexWhere((o) => !o.disabled));
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
      if (!widget.options[_active].disabled) widget.onSelected(widget.options[_active].value);
      return KeyEventResult.handled;
    }
    if (isTypeAheadKey(event)) {
      final target = _typeAhead.type(event.character!, [for (final o in widget.options) o.label], _active);
      if (target != null) {
        _moveTo(target);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.options.isEmpty) return widget.empty ?? const SizedBox.shrink();
    final rows = <Widget>[];
    String? lastGroup;
    for (var i = 0; i < widget.options.length; i++) {
      final option = widget.options[i];
      final group = option.group;
      if (group != null && group != lastGroup && widget.groupBuilder != null) {
        rows.add(widget.groupBuilder!(context, group));
      }
      lastGroup = group;
      final selected = widget.selected.contains(option.value);
      rows.add(
        Semantics(
          role: SemanticsRole.listItem,
          focused: i == _active,
          enabled: !option.disabled,
          selected: widget.multiple ? null : selected,
          checked: widget.multiple ? selected : null,
          child: GestureDetector(
            onTap: option.disabled
                ? null
                : () {
                    _moveTo(i);
                    widget.onSelected(option.value);
                  },
            child: widget.itemBuilder(context, option, active: i == _active, selected: selected),
          ),
        ),
      );
    }
    // Focus wraps the list, not the other way around: a focusable Focus contributes its own SemanticsNode, and one
    // interposed between the list and its items would break the list/listItem parent-child requirement.
    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onKeyEvent: _handleKey,
      child: Semantics(
        role: SemanticsRole.list,
        explicitChildNodes: true,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
      ),
    );
  }
}
