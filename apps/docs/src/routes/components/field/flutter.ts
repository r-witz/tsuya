// The Flutter usage shown on the Field page: read, not invented, from packages/flutter/lib/src/components/field.dart.
export const FLUTTER_FIELD = `
Field(
  label: 'Volume',
  hint: 'Applies to every device.',
  child: Slider(
    label: 'Volume',
    value: volume,
    onChanged: (value) => setState(() => volume = value),
  ),
)`.trim();
