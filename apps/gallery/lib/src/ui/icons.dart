// The icons the gallery's examples use. tsuya draws only a dozen glyphs itself (DESIGN.md, Icons): every other icon is
// a widget the app supplies, so the gallery supplies its own, stroked as the glyphs are (24 box, 1.8, round joins).
import 'package:flutter/widgets.dart';

/// Every icon the examples use.
enum GIcon {
  /// A house.
  home('M4 11 L12 4 L20 11 V20 H4 Z M10 20 V14 H14 V20'),

  /// Shelves of records.
  library('R4 4 4 16 1 R10 4 4 16 1 M17 5 L21 19'),

  /// Two sliders.
  settings('M4 7 H20 M4 17 H20 O9 7 2.2 O15 17 2.2'),

  /// A filled triangle.
  play('M8 5 L19 12 L8 19 Z', filled: true),

  /// Two filled bars.
  pause('R6 5 4 14 1 R14 5 4 14 1', filled: true),

  /// Skip forward.
  next('M6 5 L16 12 L6 19 Z M19 5 V19'),

  /// Skip back.
  previous('M18 5 L8 12 L18 19 Z M5 5 V19'),

  /// A heart.
  heart(
    'M12 20 C5 15 3 11.5 3 8.5 C3 6 5 4.5 7.2 4.5 C9.2 4.5 11 5.7 12 7.5 C13 5.7 14.8 4.5 16.8 4.5 '
    'C19 4.5 21 6 21 8.5 C21 11.5 19 15 12 20 Z',
  ),

  /// A cross.
  plus('M12 5 V19 M5 12 H19'),

  /// An arrow leaving a tray.
  share('M12 15 V4 M8 8 L12 4 L16 8 M6 12 V19 H18 V12'),

  /// A head and shoulders.
  user('O12 8 4 M4 20 C4 15.5 7.5 14 12 14 C16.5 14 20 15.5 20 20'),

  /// A bell.
  bell('M6 17 V11 C6 7.7 8.5 5 12 5 C15.5 5 18 7.7 18 11 V17 L20 18.5 H4 Z M10 21 H14'),

  /// An envelope.
  mail('R3 5 18 14 3 M3.5 7 L12 13 L20.5 7'),

  /// A padlock.
  lock('R5 11 14 9 2 M8 11 V8 C8 5.5 9.8 4 12 4 C14.2 4 16 5.5 16 8 V11'),

  /// An arrow into a tray.
  download('M12 4 V15 M8 11 L12 15 L16 11 M5 19 H19'),

  /// Three dots.
  more('O5 12 1.2 O12 12 1.2 O19 12 1.2', filled: true),

  /// A star.
  star('M12 4 L14.4 9.2 L20 9.9 L15.9 13.8 L17 19.5 L12 16.7 L7 19.5 L8.1 13.8 L4 9.9 L9.6 9.2 Z'),

  /// Three bars of decreasing length.
  filter('M4 6 H20 M7 12 H17 M10 18 H14'),

  /// Four tiles.
  grid('R4 4 6 6 1.5 R14 4 6 6 1.5 R4 14 6 6 1.5 R14 14 6 6 1.5'),

  /// Rows with bullets.
  list('M9 7 H20 M9 12 H20 M9 17 H20 O5 7 .8 O5 12 .8 O5 17 .8'),

  /// A record.
  album('O12 12 8 O12 12 2.2'),

  /// A folder.
  folder(
    'M3 7 C3 6 3.8 5.5 4.5 5.5 H9 L11 8 H19.5 C20.3 8 21 8.7 21 9.5 V18 C21 18.8 20.3 19.5 19.5 19.5 '
    'H4.5 C3.7 19.5 3 18.8 3 18 Z',
  ),

  /// A signal crossed out.
  offline('M3 9 C8 4.5 16 4.5 21 9 M6 12.5 C9 10 15 10 18 12.5 M9.5 16 C11 15 13 15 14.5 16 O12 19 1 M4 4 L20 20'),

  /// A triangle with an exclamation mark.
  warning('M12 4 L21 19.5 H3 Z M12 10 V14 O12 17 .6'),

  /// A bin.
  trash('M5 7 H19 M9 7 V4.5 H15 V7 M7 7 L8 20 H16 L17 7'),

  /// A pencil.
  edit('M5 19 L6 15 L15.5 5.5 L18.5 8.5 L9 18 Z'),

  /// A rounded square.
  box('R4 4 16 16 4'),

  /// A drop.
  drop('M12 4 C12 4 6 10.5 6 14.5 C6 17.8 8.7 20 12 20 C15.3 20 18 17.8 18 14.5 C18 10.5 12 4 12 4 Z'),

  /// A window with a sidebar.
  layout('R3 4 18 16 2 M3 9 H21 M9 9 V20');

  const GIcon(this.path, {this.filled = false});

  /// The shape: `M L H V C Z` as in SVG (absolute), plus `O cx cy r` for a circle and `R x y w h r` for a rounded
  /// rectangle.
  final String path;

  /// Whether the shape is filled as well as stroked.
  final bool filled;
}

/// [icon] at [size] and [color], the ambient [IconTheme]'s by default: it takes the colour and size a component gives
/// its icon slot.
class GIconView extends StatelessWidget {
  /// An icon.
  const GIconView(this.icon, {super.key, this.size, this.color});

  /// Which icon.
  final GIcon icon;

  /// The square dimension, or the ambient icon size.
  final double? size;

  /// The colour, or the ambient icon colour.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final side = size ?? theme.size ?? 24;
    return SizedBox.square(
      dimension: side,
      child: CustomPaint(painter: _IconPainter(icon, color ?? theme.color ?? const Color(0xFF000000))),
    );
  }
}

final _token = RegExp(r'[A-Za-z]|-?\d*\.?\d+');

class _IconPainter extends CustomPainter {
  _IconPainter(this.icon, this.color);

  final GIcon icon;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = color;
    final path = Path();
    final tokens = _token.allMatches(icon.path).map((m) => m[0]!).toList();
    var i = 0;
    double next() => double.parse(tokens[i++]);
    var x = 0.0, y = 0.0;
    while (i < tokens.length) {
      switch (tokens[i++]) {
        case 'M':
          path.moveTo(x = next(), y = next());
        case 'L':
          path.lineTo(x = next(), y = next());
        case 'H':
          path.lineTo(x = next(), y);
        case 'V':
          path.lineTo(x, y = next());
        case 'C':
          path.cubicTo(next(), next(), next(), next(), x = next(), y = next());
        case 'Z':
          path.close();
        case 'O':
          path.addOval(Rect.fromCircle(center: Offset(next(), next()), radius: next()));
        case 'R':
          path.addRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(next(), next(), next(), next()), Radius.circular(next())),
          );
      }
    }
    if (icon.filled) canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(_IconPainter old) => old.icon != icon || old.color != color;
}
