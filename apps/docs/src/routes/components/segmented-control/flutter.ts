// The Flutter usage shown on the SegmentedControl page: read, not invented, from packages/flutter/lib/src/components/segmented_control.dart.
export const FLUTTER_SEGMENTED_CONTROL = `
SegmentedControl<String>(
  label: 'View',
  selected: view,
  onChanged: (value) => setState(() => view = value),
  segments: const [
    Segment(value: 'list', label: 'List'),
    Segment(value: 'grid', label: 'Grid'),
    Segment(value: 'map', label: 'Map'),
  ],
)`.trim();
