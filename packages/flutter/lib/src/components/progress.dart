// A progress bar (DESIGN.md, Progress).
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import '../foundation/labels.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import '../material/accent.dart';

// DESIGN.md, Progress: the thin variant, for along an edge.
const _thinHeight = 2.0;
// DESIGN.md, Progress: without a value, this fraction of the bar sweeps across the track.
const _sweepWidth = 1 / 3;
// DESIGN.md, Progress: the sweep crosses the track every 1.2 s.
const _sweepDuration = Duration(milliseconds: 1200);

/// A progress bar (DESIGN.md, Progress): [TsuyaSpace.s4] tall ([thin]: 2), [TsuyaRadius.full], [TsuyaColors.track]
/// filled with the accent, proportional to [value] (0 to 1). Without [value], a third of the bar sweeps across the
/// track every 1.2 s, in the reading direction, kept moving under reduced motion: it is the information. Always
/// named, with [label] (the `loading` label by default), through the progress bar role.
class Progress extends StatefulWidget {
  /// A progress bar, [value] from 0 to 1; indeterminate without one.
  const Progress({super.key, this.value, this.label, this.thin = false});

  /// 0 to 1 (clamped to it); indeterminate without one, or when NaN.
  final double? value;

  /// Names the bar; the `loading` label by default.
  final String? label;

  /// 2 tall, for along an edge.
  final bool thin;

  @override
  State<Progress> createState() => _ProgressState();
}

class _ProgressState extends State<Progress> with SingleTickerProviderStateMixin {
  late final AnimationController _sweep;

  // The value as drawn: clamped to 0 to 1 like a native progress element, and null (indeterminate) when absent or
  // NaN.
  double? get _value {
    final value = widget.value;
    return value == null || value.isNaN ? null : value.clamp(0.0, 1.0);
  }

  @override
  void initState() {
    super.initState();
    // built eagerly, not lazily on first use by build(): a bar that stays determinate for its whole life would
    // otherwise never construct this, until dispose() reaches for it and builds a Ticker on a deactivated element
    _sweep = AnimationController(vsync: this, duration: _sweepDuration);
    _syncSweep();
  }

  @override
  void didUpdateWidget(Progress oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncSweep();
  }

  // the sweep runs only while indeterminate: a determinate bar keeps no ticker
  void _syncSweep() {
    if (_value == null) {
      if (!_sweep.isAnimating) _sweep.repeat();
    } else {
      _sweep.stop();
    }
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = TsuyaTheme.of(context).colors;
    final accent = Accent.of(context);
    final value = _value;
    final rtl = Directionality.of(context) == TextDirection.rtl;

    final Widget fill = value == null
        ? AnimatedBuilder(
            animation: _sweep,
            builder: (context, child) {
              final t = rtl ? 1 - _sweep.value : _sweep.value;
              // the third travels from just past the start to just past the end (DESIGN.md, Progress); Align's
              // alignment can go past ±1, pushing it fully off either edge, which the ClipRRect below then hides
              return Align(alignment: Alignment(4 * t - 2, 0), child: child);
            },
            child: FractionallySizedBox(
              widthFactor: _sweepWidth,
              heightFactor: 1,
              child: ColoredBox(color: accent),
            ),
          )
        : FractionallySizedBox(
            widthFactor: value,
            heightFactor: 1,
            alignment: AlignmentDirectional.centerStart,
            child: ColoredBox(color: accent),
          );

    return Semantics(
      // indeterminate carries no value: Flutter's own progressBar role requires one (a FlutterError otherwise), so
      // it is announced as a loadingSpinner instead, exactly like Spinner.
      role: value == null ? SemanticsRole.loadingSpinner : SemanticsRole.progressBar,
      label: widget.label ?? TsuyaLabels.of(context).loading,
      value: value == null ? null : '${(value * 100).round()} %',
      minValue: value == null ? null : '0',
      maxValue: value == null ? null : '100',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(TsuyaRadius.full),
        child: SizedBox(
          width: double.infinity,
          height: widget.thin ? _thinHeight : TsuyaSpace.s4,
          child: DecoratedBox(
            decoration: BoxDecoration(color: colors.track),
            child: fill,
          ),
        ),
      ),
    );
  }
}
