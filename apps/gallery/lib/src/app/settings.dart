// The switches of the gallery, global to the app: mode, accent, text scale, direction, transparency.
import 'package:flutter/widgets.dart';
import 'package:tsuya/tsuya.dart';

/// A seed the accent switch offers; null is the neutral accent of the tokens.
class AccentChoice {
  /// A choice named [name], computed from [seed].
  const AccentChoice(this.name, this.seed);

  /// What the switch shows.
  final String name;

  /// '#RRGGBB', or null for the neutral accent.
  final String? seed;

  /// The pair of both modes, through the package's own engine.
  AccentPair get pair {
    final seed = this.seed;
    return seed == null ? AccentPair.neutral : accentFromColor(seed);
  }
}

/// The seeds of the accent switch.
const accentChoices = [
  AccentChoice('Neutral', null),
  AccentChoice('Blue', '#3B6FE0'),
  AccentChoice('Green', '#2F9E6B'),
  AccentChoice('Amber', '#E0A100'),
  AccentChoice('Rose', '#D9487C'),
  AccentChoice('Violet', '#8B5CF6'),
];

/// The text scales of the switch: G7 promises nothing clips at 2 and nothing overflows at 3.
const textScales = [1.0, 1.3, 2.0, 3.0];

/// Every switch.
@immutable
class GallerySettings {
  /// The defaults: the system's mode, the neutral accent, text at 1, left to right, nothing reduced.
  const GallerySettings({
    this.mode = TsuyaMode.system,
    this.accent = 0,
    this.textScale = 1,
    this.rtl = false,
    this.reduceTransparency = false,
    this.reduceMotion = false,
    this.highContrast = false,
  });

  /// Light, dark or the system's.
  final TsuyaMode mode;

  /// An index into [accentChoices].
  final int accent;

  /// One of [textScales].
  final double textScale;

  /// Right to left.
  final bool rtl;

  /// Glass opaque and unblurred, ambient and glow removed.
  final bool reduceTransparency;

  /// Every change instant.
  final bool reduceMotion;

  /// What the platform's high contrast setting does: opaque glass, no grain.
  final bool highContrast;

  /// The choice [accent] points to.
  AccentChoice get accentChoice => accentChoices[accent];

  /// These settings with some values replaced.
  GallerySettings copyWith({
    TsuyaMode? mode,
    int? accent,
    double? textScale,
    bool? rtl,
    bool? reduceTransparency,
    bool? reduceMotion,
    bool? highContrast,
  }) => GallerySettings(
    mode: mode ?? this.mode,
    accent: accent ?? this.accent,
    textScale: textScale ?? this.textScale,
    rtl: rtl ?? this.rtl,
    reduceTransparency: reduceTransparency ?? this.reduceTransparency,
    reduceMotion: reduceMotion ?? this.reduceMotion,
    highContrast: highContrast ?? this.highContrast,
  );
}

/// Holds the settings and tells the app when they change.
class GalleryController extends ValueNotifier<GallerySettings> {
  /// A controller starting from [settings].
  GalleryController([super.settings = const GallerySettings()]);
}

/// Gives the controller to the screens that show the switches.
class GalleryScope extends InheritedNotifier<GalleryController> {
  /// Provides [controller] to [child].
  const GalleryScope({super.key, required GalleryController controller, required super.child})
    : super(notifier: controller);

  /// The controller above [context]; reading the settings through it rebuilds on a change.
  static GalleryController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GalleryScope>()!.notifier!;
}
