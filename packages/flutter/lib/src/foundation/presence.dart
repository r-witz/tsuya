// Mount, animate in, animate out, then unmount (DESIGN.md, Foundations: Motion). Used by every
// overlay and the accordion.
import 'package:flutter/widgets.dart';

import 'motion.dart';
import 'tokens.g.dart';

/// Keeps [builder] mounted while it animates out: when [visible] turns false, [builder] is called once more with
/// an animation running back to 0, and only unmounts once that finishes. Instant under reduced motion.
class Presence extends StatefulWidget {
  /// Shows (or animates out, then hides) [builder] as [visible] changes.
  const Presence({
    super.key,
    required this.visible,
    required this.builder,
    this.duration = TsuyaDuration.base,
    this.curve = TsuyaEasing.standard,
  });

  /// Whether the content should be shown.
  final bool visible;

  /// Builds the content from an animation running 0 (unmounted) to 1 (fully shown).
  final Widget Function(BuildContext context, Animation<double> animation) builder;

  /// How long entering and leaving take.
  final Duration duration;

  /// The easing of the animation.
  final Curve curve;

  @override
  State<Presence> createState() => _PresenceState();
}

class _PresenceState extends State<Presence> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: widget.duration)..addStatusListener(_onStatus);
  late bool _mounted = widget.visible;
  bool _startedInitial = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // the duration must be corrected for reduced motion before the first forward(), or a `Presence` that mounts
    // already visible animates at full speed instead of jumping straight to shown (initState runs too early: it
    // has no BuildContext to read MediaQuery with).
    _controller.duration = motionOf(context, widget.duration);
    if (!_startedInitial) {
      _startedInitial = true;
      if (widget.visible) _controller.forward();
    }
  }

  @override
  void didUpdateWidget(Presence oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = motionOf(context, widget.duration);
    if (widget.visible && !oldWidget.visible) {
      if (!_mounted) setState(() => _mounted = true);
      _controller.forward();
    } else if (!widget.visible && oldWidget.visible) {
      _controller.reverse();
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && !widget.visible && _mounted) setState(() => _mounted = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _mounted ? widget.builder(context, _controller.drive(CurveTween(curve: widget.curve))) : const SizedBox.shrink();
}
