// What every screen of the gallery is made of: a labelled group of variants, and state held next to the control that
// shows it.
import 'package:flutter/widgets.dart';
import 'package:tsuya/tsuya.dart';

import 'covers.dart';

/// A labelled group of variants on a component screen.
class Demo extends StatelessWidget {
  /// A group named [label] showing [child].
  const Demo(this.label, {super.key, required this.child});

  /// What the group shows: "Kinds", "Disabled".
  final String label;

  /// The variants.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: TsuyaSpace.s32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: TsuyaSpace.s12),
            child: Text(label, style: theme.text(TsuyaType.label).copyWith(color: theme.colors.textMuted)),
          ),
          child,
        ],
      ),
    );
  }
}

/// Variants side by side, wrapping rather than overflowing (DESIGN.md, Layout: action rows wrap).
class Variants extends StatelessWidget {
  /// [children] in a wrapping row.
  const Variants(this.children, {super.key, this.spacing = TsuyaSpace.s12});

  /// The variants.
  final List<Widget> children;

  /// The gap between them, both ways.
  final double spacing;

  @override
  Widget build(BuildContext context) =>
      Wrap(spacing: spacing, runSpacing: spacing, crossAxisAlignment: WrapCrossAlignment.center, children: children);
}

/// A column of [children] [gap] apart.
class Stacked extends StatelessWidget {
  /// A column that stretches its [children].
  const Stacked(this.children, {super.key, this.gap = TsuyaSpace.s16});

  /// The children.
  final List<Widget> children;

  /// The space between them.
  final double gap;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (var i = 0; i < children.length; i++) ...[if (i > 0) SizedBox(height: gap), children[i]],
    ],
  );
}

/// State held next to the control it drives, so a screen's variants stay one expression each.
class Hold<T> extends StatefulWidget {
  /// A [builder] given the value and a way to change it, starting from [initial].
  const Hold({super.key, required this.initial, required this.builder});

  /// The first value.
  final T initial;

  /// Builds from the current value.
  final Widget Function(BuildContext context, T value, ValueChanged<T> set) builder;

  @override
  State<Hold<T>> createState() => _HoldState<T>();
}

class _HoldState<T> extends State<Hold<T>> {
  late T _value = widget.initial;

  @override
  Widget build(BuildContext context) => widget.builder(context, _value, (value) => setState(() => _value = value));
}

/// [child] over a cover: where the glass variants belong (DESIGN.md, Glass: never on a flat background).
class OverArtwork extends StatelessWidget {
  /// [child], centred over [cover].
  const OverArtwork({super.key, this.cover = 0, this.height = 120, required this.child});

  /// An index into [covers].
  final int cover;

  /// How tall the picture is.
  final double height;

  /// What floats above it.
  final Widget child;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(TsuyaRadius.md),
    child: SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image(image: covers[cover % covers.length].image, fit: BoxFit.cover, alignment: Alignment.topCenter),
          Center(child: child),
        ],
      ),
    ),
  );
}

/// A text controller that lives as long as the field it feeds.
class TextHold extends StatefulWidget {
  /// A [builder] given a controller that starts with [text].
  const TextHold({super.key, this.text = '', required this.builder});

  /// What the field starts with.
  final String text;

  /// Builds the field.
  final Widget Function(BuildContext context, TextEditingController controller) builder;

  @override
  State<TextHold> createState() => _TextHoldState();
}

class _TextHoldState extends State<TextHold> {
  late final _controller = TextEditingController(text: widget.text);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _controller);
}
