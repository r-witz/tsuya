// The Flutter usage shown on the Slider page: read, not invented, from packages/flutter/lib/src/components/slider.dart.
export const FLUTTER_SLIDER = `
Slider(
  label: 'Volume',
  value: volume,
  min: 0,
  max: 100,
  step: 5,
  valueLabel: (value) => '\${value.round()} %',
  onChanged: (value) => setState(() => volume = value),
  onChangeEnd: (value) {
    // …
  },
)`.trim();
