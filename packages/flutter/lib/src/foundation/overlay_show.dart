// Showing a floating overlay above everything, from an arbitrary context (DESIGN.md, Overlays and feedback).
// It builds on the top layer / portal, the dismissable layer and the focus scope. Shared by Menu, Popover,
// Dialog, Sheet and CommandPalette: each only draws its own panel and positions it; this handles the barrier, the
// fade, carrying the opener's scopes, Escape and outside-press dismissal, and (when modal) trapping and restoring
// focus.
import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'dismissable_layer.dart';
import 'focus_trap.dart';
import 'motion.dart';
import 'opener_focus.dart';
import 'portal.dart';
import 'tokens.g.dart';

/// Shows an overlay above everything in the root [Overlay] reached from [context], wrapped in the theme, accent, glass
/// and labels scopes open at [context]. [builder] draws the full screen (a barrier plus its panel, positioned however
/// it likes) from the entrance/exit [Animation] and [wrap], which it must apply around its panel's content: [wrap] adds
/// Escape and outside-press dismissal ([DismissableLayer]), and — while [modal] — a [FocusTrap] (initial focus on
/// [initialFocus], Tab cycling inside, the opener refocused once this is fully gone). A non-modal overlay (a menu, a
/// popover) is not trapped: it dismisses instead when focus leaves it, and its caller restores focus itself; a modal
/// one also blocks the semantics under it. Without [dismissible], Escape and presses outside are swallowed rather than
/// closing it. [close] resolves the returned future with its argument; every dismissal reason (Escape, outside, focus
/// leaving) calls it with null. Instant under reduced motion. [onRemoved] is called once it is fully gone, its focus
/// trap included, so focus is back where it was: what runs a command there can move it.
Future<T?> showTsuyaOverlay<T>({
  required BuildContext context,
  required Widget Function(
    BuildContext context,
    Animation<double> animation,
    Widget Function(Widget child) wrap,
    void Function([T? result]) close,
  )
  builder,
  bool modal = true,
  bool dismissible = true,
  FocusNode? initialFocus,
  RenderBox? anchorBox,
  Duration transitionDuration = TsuyaDuration.base,
  VoidCallback? onRemoved,
}) {
  final overlayState = Overlay.of(context, rootOverlay: true);
  final completer = Completer<T?>();
  final opener = OpenerFocus.of(context);
  // read once, now: the entry's builder reruns whenever the overlay rebuilds, long after the opener may be gone
  final scopes = TsuyaPortal.capture(from: context);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (overlayContext) => scopes.wrap(
      _TsuyaOverlayScope<T>(
        modal: modal,
        dismissible: dismissible,
        initialFocus: initialFocus,
        opener: opener,
        anchorBox: anchorBox,
        duration: transitionDuration,
        onClosed: () {
          entry.remove();
          // after the frame that takes it out of the tree, where its focus trap has given the focus back
          if (onRemoved != null) WidgetsBinding.instance.addPostFrameCallback((_) => onRemoved());
        },
        complete: (value) {
          if (!completer.isCompleted) completer.complete(value);
        },
        builder: builder,
      ),
    ),
  );
  overlayState.insert(entry);
  _reorderKeptOnTop(overlayState);
  return completer.future;
}

// Entries that stay above whatever is shown after them (a toast above a dialog that opens while it is showing).
final _keptOnTop = <OverlayEntry, OverlayState>{};

/// Keeps [entry], shown in [overlay], above every overlay [showTsuyaOverlay] shows from now on, until
/// [releaseOnTop] is called.
void keepOnTop(OverlayState overlay, OverlayEntry entry) => _keptOnTop[entry] = overlay;

/// Stops [keepOnTop] for [entry].
void releaseOnTop(OverlayEntry entry) => _keptOnTop.remove(entry);

void _reorderKeptOnTop(OverlayState overlay) {
  final kept = [
    for (final MapEntry(key: entry, value: owner) in _keptOnTop.entries)
      if (owner == overlay && entry.mounted) entry,
  ];
  // rearrange puts the listed entries first and the others at its insertion point: below the first of them, they end up
  // under it
  if (kept.isNotEmpty) overlay.rearrange(kept, below: kept.first);
}

class _TsuyaOverlayScope<T> extends StatefulWidget {
  const _TsuyaOverlayScope({
    required this.modal,
    required this.dismissible,
    required this.initialFocus,
    required this.opener,
    required this.anchorBox,
    required this.duration,
    required this.onClosed,
    required this.complete,
    required this.builder,
  });

  final bool modal;
  final bool dismissible;
  final FocusNode? initialFocus;
  final FocusNode? opener;
  final RenderBox? anchorBox;
  final Duration duration;
  final VoidCallback onClosed;
  final void Function(T? value) complete;
  final Widget Function(
    BuildContext context,
    Animation<double> animation,
    Widget Function(Widget child) wrap,
    void Function([T? result]) close,
  )
  builder;

  @override
  State<_TsuyaOverlayScope<T>> createState() => _TsuyaOverlayScopeState<T>();
}

class _TsuyaOverlayScopeState<T> extends State<_TsuyaOverlayScope<T>> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: widget.duration)..addStatusListener(_onStatus);
  bool _started = false;
  bool _closing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration = motionOf(context, widget.duration);
    if (!_started) {
      _started = true;
      _controller.forward();
      _watchAnchor();
    }
  }

  // An anchored overlay ends with its anchor: checked after each frame (a callback asks for no frame of its own).
  void _watchAnchor() {
    final anchor = widget.anchorBox;
    if (anchor == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _closing) return;
      anchor.attached ? _watchAnchor() : _close();
    });
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && _closing) widget.onClosed();
  }

  void _close([T? result]) {
    if (_closing) return;
    _closing = true;
    // rebuilt, so the dismissable layer leaves its stack while it fades out; a frame later when the close comes from
    // a build (an anchor that goes away), where no other widget may be marked dirty
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    } else if (mounted) {
      setState(() {});
    }
    widget.complete(result);
    _controller.reverse();
  }

  Widget _wrap(Widget child) {
    // a required decision (not dismissible) still captures Escape and presses outside, so they do not reach
    // what is under it; only an explicit close ends it
    final layer = DismissableLayer(
      modal: widget.modal,
      closing: _closing,
      opener: widget.opener,
      onDismiss: widget.dismissible ? _close : () {},
      child: child,
    );
    return widget.modal
        ? FocusTrap(initialFocus: widget.initialFocus, opener: widget.opener, closing: _closing, child: layer)
        : layer;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.builder(context, _controller.view, _wrap, _close);
    // a modal overlay hides what is under it from a screen reader, as a route's barrier does
    return _CloseScope(
      close: ([result]) => _close(result as T?),
      child: widget.modal ? BlockSemantics(child: content) : content,
    );
  }
}

class _CloseScope extends InheritedWidget {
  const _CloseScope({required this.close, required super.child});

  final void Function([Object? result]) close;

  @override
  bool updateShouldNotify(_CloseScope oldWidget) => false;
}

/// Closes the overlay [context] belongs to (the nearest one opened by [showTsuyaOverlay]), completing its future
/// with [result]. For the content of a dialog or a sheet, whose actions end it.
void closeTsuyaOverlay(BuildContext context, [Object? result]) {
  final scope = context.getInheritedWidgetOfExactType<_CloseScope>();
  assert(scope != null, 'closeTsuyaOverlay() was called with a context that is not inside an overlay.');
  scope?.close(result);
}

/// What closes the overlay [context] belongs to, to call later (when [context] can no longer be used to look it up,
/// from a `dispose`, say): the same as [closeTsuyaOverlay] with no result.
VoidCallback tsuyaOverlayCloser(BuildContext context) {
  final scope = context.getInheritedWidgetOfExactType<_CloseScope>();
  assert(scope != null, 'tsuyaOverlayCloser() was called with a context that is not inside an overlay.');
  return scope?.close ?? () {};
}
