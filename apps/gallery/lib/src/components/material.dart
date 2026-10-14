// The material: accent, ambient background, glass, grain.
import 'package:flutter/widgets.dart';
import 'package:tsuya/tsuya.dart';

import '../app/entry.dart';
import '../app/settings.dart';
import '../ui/covers.dart';
import '../ui/demo.dart';

void _noop() {}

/// The screens of the material.
final materialEntries = [
  GalleryEntry.material('accent', 'Accent', 'The colour of the content on screen, for both modes.', _accent),
  GalleryEntry.material(
    'ambient',
    'Ambient',
    'The leading content, blurred, lighting the top of the screen.',
    _ambient,
  ),
  GalleryEntry.material('glass', 'Glass', 'Surfaces that float above content, tinted by the accent.', _glass),
  GalleryEntry.material('grain', 'Grain', 'Film grain under the content, never on text or glass.', _grain),
];

// a region in the mode it is told, whatever the app's
class _Panel extends StatelessWidget {
  const _Panel({required this.mode, required this.pair, required this.child});

  final TsuyaMode mode;
  final AccentPair pair;
  final Widget child;

  @override
  Widget build(BuildContext context) => TsuyaTheme(
    mode: mode,
    child: Builder(
      builder: (context) {
        final colors = TsuyaTheme.of(context).colors;
        return Accent(
          pair: pair,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.bg,
              borderRadius: BorderRadius.circular(TsuyaRadius.md),
              border: Border.all(color: colors.border),
            ),
            child: Padding(padding: const EdgeInsets.all(TsuyaSpace.s16), child: child),
          ),
        );
      },
    ),
  );
}

Widget _sample() => const Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Button(label: 'Play', kind: ButtonKind.primary, size: ButtonSize.sm, onPressed: _noop),
    SizedBox(height: TsuyaSpace.s12),
    Progress(value: 0.6, label: 'Position'),
    SizedBox(height: TsuyaSpace.s12),
    Switch(value: true, onChanged: null),
  ],
);

Widget _accent(BuildContext context) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Demo(
      'From a seed, light and dark side by side',
      child: Stacked([
        for (final choice in accentChoices)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: TsuyaSpace.s8),
                child: Text('${choice.name}  ${choice.seed ?? 'the text colour'}'),
              ),
              Row(
                children: [
                  Expanded(
                    child: _Panel(mode: TsuyaMode.light, pair: choice.pair, child: _sample()),
                  ),
                  const SizedBox(width: TsuyaSpace.s12),
                  Expanded(
                    child: _Panel(mode: TsuyaMode.dark, pair: choice.pair, child: _sample()),
                  ),
                ],
              ),
            ],
          ),
      ], gap: TsuyaSpace.s16),
    ),
    Demo(
      'From the content in view',
      child: Variants([
        for (final cover in covers)
          Accent(
            pair: cover.accent,
            child: Column(
              children: [
                Thumbnail(image: cover.image, size: 96, label: cover.title),
                const SizedBox(height: TsuyaSpace.s8),
                const Button(label: 'Play', kind: ButtonKind.primary, size: ButtonSize.sm, onPressed: _noop),
              ],
            ),
          ),
      ], spacing: TsuyaSpace.s16),
    ),
  ],
);

Widget _lit(Cover cover, {bool glow = false}) => ClipRRect(
  borderRadius: BorderRadius.circular(TsuyaRadius.md),
  child: ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 280),
    child: Accent(
      pair: glow ? AccentPair.neutral : cover.accent,
      child: TsuyaSurface(
        ambient: glow ? null : cover.image,
        child: Padding(
          padding: const EdgeInsets.all(TsuyaSpace.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Thumbnail(image: cover.image, size: 96, label: cover.title),
              const SizedBox(height: TsuyaSpace.s16),
              Builder(
                builder: (context) {
                  final theme = TsuyaTheme.of(context);
                  return Text(cover.title, style: theme.text(TsuyaType.titleL));
                },
              ),
              Text(cover.artist),
            ],
          ),
        ),
      ),
    ),
  ),
);

Widget _ambient(BuildContext context) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Demo('Lit by a cover', child: Stacked([_lit(covers[0]), _lit(covers[1]), _lit(covers[4])])),
    Demo('No content leads: the neutral glow', child: _lit(covers[0], glow: true)),
  ],
);

Widget _glass(BuildContext context) {
  Widget bar(String text) => Glass(
    borderRadius: BorderRadius.circular(TsuyaRadius.lg),
    shadow: GlassShadow.md,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: TsuyaSpace.s20, vertical: TsuyaSpace.s16),
      child: Text(text),
    ),
  );
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Demo(
        'Tinted by the accent, the default',
        child: Accent(
          pair: covers[1].accent,
          child: OverArtwork(cover: 1, height: 140, child: bar('Tinted glass')),
        ),
      ),
      Demo(
        'Neutral, for settings, forms and grids',
        child: Accent(
          pair: covers[1].accent,
          child: GlassScope(neutral: true, child: OverArtwork(cover: 1, height: 140, child: bar('Neutral glass'))),
        ),
      ),
      Demo(
        'Reduced transparency: opaque and unblurred',
        child: Accent(
          pair: covers[1].accent,
          child: GlassScope(reduce: true, child: OverArtwork(cover: 1, height: 140, child: bar('Opaque glass'))),
        ),
      ),
      Demo(
        'Control glass, a veil over artwork',
        child: OverArtwork(
          cover: 2,
          height: 120,
          child: ControlGlass(
            borderRadius: BorderRadius.circular(TsuyaRadius.full),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: TsuyaSpace.s20, vertical: TsuyaSpace.s12),
              child: Text('Control glass'),
            ),
          ),
        ),
      ),
    ],
  );
}

Widget _grain(BuildContext context) {
  Widget tile(String label, GrainMode mode) => Expanded(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(TsuyaRadius.md),
      child: SizedBox(
        height: 160,
        child: TsuyaSurface(
          grain: mode,
          child: Padding(padding: const EdgeInsets.all(TsuyaSpace.s12), child: Text(label)),
        ),
      ),
    ),
  );
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Demo(
        'On the background (default), over everything, off',
        child: Row(
          children: [
            tile('Background', GrainMode.bg),
            const SizedBox(width: TsuyaSpace.s8),
            tile('Everything', GrainMode.all),
            const SizedBox(width: TsuyaSpace.s8),
            tile('Off', GrainMode.off),
          ],
        ),
      ),
    ],
  );
}
