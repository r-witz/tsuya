# tsuya gallery

The Flutter gallery of tsuya: a screen for every component, for the four parts of the material (accent,
ambient, glass, grain) and for every block. It is the source of the goldens, and the docs take their
Flutter screenshots from them. It stays on the widgets layer, like the package: no Material, no Cupertino.

## Run it

```sh
cd apps/gallery
flutter pub get
flutter run -d chrome     # its one platform folder is web/
```

From 1024 px wide it shows a sidebar, the screen and the switches side by side; below, a tab bar (Components, Blocks,
Controls) and screens pushed under a screen bar. The switches apply to the whole app: mode (auto, light, dark), accent
(through `accentFromColor`), text scale (1, 1.3, 2, 3), direction, reduced transparency, reduced motion and high
contrast (`GlassScope`, and `MediaQuery`, which is where the package reads the last two).

The sample covers in `assets/covers` are drawn by `node tool/covers.mjs` (no third-party picture); the output is
committed.

## Tests

```sh
flutter test                              # everything, goldens included
flutter test --exclude-tags golden        # what does not compare pixels
flutter test --update-goldens             # rewrite the goldens (see below)
```

- `switches_test.dart`: each switch changes what it says it changes. `screens_test.dart`: every screen builds
  without an exception at 320 px wide and text scale 3, and right to left. `imports_test.dart`: no Material or
  Cupertino import under `lib/` or `test/`.
- `golden_components_test.dart`: every component and material screen, light and dark, at 390 px wide and as tall as
  the page (`test/goldens/components/<id>-<mode>.png`). `golden_overlays_test.dart`: the menu, popover, dialog,
  sheet, command palette, toast and select, open (`test/goldens/overlays/<id>-open-<mode>.png`).
- The tests load the real fonts (Inter, Geist Mono) and turn animations off, so a golden shows the design and does
  not move. `test/flutter_test_config.dart` installs a comparator that tolerates 0.5 % of differing pixels, where
  Flutter's own fails on one: anti-aliasing varies a little between machines.

### Goldens are written on one SDK

The goldens are written and checked on Flutter 3.47 and on Linux, as CI does: CI runs the gallery on that SDK only. The
engines do draw differently: on 3.44 a few goldens differ by 0.5 to 0.9 % of their pixels, more than the 0.5 %
tolerance absorbs, so a golden is only worth its comparison on the SDK that wrote it. The golden tests carry the tag
`golden`, to leave them out on another SDK (`flutter test --exclude-tags golden`).

After a change that moves pixels, run `flutter test --update-goldens` on Linux with Flutter 3.47, look at the PNGs that
changed, and commit them with the change.

## Where the docs pick the screenshots up

The docs page of a component shows `apps/gallery/test/goldens/components/<id>-light.png` (and `-dark`), where `<id>` is
the id of the entry in `lib/src/app/registry.dart`: `button`, `icon-button`, `text-field`, `command-palette`… An
overlay's page shows it open, from `test/goldens/overlays/<id>-open-<light|dark>.png`.
