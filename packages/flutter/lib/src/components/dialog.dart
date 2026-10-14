// A decision that needs an answer, or a short focused task (DESIGN.md, Dialog).
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import '../foundation/modal_scrim.dart';
import '../foundation/overlay_show.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';

/// The width of a [Dialog].
enum DialogSize {
  /// At most 420 wide. The default.
  md(420),

  /// At most 560 wide.
  lg(560);

  const DialogSize(this.maxWidth);

  /// The widest the box grows.
  final double maxWidth;
}

/// A decision that needs an answer, or a short focused task (DESIGN.md, Dialog): a box at most 420 wide ([size]
/// lg: 560) of [title], [body] in [TsuyaColors.textMuted], optional [content], and [actions] at the end, wrapping
/// when needed — put the main one last. Show it with [Dialog.show]; it is modal, traps focus, and puts it first on
/// the least destructive action: the first of [actions] (so, usually, Cancel), or [initialFocus]. [alert] gives it
/// the alert dialog role, for one that interrupts.
class Dialog extends StatefulWidget {
  /// A dialog titled [title].
  const Dialog({
    super.key,
    required this.title,
    this.body,
    this.content,
    this.actions = const [],
    this.size = DialogSize.md,
    this.alert = false,
    this.initialFocus,
  });

  /// What is being asked, in [TsuyaType.titleM]; also its accessible name.
  final String title;

  /// A sentence of explanation under the title, announced with it.
  final String? body;

  /// Anything else under the body: a field, a list.
  final Widget? content;

  /// Buttons at the end, the main one last.
  final List<Widget> actions;

  /// How wide it grows at most.
  final DialogSize size;

  /// Announces it as an alert dialog: it interrupts what the person was doing.
  final bool alert;

  /// The node to focus first, instead of the first action.
  final FocusNode? initialFocus;

  /// Shows [builder]'s dialog above everything, over a scrim, and completes with what [close] gives, or null once
  /// dismissed. Escape and a press on the scrim dismiss it unless [dismissible] is false (a required decision:
  /// only an action's [close] ends it). [barrierLabel] names the scrim for a screen reader, which can then dismiss
  /// it; it is left out when not [dismissible].
  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool dismissible = true,
    String? barrierLabel,
  }) => showTsuyaOverlay<T>(
    context: context,
    dismissible: dismissible,
    builder: (context, animation, wrap, close) => _DialogHost(
      animation: animation,
      wrap: wrap,
      barrierLabel: dismissible ? barrierLabel : null,
      onDismiss: close,
      child: Builder(builder: builder),
    ),
  );

  /// Closes the dialog [context] belongs to, completing [Dialog.show]'s future with [result].
  static void close<T>(BuildContext context, [T? result]) => closeTsuyaOverlay(context, result);

  @override
  State<Dialog> createState() => _DialogState();
}

class _DialogState extends State<Dialog> {
  final _actions = FocusNode(debugLabel: 'Dialog actions', canRequestFocus: false, skipTraversal: true);

  @override
  void initState() {
    super.initState();
    // after the focus trap has moved focus in (it does so first, from its own post-frame callback)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final first = widget.initialFocus ?? _actions.traversalDescendants.firstOrNull;
      first?.requestFocus();
    });
  }

  @override
  void dispose() {
    _actions.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    final colors = theme.colors;
    const radius = BorderRadius.all(Radius.circular(TsuyaRadius.lg));
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: widget.size.maxWidth),
      child: Semantics(
        role: widget.alert ? SemanticsRole.alertDialog : SemanticsRole.dialog,
        scopesRoute: true,
        namesRoute: true,
        explicitChildNodes: true,
        label: widget.title,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: radius,
            border: Border.all(color: colors.border, strokeAlign: BorderSide.strokeAlignOutside),
            boxShadow: theme.shadows.lg,
          ),
          child: Padding(
            padding: const EdgeInsets.all(TsuyaSpace.s24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(widget.title, style: theme.text(TsuyaType.titleM).copyWith(color: colors.text)),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.body != null) ...[
                          const SizedBox(height: TsuyaSpace.s16),
                          Text(widget.body!, style: theme.text(TsuyaType.body).copyWith(color: colors.textMuted)),
                        ],
                        if (widget.content != null) ...[const SizedBox(height: TsuyaSpace.s16), widget.content!],
                      ],
                    ),
                  ),
                ),
                if (widget.actions.isNotEmpty) ...[
                  const SizedBox(height: TsuyaSpace.s16),
                  Focus(
                    focusNode: _actions,
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      spacing: TsuyaSpace.s8,
                      runSpacing: TsuyaSpace.s8,
                      children: widget.actions,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// The scrim, the entrance (a fade that grows from 0.98 over the shared controller), the room left by the keyboard
// and the margin to the screen edges around a dialog.
class _DialogHost extends StatelessWidget {
  const _DialogHost({
    required this.animation,
    required this.wrap,
    required this.barrierLabel,
    required this.onDismiss,
    required this.child,
  });

  final Animation<double> animation;
  final Widget Function(Widget child) wrap;
  final String? barrierLabel;
  final VoidCallback onDismiss;
  final Widget child;

  // a dialog grows from 0.98
  static const _from = 0.98;

  @override
  Widget build(BuildContext context) {
    final curved = animation.drive(CurveTween(curve: TsuyaEasing.standard));
    return Stack(
      children: [
        ModalScrim(opacity: curved, barrierLabel: barrierLabel, onDismiss: onDismiss),
        Padding(
          padding: EdgeInsets.fromLTRB(
            TsuyaSpace.s16,
            TsuyaSpace.s16,
            TsuyaSpace.s16,
            TsuyaSpace.s16 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Center(
            child: wrap(
              FadeTransition(
                opacity: curved,
                child: ScaleTransition(
                  scale: curved.drive(Tween<double>(begin: _from, end: 1)),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
