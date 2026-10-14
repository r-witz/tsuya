// A labelled text input (DESIGN.md, TextField, Textarea, Search), built on EditableText: its own
// selection handles and context menu, the system one on iOS where it is supported.

import 'dart:math' as math;

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../foundation/labels.dart';
import '../foundation/pressable.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import '../material/accent.dart';
import 'field.dart';
import 'glyphs.dart';
import 'menu_panel.dart';
import 'text_field_box.dart';

/// A labelled text input (DESIGN.md, TextField): [label] sits above the field; [hint] or [error] goes under it. The
/// box turns to the accent when focused, to [TsuyaColors.danger] with an [error]. Built on [EditableText]: its own
/// selection handles (accent teardrops) and its own context menu (Cut, Copy, Paste, Select all), except on iOS where
/// the system context menu is used. Use [TextField.search] for a search field (a pill with no visible label).
class TextField extends StatefulWidget {
  /// A text field labelled [label].
  const TextField({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.hint,
    this.error,
    this.optional = false,
    this.required = false,
    this.leading,
    this.trailing,
    this.clearable = false,
    this.obscureText = false,
    this.revealable = true,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
    this.contextMenuBuilder,
  }) : _search = false,
       glass = false,
       size = TextFieldSize.md;

  /// A search field (DESIGN.md, Search): a pill with a leading search glyph, a clear button by default, and no
  /// visible label ([label] is still required, used for semantics). [glass] uses control glass over content.
  const TextField.search({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.autofocus = false,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.glass = false,
    this.size = TextFieldSize.md,
  }) : hint = null,
       error = null,
       optional = false,
       required = false,
       leading = null,
       trailing = null,
       clearable = true,
       obscureText = false,
       revealable = false,
       maxLines = 1,
       minLines = null,
       keyboardType = null,
       textInputAction = null,
       autofillHints = null,
       contextMenuBuilder = null,
       _search = true;

  /// Above the field, or only announced for a search field.
  final String label;

  /// Uncontrolled when null (the field keeps its own).
  final TextEditingController? controller;

  /// A node the field keeps when none is given.
  final FocusNode? focusNode;

  /// Shown in [TsuyaColors.textMuted] while the field is empty; never read by a screen reader.
  final String? placeholder;

  /// Under the field, replaced by [error].
  final String? hint;

  /// Under the field instead of [hint], with the alert glyph; also marks the field invalid in semantics.
  final String? error;

  /// Appends the optional marker to [label].
  final bool optional;

  /// Marks the field as required in semantics.
  final bool required;

  /// Before the text, in [TsuyaColors.textMuted].
  final Widget? leading;

  /// After the text, after any clear or reveal button.
  final Widget? trailing;

  /// Shows a clear button (from the labels) while the field holds text.
  final bool clearable;

  /// Hides the text, one line only.
  final bool obscureText;

  /// With [obscureText], shows a show/hide button (from the labels).
  final bool revealable;

  /// Disables the field: faded, read-only, not focusable.
  final bool enabled;

  /// Focuses the field as soon as it is built.
  final bool autofocus;

  /// At least twice [TsuyaSize.controlMd] tall and scrolling once reached, when more than 1 (or null).
  final int? maxLines;

  /// The fewest lines the field reserves room for.
  final int? minLines;

  /// The on-screen keyboard to show.
  final TextInputType? keyboardType;

  /// The action its submit key performs.
  final TextInputAction? textInputAction;

  /// Autofill group hints (email, password…).
  final Iterable<String>? autofillHints;

  /// Called on every change.
  final ValueChanged<String>? onChanged;

  /// Called when the field is submitted.
  final ValueChanged<String>? onSubmitted;

  /// Replaces the field's own context menu; `null` keeps it (the system one on iOS where supported).
  final EditableTextContextMenuBuilder? contextMenuBuilder;

  /// Control glass instead of a plain fill; set by [TextField.search] only.
  final bool glass;

  /// The field's height; set by [TextField.search] only ([TsuyaSize.controlMd] otherwise, and by default, as the
  /// web's `SearchInput`).
  final TextFieldSize size;

  final bool _search;

  @override
  State<TextField> createState() => _TextFieldState();
}

class _TextFieldState extends State<TextField> implements TextSelectionGestureDetectorBuilderDelegate {
  @override
  final editableTextKey = GlobalKey<EditableTextState>();
  @override
  bool get forcePressEnabled => false;
  @override
  bool get selectionEnabled => widget.enabled;

  late final _gestures = TextSelectionGestureDetectorBuilder(delegate: this);
  TextEditingController? _ownController;
  FocusNode? _ownFocus;
  bool _obscured = true;

  TextEditingController get _controller => widget.controller ?? (_ownController ??= TextEditingController());
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  @override
  void dispose() {
    _ownController?.dispose();
    _ownFocus?.dispose();
    super.dispose();
  }

  Widget _contextMenu(BuildContext context, EditableTextState state) {
    if (widget.contextMenuBuilder case final builder?) return builder(context, state);
    if (SystemContextMenu.isSupportedByField(state)) return SystemContextMenu.editableText(editableTextState: state);
    return _textFieldContextMenu(context, state);
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    final colors = theme.colors;
    final labels = TsuyaLabels.of(context);
    final accent = Accent.of(context);
    final multiline = widget.maxLines != 1;
    final radius = BorderRadius.circular(widget._search ? widget.size.height / 2 : TsuyaRadius.sm);
    final style = theme.text(TsuyaType.body).copyWith(color: colors.text);
    final obscure = widget.obscureText && _obscured;

    final editable = EditableText(
      key: editableTextKey,
      controller: _controller,
      focusNode: _focus,
      readOnly: !widget.enabled,
      obscureText: obscure,
      autofocus: widget.autofocus,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,
      keyboardType: widget.keyboardType ?? (widget.obscureText ? TextInputType.visiblePassword : TextInputType.text),
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      style: style,
      cursorColor: accent,
      backgroundCursorColor: colors.textMuted,
      selectionColor: accent.withValues(alpha: 0.3),
      selectionControls: tsuyaTextSelectionHandles,
      contextMenuBuilder: _contextMenu,
      rendererIgnoresPointer: true,
    );

    final leadingIcon = widget._search ? Glyph(TsuyaGlyph.search, color: colors.textMuted) : widget.leading;
    final trailingItems = <Widget>[
      if (widget.obscureText && widget.revealable)
        _actionButton(
          context,
          glyph: _obscured ? TsuyaGlyph.eye : TsuyaGlyph.eyeOff,
          label: _obscured ? labels.showPassword : labels.hidePassword,
          onPressed: () => setState(() => _obscured = !_obscured),
        ),
      ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => widget.clearable && _controller.text.isNotEmpty
            ? _actionButton(context, glyph: TsuyaGlyph.close, label: labels.clear, onPressed: _clear)
            : const SizedBox.shrink(),
      ),
      ?widget.trailing,
    ];

    final field = ListenableBuilder(
      listenable: Listenable.merge([_controller, _focus]),
      builder: (context, _) {
        final (color, width) = switch ((widget.error, _focus.hasFocus)) {
          (_?, _) => (colors.danger, TsuyaState.focusWidth),
          (null, true) => (accent, TsuyaState.focusWidth),
          (null, false) => (colors.borderStrong, 1.0),
        };
        return TextFieldBox(
          controller: _controller,
          radius: radius,
          borderColor: color,
          borderWidth: width,
          glass: widget.glass,
          minHeight: multiline ? 2 * TsuyaSize.controlMd : widget.size.height,
          multiline: multiline,
          placeholder: widget.placeholder,
          style: style,
          leading: leadingIcon,
          trailingItems: trailingItems,
          editable: _gestures.buildGestureDetector(behavior: HitTestBehavior.translucent, child: editable),
        );
      },
    );

    Widget result = MouseRegion(cursor: widget.enabled ? SystemMouseCursors.text : MouseCursor.defer, child: field);
    result = widget._search
        ? MergeSemantics(
            child: Semantics(label: widget.label, enabled: widget.enabled, child: result),
          )
        : Field(
            label: widget.label,
            hint: widget.hint,
            error: widget.error,
            optional: widget.optional,
            required: widget.required,
            child: result,
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

/// A quiet, icon-sized button inside a [TextFieldBox] (DESIGN.md, TextField): the clear and the show/hide password
/// buttons. Not [TsuyaSize.target] drawn, but [Pressable] still answers on it.
Widget _actionButton(
  BuildContext context, {
  required TsuyaGlyph glyph,
  required String label,
  required VoidCallback onPressed,
}) => Pressable(
  onPressed: onPressed,
  label: label,
  quiet: true,
  borderRadius: BorderRadius.circular(TsuyaSize.icon),
  child: Glyph(glyph, color: TsuyaTheme.of(context).colors.textMuted),
);

/// The default `contextMenuBuilder` of every tsuya text field (DESIGN.md, TextField): Cut, Copy, Paste and Select
/// all, each shown only when [state] says it applies, positioned like the platform toolbar (above the selection,
/// or below it when there is no room) and drawn as a [menuPanel].
Widget _textFieldContextMenu(BuildContext context, EditableTextState state) {
  final labels = TsuyaLabels.of(context);
  final actions = <({String label, VoidCallback onSelected})>[
    if (state.cutEnabled) (label: labels.cut, onSelected: () => state.cutSelection(SelectionChangedCause.toolbar)),
    if (state.copyEnabled) (label: labels.copy, onSelected: () => state.copySelection(SelectionChangedCause.toolbar)),
    if (state.pasteEnabled) (label: labels.paste, onSelected: () => state.pasteText(SelectionChangedCause.toolbar)),
    if (state.selectAllEnabled)
      (label: labels.selectAll, onSelected: () => state.selectAll(SelectionChangedCause.toolbar)),
  ];
  if (actions.isEmpty) return const SizedBox.shrink();
  final anchors = state.contextMenuAnchors;
  return CustomSingleChildLayout(
    delegate: _ContextMenuLayout(anchors.primaryAnchor, anchors.secondaryAnchor ?? anchors.primaryAnchor),
    child: Semantics(
      role: SemanticsRole.menu,
      explicitChildNodes: true,
      child: IntrinsicWidth(
        child: menuPanel(
          context,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, action) in actions.indexed)
                _MenuRow(
                  label: action.label,
                  autofocus: i == 0,
                  onSelected: () {
                    action.onSelected();
                    state.hideToolbar();
                  },
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.label, required this.autofocus, required this.onSelected});

  final String label;
  final bool autofocus;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    return Pressable(
      onPressed: onSelected,
      autofocus: autofocus,
      role: SemanticsRole.menuItem,
      feedback: PressFeedback.highlight,
      borderRadius: const BorderRadius.all(Radius.circular(TsuyaRadius.sm)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: TsuyaSize.controlMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: TsuyaSpace.s12),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(label, style: theme.text(TsuyaType.body).copyWith(color: theme.colors.text)),
          ),
        ),
      ),
    );
  }
}

// Centred on the anchor, above `top` by default (a gap above it), flipped to below `bottom` when there is no room,
// clamped inside the screen margins: the same placement system toolbars use.
class _ContextMenuLayout extends SingleChildLayoutDelegate {
  _ContextMenuLayout(this.top, this.bottom);

  final Offset top;
  final Offset bottom;

  static const _margin = TsuyaSpace.s16;
  static const _gap = TsuyaSpace.s8;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints.loose(constraints.biggest - const Offset(2 * _margin, 2 * _margin) as Size);

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final fitsAbove = top.dy - _gap - childSize.height >= _margin;
    final y = fitsAbove ? top.dy - _gap - childSize.height : bottom.dy + _gap;
    final x = top.dx - childSize.width / 2;
    return Offset(
      x.clamp(_margin, math.max(_margin, size.width - _margin - childSize.width)),
      y.clamp(_margin, math.max(_margin, size.height - _margin - childSize.height)),
    );
  }

  @override
  bool shouldRelayout(_ContextMenuLayout old) => old.top != top || old.bottom != bottom;
}
