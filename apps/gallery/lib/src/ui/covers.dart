// The sample covers (assets/covers, drawn by tool/covers.mjs) and the people and albums the examples talk about.
import 'package:flutter/widgets.dart';
import 'package:tsuya/tsuya.dart';

/// One sample cover with the colour its accent is computed from. The app stores that seed with the content, so the
/// accent is known before the picture has loaded (DESIGN.md, Accent).
class Cover {
  /// A cover named [name] whose accent comes from [seed].
  const Cover(this.name, this.seed, {required this.title, required this.artist});

  /// The file name without extension.
  final String name;

  /// '#RRGGBB'.
  final String seed;

  /// The album.
  final String title;

  /// Who made it.
  final String artist;

  /// The picture.
  ImageProvider get image => AssetImage('assets/covers/$name.png');

  /// The accent of both modes, and the ambient opacities.
  AccentPair get accent => accentFromColor(seed);
}

/// The six covers.
const covers = [
  Cover('dusk', '#E0724A', title: 'Slow Light', artist: 'Mira Vale'),
  Cover('tide', '#26A69A', title: 'Low Tide', artist: 'The Harbour Club'),
  Cover('ember', '#E4553A', title: 'Ember Hours', artist: 'Noa Reyes'),
  Cover('moss', '#86B04A', title: 'Field Notes', artist: 'Juniper Lane'),
  Cover('sand', '#D9B779', title: 'Dune Radio', artist: 'Sol Arkin'),
  Cover('slate', '#C9769F', title: 'Violet Hour', artist: 'Kei Tanaka'),
];
