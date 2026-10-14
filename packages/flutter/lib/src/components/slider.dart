// A continuous value between two ends (DESIGN.md, Slider).
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../foundation/focus_ring.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import '../material/accent.dart';

/// A continuous value between [min] and [max] (DESIGN.md, Slider): [TsuyaSize.target] tall; a [TsuyaSpace.s4]
/// track in [TsuyaColors.track], filled with the accent from the start (from the end under right-to-left); a 20
/// thumb in [TsuyaColors.thumb] with [TsuyaShadows.sm] and a hairline ring, the focus ring around it. Arrow keys
/// move by [step] (a twentieth of the range by default), Page Up/Down by a tenth (at least one step), Home/End to the
/// ends. The value is announced as a percentage unless [valueLabel] formats it.
class Slider extends StatefulWidget {
  /// A slider at [value], named [label].
  const Slider({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
    required this.label,
    this.min = 0.0,
    this.max = 1.0,
    this.step,
    this.valueLabel,
    this.focusNode,
    this.autofocus = false,
  });

  /// The current value, between [min] and [max].
  final double value;

  /// Called with the next value as it is dragged or pressed; null disables it.
  final ValueChanged<double>? onChanged;

  /// Called once with the final value when a drag or a key press ends.
  final ValueChanged<double>? onChangeEnd;

  /// The accessible name.
  final String label;

  /// The lower end.
  final double min;

  /// The upper end.
  final double max;

  /// The amount arrow keys move by, and dragging snaps to; a twentieth of the range when null.
  final double? step;

  /// Formats the announced value; a percentage of the range by default.
  final String Function(double value)? valueLabel;

  /// The node to track focus with, when the caller manages one.
  final FocusNode? focusNode;

  /// Focuses it as soon as it is built.
  final bool autofocus;

  @override
  State<Slider> createState() => _SliderState();
}

class _SliderState extends State<Slider> {
  static const _thumbSize = 20.0;

  bool _focused = false;
  double _width = 0;
  double? _dragValue;
  bool _pressing = false;

  bool get _enabled => widget.onChanged != null;
  double get _range => widget.max - widget.min;
  double get _keyStep => widget.step ?? (_range == 0 ? 0 : _range / 20);
  double get _pageStep => _range == 0 ? 0 : math.max(_range / 10, _keyStep);

  double _clamp(double value) => value.clamp(widget.min, widget.max);

  double _snap(double value) {
    final step = widget.step;
    if (step == null || step <= 0) return _clamp(value);
    return _clamp(widget.min + ((value - widget.min) / step).round() * step);
  }

  void _change(double value, {bool press = false}) {
    final next = _snap(value);
    _dragValue = next;
    if (next == widget.value) return;
    if (press) _pressing = true;
    widget.onChanged!(next);
  }

  void _changeFromOffset(double dx) {
    final usable = _width - _thumbSize;
    if (usable <= 0) return;
    var fraction = ((dx - _thumbSize / 2) / usable).clamp(0.0, 1.0);
    if (Directionality.of(context) == TextDirection.rtl) fraction = 1 - fraction;
    _change(widget.min + fraction * _range, press: true);
  }

  // A press that commits a value ends once: by its release, or by the arena rejecting it (a tap inside a scrollable,
  // or the scrollable taking the drag over), which cancels instead of ending.
  void _endPress() {
    if (!_pressing) return;
    _pressing = false;
    widget.onChangeEnd?.call(_dragValue ?? widget.value);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final increaseKey = rtl ? LogicalKeyboardKey.arrowLeft : LogicalKeyboardKey.arrowRight;
    final decreaseKey = rtl ? LogicalKeyboardKey.arrowRight : LogicalKeyboardKey.arrowLeft;
    final key = event.logicalKey;
    final double next;
    if (key == increaseKey || key == LogicalKeyboardKey.arrowUp) {
      next = widget.value + _keyStep;
    } else if (key == decreaseKey || key == LogicalKeyboardKey.arrowDown) {
      next = widget.value - _keyStep;
    } else if (key == LogicalKeyboardKey.pageUp) {
      next = widget.value + _pageStep;
    } else if (key == LogicalKeyboardKey.pageDown) {
      next = widget.value - _pageStep;
    } else if (key == LogicalKeyboardKey.home) {
      next = widget.min;
    } else if (key == LogicalKeyboardKey.end) {
      next = widget.max;
    } else {
      return KeyEventResult.ignored;
    }
    _change(next);
    widget.onChangeEnd?.call(_snap(next));
    return KeyEventResult.handled;
  }

  String _format(double value) {
    final formatter = widget.valueLabel;
    if (formatter != null) return formatter(value);
    final percent = _range == 0 ? 0 : (((value - widget.min) / _range) * 100).round();
    return '$percent %';
  }

  @override
  Widget build(BuildContext context) {
    final colors = TsuyaTheme.of(context).colors;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final fraction = _range == 0 ? 0.0 : ((widget.value - widget.min) / _range).clamp(0.0, 1.0);

    Widget result = LayoutBuilder(
      builder: (context, constraints) {
        _width = constraints.maxWidth;
        final usable = (_width - _thumbSize).clamp(0.0, double.infinity);
        final thumbLeft = (rtl ? 1 - fraction : fraction) * usable;
        return SizedBox(
          height: TsuyaSize.target,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Positioned(left: _thumbSize / 2, right: _thumbSize / 2, child: _bar(colors.track)),
              Positioned(
                left: rtl ? null : _thumbSize / 2,
                right: rtl ? _thumbSize / 2 : null,
                width: fraction * usable,
                child: _bar(Accent.of(context)),
              ),
              Positioned(
                left: thumbLeft,
                child: FocusRing(
                  focused: _focused,
                  borderRadius: BorderRadius.circular(_thumbSize / 2),
                  child: Container(
                    width: _thumbSize,
                    height: _thumbSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.thumb,
                      boxShadow: TsuyaShadows.of(context).sm,
                      border: Border.all(color: colors.borderStrong),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    result = GestureDetector(
      onPanDown: _enabled ? (details) => _changeFromOffset(details.localPosition.dx) : null,
      onPanUpdate: _enabled ? (details) => _changeFromOffset(details.localPosition.dx) : null,
      onPanEnd: _enabled ? (_) => _endPress() : null,
      onPanCancel: _enabled ? _endPress : null,
      child: result,
    );
    if (!_enabled) result = Opacity(opacity: TsuyaState.disabledOpacity, child: result);

    return Semantics(
      slider: true,
      enabled: _enabled,
      label: widget.label,
      value: _format(widget.value),
      increasedValue: _enabled ? _format(_clamp(widget.value + _keyStep)) : null,
      decreasedValue: _enabled ? _format(_clamp(widget.value - _keyStep)) : null,
      onIncrease: _enabled ? () => _change(widget.value + _keyStep) : null,
      onDecrease: _enabled ? () => _change(widget.value - _keyStep) : null,
      child: Focus(
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        canRequestFocus: _enabled,
        onKeyEvent: _onKey,
        onFocusChange: (focused) => setState(() => _focused = focused),
        child: result,
      ),
    );
  }

  Widget _bar(Color color) => Container(
    height: TsuyaSpace.s4,
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(TsuyaSpace.s4 / 2)),
  );
}
