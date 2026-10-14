// A choice among options too many to show at once (DESIGN.md, Select): a trigger that looks like a
// text field, a listbox panel (menu panel styling) anchored under it, or a sheet on a phone.
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../foundation/dismissable_layer.dart';
import '../foundation/labels.dart';
import '../foundation/listbox.dart';
import '../foundation/pressable.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import 'control_body.dart';
import 'field.dart';
import 'glyphs.dart';
import 'menu_panel.dart';
import 'sheet.dart';

/// A choice among options too many to show at once, or not all seen together (DESIGN.md, Select). The trigger
/// looks like a text field with a chevron and the selected label (or [placeholder]); Enter, Space or an arrow key
/// opens a listbox panel (menu panel styling) anchored under it, the selected option ticked and scrolled into
/// view. Type-ahead, groups and separators come from the listbox; Escape closes it. Below [TsuyaBreakpoint.tablet]
/// the options open in a [Sheet] titled by [label] instead, unless [sheetOnPhone] is false.
class Select<T> extends StatefulWidget {
  /// A select named [label], [value] chosen among [options].
  const Select({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.options,
    this.placeholder,
    this.sheetOnPhone = true,
    this.focusNode,
    this.autofocus = false,
  });

  /// The accessible name, shown above the trigger.
  final String label;

  /// The chosen value, or null when nothing is chosen yet.
  final T? value;

  /// Called with an option's value when it is chosen; null disables the control.
  final ValueChanged<T>? onChanged;

  /// The options, in order; options sharing a [ListboxOption.group] should be adjacent.
  final List<ListboxOption<T>> options;

  /// Shown in [TsuyaColors.textMuted] while nothing is chosen; never announced (a placeholder is not a value).
  final String? placeholder;

  /// Below the tablet width, the options open in a sheet rather than a panel.
  final bool sheetOnPhone;

  /// The node to track the trigger's focus with, when the caller manages one.
  final FocusNode? focusNode;

  /// Focuses the trigger as soon as it is built.
  final bool autofocus;

  @override
  State<Select<T>> createState() => _SelectState<T>();
}

class _OpenIntent extends Intent {
  const _OpenIntent();
}

class _SelectState<T> extends State<Select<T>> {
  final _overlay = OverlayPortalController();
  final _triggerKey = GlobalKey();
  final _listboxFocus = FocusNode(debugLabel: 'Select listbox');
  final _rowKeys = <T, GlobalKey>{};
  FocusNode? _ownTriggerFocus;
  bool _expanded = false;
  // As OpenerButton: a press that closed the panel (an outside press closes it as the pointer goes down, before this
  // is rebuilt) must not open it again as the pointer comes up.
  bool _shownExpanded = false;
  bool _openAtPointerDown = false;

  FocusNode get _triggerFocus => widget.focusNode ?? (_ownTriggerFocus ??= FocusNode(debugLabel: 'Select trigger'));

  @override
  void dispose() {
    _ownTriggerFocus?.dispose();
    _listboxFocus.dispose();
    super.dispose();
  }

  ListboxOption<T>? _optionFor(T? value) {
    for (final option in widget.options) {
      if (option.value == value) return option;
    }
    return null;
  }

  void _open() {
    if (_expanded || widget.onChanged == null) return;
    if (widget.sheetOnPhone && MediaQuery.sizeOf(context).width < TsuyaBreakpoint.tablet) {
      _openSheet();
      return;
    }
    setState(() => _expanded = true);
    _overlay.show();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _listboxFocus.requestFocus();
      final rowContext = _rowKeys[widget.value]?.currentContext;
      if (rowContext != null) Scrollable.ensureVisible(rowContext, alignment: 0.5);
    });
  }

  void _close() {
    if (!_expanded) return;
    setState(() => _expanded = false);
    _overlay.hide();
    // back to the trigger from the listbox, but not from a control that took focus (Shift+Tab off the trigger)
    if (_listboxFocus.hasFocus || FocusManager.instance.primaryFocus == null) _triggerFocus.requestFocus();
  }

  // the options in a sheet: the choice comes back as its result, wrapped so that a null value stays a choice
  Future<void> _openSheet() async {
    setState(() => _expanded = true);
    final chosen = await Sheet.show<(T,)>(
      context,
      builder: (sheetContext) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _listboxFocus.requestFocus());
        final theme = TsuyaTheme.of(sheetContext);
        return Sheet(
          label: widget.label,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Text(widget.label, style: theme.text(TsuyaType.titleM).copyWith(color: theme.colors.text)),
              ),
              const SizedBox(height: TsuyaSpace.s12),
              _listbox(sheetContext, (value) => Sheet.close(sheetContext, (value,))),
            ],
          ),
        );
      },
    );
    if (!mounted) return;
    setState(() => _expanded = false);
    if (chosen != null) widget.onChanged?.call(chosen.$1);
    _triggerFocus.requestFocus();
  }

  void _toggle() {
    if (_openAtPointerDown) {
      _openAtPointerDown = false;
      return;
    }
    _expanded ? _close() : _open();
  }

  void _select(T value) {
    widget.onChanged?.call(value);
    _close();
  }

  Widget _buildRow(BuildContext context, ListboxOption<T> option, {required bool active, required bool selected}) {
    final colors = TsuyaTheme.of(context).colors;
    final theme = TsuyaTheme.of(context);
    return Container(
      key: _rowKeys.putIfAbsent(option.value, GlobalKey.new),
      padding: const EdgeInsets.symmetric(horizontal: TsuyaSpace.s12, vertical: TsuyaSpace.s8),
      color: active ? colors.fill : null,
      child: Row(
        children: [
          Expanded(
            child: Text(
              option.label,
              style: theme.text(TsuyaType.body).copyWith(color: option.disabled ? colors.textMuted : colors.text),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (selected) ...[
            const SizedBox(width: TsuyaSpace.s8),
            Glyph(TsuyaGlyph.check, size: TsuyaSize.iconSm, color: colors.text),
          ],
        ],
      ),
    );
  }

  Widget _listbox(BuildContext context, ValueChanged<T> onSelected) => Listbox<T>(
    options: widget.options,
    selected: widget.value == null ? const {} : {widget.value as T},
    onSelected: onSelected,
    focusNode: _listboxFocus,
    itemBuilder: _buildRow,
    empty: Padding(padding: const EdgeInsets.all(TsuyaSpace.s12), child: Text(TsuyaLabels.of(context).noResults)),
  );

  Widget _buildPanel(BuildContext overlayContext) {
    final anchor = _triggerKey.currentContext?.findRenderObject();
    if (anchor is! RenderBox || !anchor.attached) return const SizedBox.shrink();
    return AnchoredPanel(
      anchor: anchor,
      wrap: (panel) => DismissableLayer(modal: false, opener: _triggerFocus, onDismiss: _close, child: panel),
      child: SingleChildScrollView(child: _listbox(overlayContext, _select)),
    );
  }

  Widget _buildTrigger(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    final colors = theme.colors;
    final selectedOption = _optionFor(widget.value);
    final shown = selectedOption?.label ?? widget.placeholder;
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.arrowDown): _OpenIntent(),
        SingleActivator(LogicalKeyboardKey.arrowUp): _OpenIntent(),
      },
      child: Actions(
        actions: {_OpenIntent: CallbackAction<_OpenIntent>(onInvoke: (_) => _open())},
        child: Listener(
          onPointerDown: (_) => _openAtPointerDown = _shownExpanded,
          child: Pressable(
            key: _triggerKey,
            onPressed: widget.onChanged == null ? null : _toggle,
            role: SemanticsRole.comboBox,
            expanded: _expanded,
            value: selectedOption?.label,
            borderRadius: BorderRadius.circular(TsuyaRadius.sm),
            focusNode: _triggerFocus,
            autofocus: widget.autofocus,
            child: ControlBody(
              fill: colors.fill,
              border: colors.borderStrong,
              radius: BorderRadius.circular(TsuyaRadius.sm),
              child: ExcludeSemantics(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: TsuyaSpace.s12),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: TsuyaSize.controlMd),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            shown ?? '',
                            style: theme
                                .text(TsuyaType.body)
                                .copyWith(color: selectedOption == null ? colors.textMuted : colors.text),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: TsuyaSpace.s8),
                        Glyph(TsuyaGlyph.chevronDown, size: TsuyaSize.iconSm, color: colors.textMuted),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _shownExpanded = _expanded;
    return Field(
      label: widget.label,
      child: OverlayPortal(controller: _overlay, overlayChildBuilder: _buildPanel, child: _buildTrigger(context)),
    );
  }
}
