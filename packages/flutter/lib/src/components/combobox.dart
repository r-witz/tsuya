// A text input that filters a listbox (DESIGN.md, Combobox); its panel is in combobox_panel.dart. `Listbox` is not
// reused here: the text field itself must keep real focus throughout, so the active option is a visual-only marker,
// not a focus target.

import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../foundation/labels.dart';
import '../foundation/listbox.dart';
import '../foundation/live_announcer.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import '../material/accent.dart';
import 'combobox_panel.dart';
import 'field.dart';
import 'text_field_box.dart';

/// A text input that filters a listbox (DESIGN.md, Combobox), with the model of the web's: typing filters [options]
/// and opens the panel below it (menu panel styling) with no option active; a press on the field, or an arrow, opens
/// every option, the chosen one active; arrows move the active option with no wrap, from none down to the first and
/// up to the last; Enter chooses it, or with none active keeps the text, which chooses an option it names (in any
/// case) and otherwise stays with [freeText] or goes back to the last chosen label; focus leaving does the same.
/// Escape closes the panel, then clears the text, then passes on. [loading] shows a spinner row instead of the
/// options; an empty list shows a "no results" row; the number of results is announced 500 ms after typing pauses,
/// and again when the options change.
class Combobox<T> extends StatefulWidget {
  /// A combobox named [label], searching [options].
  const Combobox({
    super.key,
    required this.label,
    required this.options,
    this.onSelected,
    this.filter,
    this.loading = false,
    this.freeText = false,
    this.placeholder,
    this.hint,
    this.error,
    this.optional = false,
    this.required = false,
    this.enabled = true,
    this.controller,
    this.focusNode,
    this.autofocus = false,
  });

  /// The accessible name, shown above the field.
  final String label;

  /// The candidate options; matched by [filter] against the typed text.
  final List<ListboxOption<T>> options;

  /// Called with an option's value when it is chosen.
  final ValueChanged<T>? onSelected;

  /// Matches an option against the query; a case-insensitive substring match on [ListboxOption.label] by default.
  final bool Function(ListboxOption<T> option, String query)? filter;

  /// Shows a loading row instead of the filtered options (an async fetch of them is in flight).
  final bool loading;

  /// Allows text matching no option to stand as typed; otherwise it reverts once the field loses focus.
  final bool freeText;

  /// Shown in [TsuyaColors.textMuted] while the field is empty.
  final String? placeholder;

  /// Under the field, replaced by [error].
  final String? hint;

  /// Under the field instead of [hint], with the alert glyph; also marks the field invalid in semantics.
  final String? error;

  /// Appends the optional marker to [label].
  final bool optional;

  /// Marks the field as required in semantics.
  final bool required;

  /// Disables the field: faded, read-only, not focusable.
  final bool enabled;

  /// Uncontrolled when null (the field keeps its own).
  final TextEditingController? controller;

  /// The node to track focus with, when the caller manages one.
  final FocusNode? focusNode;

  /// Focuses the field as soon as it is built.
  final bool autofocus;

  @override
  State<Combobox<T>> createState() => _ComboboxState<T>();
}

/// The state of a [Combobox]: the panel, the active option, the text typed and the last chosen label.
class _ComboboxState<T> extends State<Combobox<T>> implements TextSelectionGestureDetectorBuilderDelegate {
  @override
  final editableTextKey = GlobalKey<EditableTextState>();
  @override
  bool get forcePressEnabled => false;
  @override
  bool get selectionEnabled => widget.enabled;

  late final _gestures = TextSelectionGestureDetectorBuilder(delegate: this);
  final _overlay = OverlayPortalController();
  final _fieldKey = GlobalKey();
  final _rowKeys = <T, GlobalKey>{};
  TextEditingController? _ownController;
  FocusNode? _ownFocus;
  Timer? _announceTimer;
  String? _announcing;
  // the active option among those listed, or none; an index past their end, left by options that changed, is none
  int? _active;
  bool _open = false;
  // the text typed since the field last showed the chosen label; null while it shows it, and every option is listed
  String? _query;
  String? _lastConfirmed;

  TextEditingController get _controller => widget.controller ?? (_ownController ??= TextEditingController());
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  bool _defaultFilter(ListboxOption<T> option, String query) =>
      option.label.toLowerCase().contains(query.toLowerCase());

  List<ListboxOption<T>> get _filtered {
    final query = _query?.trim() ?? '';
    if (query.isEmpty) return widget.options;
    final test = widget.filter ?? _defaultFilter;
    return [
      for (final option in widget.options)
        if (test(option, query)) option,
    ];
  }

  int? get _current => _active != null && _active! < _filtered.length ? _active : null;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(Combobox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_open && _message != _announcing) _scheduleAnnouncement();
  }

  @override
  void dispose() {
    _announceTimer?.cancel();
    _focus.removeListener(_onFocusChanged);
    _ownController?.dispose();
    _ownFocus?.dispose();
    super.dispose();
  }

  // Sets the text programmatically. `EditableText` does not reliably call `onChanged` back for every such change
  // (observed: it does not when called while handling a `TextInputAction`), so callers that also need to force the
  // panel open or closed do that themselves, last, rather than relying on the `onChanged` this may or may not fire.
  void _setText(String text) {
    _controller.text = text;
    _controller.selection = TextSelection.collapsed(offset: text.length);
  }

  void _onTextChanged(String text) {
    _query = text;
    _show();
  }

  // opens the panel: on the chosen option while the field shows it, otherwise at [at] (first or last) or on none
  void _show({bool? last}) {
    if (!widget.enabled) return;
    final options = _filtered;
    final chosen = _query == null ? options.indexWhere((o) => o.label == _lastConfirmed) : -1;
    setState(() {
      _open = true;
      _active = chosen != -1 ? chosen : (last == null ? null : _edge(options, last: last));
    });
    _overlay.show();
    _scheduleAnnouncement();
  }

  int? _edge(List<ListboxOption<T>> options, {required bool last}) {
    final enabled = [
      for (var i = 0; i < options.length; i++)
        if (!options[i].disabled) i,
    ];
    return enabled.isEmpty ? null : (last ? enabled.last : enabled.first);
  }

  void _onFocusChanged() {
    if (_focus.hasFocus) return;
    _commit();
  }

  String get _message {
    final labels = TsuyaLabels.of(context);
    final count = _filtered.length;
    return widget.loading ? labels.loading : (count == 0 ? labels.noResults : labels.results(count));
  }

  void _scheduleAnnouncement() {
    _announceTimer?.cancel();
    _announcing = _message;
    _announceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted && _open) announce(context, _message);
    });
  }

  void _move(int delta) {
    if (!_open) {
      _show(last: delta < 0);
      return;
    }
    final options = _filtered;
    final current = _current;
    if (current == null) {
      setState(() => _active = _edge(options, last: delta < 0));
    } else {
      var next = current + delta;
      while (next >= 0 && next < options.length && options[next].disabled) {
        next += delta;
      }
      if (next < 0 || next >= options.length) return;
      setState(() => _active = next);
    }
    final active = _active;
    final rowContext = active == null ? null : _rowKeys[options[active].value]?.currentContext;
    if (rowContext != null) Scrollable.ensureVisible(rowContext, alignment: 0.5, duration: Duration.zero);
  }

  void _onSubmitted() {
    if (!_open) return;
    final current = _current;
    if (current != null) {
      _choose(_filtered[current]);
    } else {
      _commit();
    }
  }

  void _choose(ListboxOption<T> option) {
    _setText(option.label);
    _lastConfirmed = option.label;
    _query = null;
    widget.onSelected?.call(option.value);
    _close();
  }

  // the text as it is: a text that names an option chooses it; otherwise free text stays, other text goes back
  void _commit() {
    final text = _controller.text;
    _query = null;
    if (_lastConfirmed != null && text == _lastConfirmed) return _close();
    final wanted = text.trim().toLowerCase();
    for (final option in widget.options) {
      if (wanted.isNotEmpty && !option.disabled && option.label.toLowerCase() == wanted) return _choose(option);
    }
    if (widget.freeText || wanted.isEmpty) {
      _lastConfirmed = null;
      if (wanted.isEmpty) _setText('');
    } else {
      _setText(_lastConfirmed ?? '');
    }
    _close();
  }

  void _close() {
    _announceTimer?.cancel();
    if (!_open) return;
    setState(() => _open = false);
    _overlay.hide();
  }

  // Escape: closes the panel, then clears the text; with neither to do, it is not this field's
  void _escape() {
    if (_open) return _close();
    setState(() {
      _setText('');
      _lastConfirmed = null;
      _query = null;
    });
  }

  Widget _buildPanel(BuildContext overlayContext) => comboboxPanel<T>(
    overlayContext,
    anchorKey: _fieldKey,
    loading: widget.loading,
    options: _filtered,
    active: _current,
    onChoose: _choose,
    onHover: (index) => setState(() => _active = index),
    rowKeys: _rowKeys,
  );

  Widget _buildField(BuildContext context) => _comboboxKeys(
    key: _fieldKey,
    text: _controller,
    canEscape: () => _open || _controller.text.isNotEmpty,
    onEscape: _escape,
    onArrow: _move,
    onPress: () {
      if (!_open) _show();
    },
    child: Semantics(
      container: true,
      role: SemanticsRole.comboBox,
      expanded: _open,
      child: _comboboxField(
        context: context,
        editableTextKey: editableTextKey,
        controller: _controller,
        focusNode: _focus,
        enabled: widget.enabled,
        error: widget.error,
        placeholder: widget.placeholder,
        gestures: _gestures,
        onChanged: _onTextChanged,
        onSubmitted: (_) => _onSubmitted(),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    Widget result = Field(
      label: widget.label,
      hint: widget.hint,
      error: widget.error,
      optional: widget.optional,
      required: widget.required,
      child: OverlayPortal(controller: _overlay, overlayChildBuilder: _buildPanel, child: _buildField(context)),
    );
    if (!widget.enabled) {
      result = Opacity(
        opacity: TsuyaState.disabledOpacity,
        child: ExcludeFocus(child: IgnorePointer(child: result)),
      );
    }
    return result;
  }
}

/// The text field chrome of a `Combobox`: an [EditableText] over [controller] and [focusNode], boxed the way a
/// `TextField` is, its border the accent while focused, [TsuyaColors.danger] with [error].
Widget _comboboxField({
  required BuildContext context,
  required GlobalKey<EditableTextState> editableTextKey,
  required TextEditingController controller,
  required FocusNode focusNode,
  required bool enabled,
  required String? error,
  required String? placeholder,
  required TextSelectionGestureDetectorBuilder gestures,
  required ValueChanged<String> onChanged,
  required ValueChanged<String> onSubmitted,
}) {
  final theme = TsuyaTheme.of(context);
  final colors = theme.colors;
  final accent = Accent.of(context);
  final style = theme.text(TsuyaType.body).copyWith(color: colors.text);

  final editable = EditableText(
    key: editableTextKey,
    controller: controller,
    focusNode: focusNode,
    readOnly: !enabled,
    style: style,
    cursorColor: accent,
    backgroundCursorColor: colors.textMuted,
    selectionColor: accent.withValues(alpha: 0.3),
    selectionControls: tsuyaTextSelectionHandles,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
    rendererIgnoresPointer: true,
  );

  return ListenableBuilder(
    listenable: focusNode,
    builder: (context, _) {
      final (color, width) = switch ((error, focusNode.hasFocus)) {
        (_?, _) => (colors.danger, TsuyaState.focusWidth),
        (null, true) => (accent, TsuyaState.focusWidth),
        (null, false) => (colors.borderStrong, 1.0),
      };
      return TextFieldBox(
        controller: controller,
        radius: BorderRadius.circular(TsuyaRadius.sm),
        borderColor: color,
        borderWidth: width,
        glass: false,
        minHeight: TsuyaSize.controlMd,
        multiline: false,
        placeholder: placeholder,
        style: style,
        trailingItems: const [],
        editable: gestures.buildGestureDetector(behavior: HitTestBehavior.translucent, child: editable),
      );
    },
  );
}

/// The keys and presses of a `Combobox`'s field around [child]: a press calls [onPress], the arrows [onArrow] with
/// 1 or -1, and Escape, through `DismissIntent`, [onEscape]. The Escape action is declared only while
/// [canEscape] holds, checked again as [text] changes: a disabled action would still keep the key from a dialog
/// around the field.
Widget _comboboxKeys({
  required Key key,
  required Listenable text,
  required bool Function() canEscape,
  required VoidCallback onEscape,
  required ValueChanged<int> onArrow,
  required VoidCallback onPress,
  required Widget child,
}) => Listener(
  key: key,
  onPointerUp: (_) => onPress(),
  child: CallbackShortcuts(
    bindings: {
      const SingleActivator(LogicalKeyboardKey.arrowDown): () => onArrow(1),
      const SingleActivator(LogicalKeyboardKey.arrowUp): () => onArrow(-1),
    },
    child: ListenableBuilder(
      listenable: text,
      builder: (context, child) => Actions(
        actions: {if (canEscape()) DismissIntent: CallbackAction<DismissIntent>(onInvoke: (_) => onEscape())},
        child: child!,
      ),
      child: Shortcuts(shortcuts: const {SingleActivator(LogicalKeyboardKey.escape): DismissIntent()}, child: child),
    ),
  ),
);
