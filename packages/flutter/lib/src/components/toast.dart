// A short message about something that just happened (DESIGN.md, Toast).
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../foundation/dismissable_layer.dart';
import '../foundation/dock_inset.dart';
import '../foundation/labels.dart';
import '../foundation/motion.dart';
import '../foundation/overlay_show.dart';
import '../foundation/portal.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import '../material/accent.dart';
import '../material/glass.dart';
import 'button.dart';
import 'glyphs.dart';
import 'icon_button.dart';

// at least 48 tall (space-48), padding 0 20 0 14.
const _padding = EdgeInsetsDirectional.fromSTEB(14, 0, TsuyaSpace.s20, 0);

// DESIGN.md, Toast: it comes in from 16 below.
const _enterOffset = 16.0;

// How often the dwell timer counts: it counts ticks, not wall time, so being paused (hovered, focused) costs
// exactly what it lasted, and no frame is scheduled for it.
const _dwellTick = Duration(milliseconds: 100);

// A swipe down on touch: past a third of its height or a fling (as the Sheet), 500 px/s.
const _flingVelocity = 500.0;

/// A short message about something that just happened (DESIGN.md, Toast): glass, at least 48 tall, fully round,
/// at the bottom centre above everything — dialogs and sheets included, and above the dock of a [Screen]. One at a
/// time: a new one replaces the current one. Read politely as a status. Without an action it leaves after
/// [TsuyaDuration.toast] (paused while hovered or focused); with one it also has a dismiss button and stays until
/// the action is used, Escape, a swipe down on touch, or another toast replaces it. F6 moves focus to it while one
/// is shown, and gives it back to where it was when it goes.
abstract final class Toast {
  static _ToastHandle? _current;

  /// Shows [message], with [icon] in the accent before it, and, when both [actionLabel] and [onAction] are given,
  /// a small ghost button that runs [onAction] and dismisses it. Completes once it has gone.
  static Future<void> show(
    BuildContext context, {
    required String message,
    Widget? icon,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _current?.remove();
    final overlay = Overlay.of(context, rootOverlay: true);
    final bottom = MediaQuery.paddingOf(context).bottom + DockInset.of(context);
    final scopes = TsuyaPortal.capture(from: context);
    late final _ToastHandle handle;
    final entry = OverlayEntry(
      builder: (_) => scopes.wrap(
        _ToastView(
          handle: handle,
          message: message,
          icon: icon,
          action: actionLabel != null && onAction != null ? (actionLabel, onAction) : null,
          bottom: bottom,
        ),
      ),
    );
    handle = _ToastHandle(overlay, entry);
    _current = handle;
    overlay.insert(entry);
    keepOnTop(overlay, entry);
    return handle.done.future;
  }
}

class _ToastHandle {
  _ToastHandle(this.overlay, this.entry);

  final OverlayState overlay;
  final OverlayEntry entry;
  final done = Completer<void>();
  bool _removed = false;

  void remove() {
    if (_removed) return;
    _removed = true;
    releaseOnTop(entry);
    if (identical(Toast._current, this)) Toast._current = null;
    entry.remove();
    entry.dispose();
    done.complete();
  }
}

class _ToastView extends StatefulWidget {
  const _ToastView({
    required this.handle,
    required this.message,
    required this.icon,
    required this.action,
    required this.bottom,
  });

  final _ToastHandle handle;
  final String message;
  final Widget? icon;
  final (String, VoidCallback)? action;
  final double bottom;

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: TsuyaDuration.base);
  late final _slide = CurvedAnimation(parent: _controller, curve: TsuyaEasing.standard);
  final _focus = FocusNode(debugLabel: 'Toast', skipTraversal: true);
  Timer? _tick;
  Duration _elapsed = Duration.zero;
  bool _hovered = false;
  bool _focused = false;
  bool _leaving = false;
  double _drag = 0;
  FocusNode? _opener;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
    _focus.addListener(_onFocus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration = motionOf(context, TsuyaDuration.base);
    if (_controller.status == AnimationStatus.dismissed && !_leaving) {
      unawaited(_controller.forward());
      _syncDwell();
    }
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    _tick?.cancel();
    final opener = _opener;
    if (_focus.hasFocus && opener != null && (opener.context?.mounted ?? false)) opener.requestFocus();
    _focus.dispose();
    _slide.dispose();
    _controller.dispose();
    super.dispose();
  }

  // F6 reaches the toast (the documented shortcut, DESIGN.md)
  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent || event.logicalKey != LogicalKeyboardKey.f6 || _leaving) return false;
    if (!_focus.hasFocus) _opener = FocusManager.instance.primaryFocus;
    _focus.requestFocus();
    return true;
  }

  void _onFocus() {
    _focused = _focus.hasFocus;
    _syncDwell();
  }

  // counts down while neither hovered nor focused, unless there is an action to wait for
  void _syncDwell() {
    _tick?.cancel();
    if (widget.action != null || _hovered || _focused || _leaving) return;
    _tick = Timer.periodic(_dwellTick, (_) {
      _elapsed += _dwellTick;
      if (_elapsed >= TsuyaDuration.toast) _dismiss();
    });
  }

  void _dismiss() {
    if (_leaving) return;
    _leaving = true;
    // rebuilt, so its dismissable layer leaves the stack while it fades out
    setState(() {});
    _tick?.cancel();
    unawaited(_controller.reverse().whenComplete(widget.handle.remove));
  }

  void _endDrag(DragEndDetails details) {
    final height = context.size?.height ?? 0;
    if (_drag > height / 3 || (details.primaryVelocity ?? 0) > _flingVelocity) {
      _dismiss();
    } else {
      setState(() => _drag = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    final colors = theme.colors;
    final action = widget.action;
    final labels = TsuyaLabels.of(context);
    final pill = Glass(
      borderRadius: BorderRadius.circular(TsuyaRadius.full),
      shadow: GlassShadow.md,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: TsuyaSpace.s48),
        child: Padding(
          padding: _padding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                ExcludeSemantics(
                  child: IconTheme(
                    data: IconThemeData(color: Accent.of(context), size: TsuyaSize.icon),
                    child: widget.icon!,
                  ),
                ),
                const SizedBox(width: TsuyaSpace.s8),
              ],
              Flexible(
                child: Semantics(
                  role: SemanticsRole.status,
                  child: Text(widget.message, style: theme.text(TsuyaType.bodyStrong).copyWith(color: colors.text)),
                ),
              ),
              if (action != null) ...[
                const SizedBox(width: TsuyaSpace.s8),
                Button(
                  label: action.$1,
                  kind: ButtonKind.ghost,
                  size: ButtonSize.sm,
                  onPressed: () {
                    action.$2();
                    _dismiss();
                  },
                ),
                IconButton(
                  icon: const Glyph(TsuyaGlyph.close),
                  label: labels.dismiss,
                  kind: IconButtonKind.plain,
                  size: IconButtonSize.sm,
                  onPressed: _dismiss,
                ),
              ],
            ],
          ),
        ),
      ),
    );
    return Positioned(
      left: TsuyaSpace.s16,
      right: TsuyaSpace.s16,
      // above the dock, or the keyboard when that reaches higher (as a Dialog and a Sheet lift above it)
      bottom: TsuyaSpace.s16 + math.max(widget.bottom, MediaQuery.viewInsetsOf(context).bottom),
      child: Center(
        child: AnimatedBuilder(
          animation: _slide,
          builder: (context, child) => Opacity(
            opacity: _slide.value,
            child: Transform.translate(offset: Offset(0, (1 - _slide.value) * _enterOffset + _drag), child: child),
          ),
          child: DismissableLayer(
            ambient: true,
            closing: _leaving,
            onDismiss: _dismiss,
            child: Focus(
              focusNode: _focus,
              child: MouseRegion(
                onEnter: (_) {
                  _hovered = true;
                  _syncDwell();
                },
                onExit: (_) {
                  _hovered = false;
                  _syncDwell();
                },
                child: GestureDetector(
                  supportedDevices: const {PointerDeviceKind.touch, PointerDeviceKind.stylus},
                  onVerticalDragUpdate: (details) =>
                      setState(() => _drag = (_drag + details.delta.dy).clamp(0, double.infinity)),
                  onVerticalDragEnd: _endDrag,
                  onVerticalDragCancel: () => setState(() => _drag = 0),
                  child: pill,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
