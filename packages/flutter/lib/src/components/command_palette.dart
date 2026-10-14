// A search-driven list of commands (DESIGN.md, CommandPalette).

import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../foundation/labels.dart';
import '../foundation/live_announcer.dart';
import '../foundation/modal_scrim.dart';
import '../foundation/overlay_show.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import 'text_field.dart';
import 'text_field_box.dart' show TextFieldSize;

// a dialog at most 560 wide.
const _maxWidth = 560.0;

// the palette sits near the top: space-64 below it.
const _topOffset = TsuyaSpace.s64;

// as the Combobox: the result count is announced once typing has paused.
const _announceDelay = Duration(milliseconds: 500);

// as the Dialog it is a kind of: it grows from 0.98.
const _from = 0.98;

/// A search-driven list of commands (DESIGN.md, CommandPalette): a dialog at most 560 wide near the top, a search field
/// with no visible label over a listbox of [CommandGroup]s. Type to filter, the arrows move (stopping at the ends),
/// Enter runs the active command, Escape closes it; with no match it says so. Groups show in the order given: put the
/// recent commands in the first one. The app opens it, usually on Ctrl or Cmd+K; tsuya binds no shortcut.
abstract final class CommandPalette {
  /// Shows a palette of [groups] above everything; a command runs through [onSelected] once the palette has closed and
  /// focus has returned to where it was, so that the command can move it. [filter] says whether a command matches the
  /// query (a case-insensitive substring of its label by default). [barrierLabel] names the scrim for a screen reader.
  static Future<void> show<T>(
    BuildContext context, {
    required List<CommandGroup<T>> groups,
    required ValueChanged<T> onSelected,
    bool Function(Command<T> command, String query)? filter,
    String? barrierLabel,
  }) {
    T? chosen;
    var run = false;
    return showTsuyaOverlay<void>(
      context: context,
      onRemoved: () {
        if (run) onSelected(chosen as T);
      },
      builder: (context, animation, wrap, close) {
        final curved = animation.drive(CurveTween(curve: TsuyaEasing.standard));
        return Stack(
          children: [
            ModalScrim(opacity: curved, barrierLabel: barrierLabel, onDismiss: close),
            LayoutBuilder(
              builder: (context, constraints) {
                final inset = MediaQuery.viewInsetsOf(context).bottom;
                return Padding(
                  padding: EdgeInsets.only(top: _topOffset, left: TsuyaSpace.s16, right: TsuyaSpace.s16),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: _maxWidth,
                        maxHeight: constraints.maxHeight - _topOffset - inset - TsuyaSpace.s16,
                      ),
                      child: wrap(
                        FadeTransition(
                          opacity: curved,
                          child: ScaleTransition(
                            scale: curved.drive(Tween<double>(begin: _from, end: 1)),
                            child: _Palette<T>(
                              groups: groups,
                              filter: filter ?? _matches,
                              onRun: (command) {
                                chosen = command.value;
                                run = true;
                                close();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

bool _matches<T>(Command<T> command, String query) => command.label.toLowerCase().contains(query.trim().toLowerCase());

class _Palette<T> extends StatefulWidget {
  const _Palette({required this.groups, required this.filter, required this.onRun});

  final List<CommandGroup<T>> groups;
  final bool Function(Command<T> command, String query) filter;
  final ValueChanged<Command<T>> onRun;

  @override
  State<_Palette<T>> createState() => _PaletteState<T>();
}

class _PaletteState<T> extends State<_Palette<T>> {
  final _controller = TextEditingController();
  final _focus = FocusNode(debugLabel: 'CommandPalette search');
  final _keys = <Command<T>, GlobalKey>{};
  Timer? _announce;
  int _active = 0;

  List<CommandGroup<T>> get _visible => [
    for (final group in widget.groups)
      if (group.commands.any((c) => widget.filter(c, _controller.text)))
        CommandGroup(
          label: group.label,
          commands: [
            for (final c in group.commands)
              if (widget.filter(c, _controller.text)) c,
          ],
        ),
  ];

  List<Command<T>> get _commands => [for (final group in _visible) ...group.commands];

  int _firstEnabled() => _commands.indexWhere((c) => !c.disabled).clamp(0, _commands.length);

  @override
  void dispose() {
    _announce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String _) {
    setState(() => _active = _firstEnabled());
    _announce?.cancel();
    _announce = Timer(_announceDelay, () {
      if (!mounted) return;
      final labels = TsuyaLabels.of(context);
      final count = _commands.length;
      announce(context, count == 0 ? labels.noResults : labels.results(count));
    });
  }

  void _move(int delta) {
    final commands = _commands;
    if (commands.isEmpty) return;
    // past a disabled command, and stopping at the ends
    var next = _active + delta;
    while (next >= 0 && next < commands.length && commands[next].disabled) {
      next += delta;
    }
    if (next < 0 || next >= commands.length) return;
    setState(() => _active = next);
    final rowContext = _keys[commands[next]]?.currentContext;
    if (rowContext != null) Scrollable.ensureVisible(rowContext, duration: Duration.zero);
  }

  void _runActive() {
    final commands = _commands;
    if (_active < commands.length && !commands[_active].disabled) widget.onRun(commands[_active]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    final colors = theme.colors;
    final labels = TsuyaLabels.of(context);
    final commands = _commands;
    final rows = <Widget>[];
    var index = 0;
    for (final group in _visible) {
      rows.add(_CommandGroupHeading(label: group.label));
      for (final command in group.commands) {
        final i = index++;
        rows.add(
          _CommandRow<T>(
            key: _keys.putIfAbsent(command, GlobalKey.new),
            command: command,
            active: i == _active,
            onHover: () => setState(() => _active = i),
            onRun: () => widget.onRun(command),
          ),
        );
      }
    }
    final list = commands.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(TsuyaSpace.s24),
            child: Center(
              child: Text(labels.noResults, style: theme.text(TsuyaType.body).copyWith(color: colors.textMuted)),
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(TsuyaSpace.s8, 0, TsuyaSpace.s8, TsuyaSpace.s8),
            child: Semantics(
              role: SemanticsRole.list,
              explicitChildNodes: true,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
            ),
          );
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowDown): () => _move(1),
        const SingleActivator(LogicalKeyboardKey.arrowUp): () => _move(-1),
      },
      child: Semantics(
        role: SemanticsRole.dialog,
        scopesRoute: true,
        namesRoute: true,
        explicitChildNodes: true,
        label: labels.search,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(TsuyaRadius.lg),
            border: Border.all(color: colors.border, strokeAlign: BorderSide.strokeAlignOutside),
            boxShadow: theme.shadows.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(TsuyaSpace.s12),
                child: TextField.search(
                  label: labels.search,
                  placeholder: labels.search,
                  controller: _controller,
                  focusNode: _focus,
                  autofocus: true,
                  size: TextFieldSize.md,
                  onChanged: _onChanged,
                  onSubmitted: (_) => _runActive(),
                ),
              ),
              ColoredBox(color: colors.border, child: const SizedBox(height: 1)),
              Flexible(child: list),
            ],
          ),
        ),
      ),
    );
  }
}

/// A command the palette can run, with the [value] [CommandPalette.show]'s `onSelected` gets.
@immutable
class Command<T> {
  /// A command named [label] that runs as [value].
  const Command({required this.value, required this.label, this.disabled = false});

  /// What `onSelected` is called with.
  final T value;

  /// What it is called; matched against the query and read by a screen reader.
  final String label;

  /// Shown but cannot be run.
  final bool disabled;
}

/// A titled group of [commands] in a [CommandPalette].
@immutable
class CommandGroup<T> {
  /// A group headed [label].
  const CommandGroup({required this.label, required this.commands});

  /// The group's heading.
  final String label;

  /// Its commands, in order.
  final List<Command<T>> commands;
}

/// A group's heading in the list.
class _CommandGroupHeading extends StatelessWidget {
  /// A heading reading [label].
  const _CommandGroupHeading({required this.label});

  /// The group's name.
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(TsuyaSpace.s12, TsuyaSpace.s12, TsuyaSpace.s12, TsuyaSpace.s4),
        child: Text(label, style: theme.text(TsuyaType.label).copyWith(color: theme.colors.textMuted)),
      ),
    );
  }
}

/// One command's row: [active] is marked on [TsuyaColors.fill], and hovering makes it active.
class _CommandRow<T> extends StatelessWidget {
  /// A row for [command].
  const _CommandRow({
    super.key,
    required this.command,
    required this.active,
    required this.onHover,
    required this.onRun,
  });

  /// The command shown.
  final Command<T> command;

  /// Whether it is the active descendant.
  final bool active;

  /// Called when the pointer moves onto it.
  final VoidCallback onHover;

  /// Called when it is pressed.
  final VoidCallback onRun;

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    final colors = theme.colors;
    Widget row = Container(
      constraints: const BoxConstraints(minHeight: TsuyaSize.controlMd),
      padding: const EdgeInsets.symmetric(horizontal: TsuyaSpace.s12),
      decoration: BoxDecoration(
        color: active ? colors.fill : null,
        borderRadius: BorderRadius.circular(TsuyaRadius.sm),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(command.label, style: theme.text(TsuyaType.body).copyWith(color: colors.text)),
          ),
        ],
      ),
    );
    if (command.disabled) row = Opacity(opacity: TsuyaState.disabledOpacity, child: row);
    return Semantics(
      role: SemanticsRole.listItem,
      focused: active,
      enabled: !command.disabled,
      child: MouseRegion(
        onHover: (_) => onHover(),
        child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: command.disabled ? null : onRun, child: row),
      ),
    );
  }
}
