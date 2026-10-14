// The switches, as a form: mode, accent, text scale, direction, and the three things a platform can ask to reduce.
import 'package:flutter/widgets.dart';
import 'package:tsuya/tsuya.dart';

import '../ui/demo.dart';
import 'settings.dart';

/// Every switch of the gallery, wired to the nearest [GalleryScope].
class ControlsPanel extends StatelessWidget {
  /// The panel.
  const ControlsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GalleryScope.of(context);
    final settings = controller.value;
    void change(GallerySettings Function(GallerySettings s) update) => controller.value = update(settings);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Demo(
          'Mode',
          child: SegmentedControl<TsuyaMode>(
            label: 'Mode',
            expand: true,
            selected: settings.mode,
            onChanged: (mode) => change((s) => s.copyWith(mode: mode)),
            segments: const [
              Segment(value: TsuyaMode.system, label: 'Auto'),
              Segment(value: TsuyaMode.light, label: 'Light'),
              Segment(value: TsuyaMode.dark, label: 'Dark'),
            ],
          ),
        ),
        Demo(
          'Accent',
          child: ChipGroup<int>(
            label: 'Accent',
            value: {settings.accent},
            onChanged: (value) {
              if (value.isNotEmpty) change((s) => s.copyWith(accent: value.single));
            },
            chips: [for (var i = 0; i < accentChoices.length; i++) ChipOption(value: i, label: accentChoices[i].name)],
          ),
        ),
        Demo(
          'Text scale',
          child: SegmentedControl<double>(
            label: 'Text scale',
            expand: true,
            selected: settings.textScale,
            onChanged: (scale) => change((s) => s.copyWith(textScale: scale)),
            segments: [for (final scale in textScales) Segment(value: scale, label: '$scale×'.replaceAll('.0', ''))],
          ),
        ),
        Demo(
          'Direction',
          child: SegmentedControl<bool>(
            label: 'Direction',
            expand: true,
            selected: settings.rtl,
            onChanged: (rtl) => change((s) => s.copyWith(rtl: rtl)),
            segments: const [
              Segment(value: false, label: 'LTR'),
              Segment(value: true, label: 'RTL'),
            ],
          ),
        ),
        Demo(
          'Platform',
          child: Stacked([
            Switch(
              value: settings.reduceTransparency,
              onChanged: (on) => change((s) => s.copyWith(reduceTransparency: on)),
              label: 'Reduce transparency',
            ),
            Switch(
              value: settings.reduceMotion,
              onChanged: (on) => change((s) => s.copyWith(reduceMotion: on)),
              label: 'Reduce motion',
            ),
            Switch(
              value: settings.highContrast,
              onChanged: (on) => change((s) => s.copyWith(highContrast: on)),
              label: 'High contrast',
            ),
          ], gap: TsuyaSpace.s8),
        ),
      ],
    );
  }
}
