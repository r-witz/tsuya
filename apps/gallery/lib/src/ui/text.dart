// Text in a token style, for the blocks: the theme resolves the typeface, the colour is the text's or the muted one.
import 'package:flutter/widgets.dart';
import 'package:tsuya/tsuya.dart';

/// [text] in [style] from [TsuyaType], [muted] in `text-muted`. One line with an ellipsis when [maxLines] is 1.
Widget styled(
  BuildContext context,
  TextStyle style,
  String text, {
  bool muted = false,
  TextAlign? align,
  int? maxLines,
}) {
  final theme = TsuyaTheme.of(context);
  return Text(
    text,
    textAlign: align,
    maxLines: maxLines,
    overflow: maxLines == null ? null : TextOverflow.ellipsis,
    style: theme.text(style).copyWith(color: muted ? theme.colors.textMuted : theme.colors.text),
  );
}

/// A figure that keeps its width from one value to the next (DESIGN.md, Type: tabular).
TextStyle tabular(TextStyle style) => style.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
