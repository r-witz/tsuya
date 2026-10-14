// The Flutter usage shown on the Popover page: read, not invented, from packages/flutter/lib/src/components/popover.dart.
export const FLUTTER_POPOVER = `
Popover(
  label: 'Filters',
  builder: (context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Showing 12 of 48 photos'),
      const SizedBox(height: 12),
      Button(label: 'Clear filters', onPressed: () {}),
    ],
  ),
)`.trim();

export const FLUTTER_SHOW = `
Builder(
  builder: (anchor) => IconButton(
    icon: const FilterIcon(), // your own icon widget: tsuya ships no icon set
    label: 'Filters',
    onPressed: () => Popover.show(
      anchor,
      label: 'Filters',
      side: AnchorSide.bottom,
      align: AnchorAlign.end,
      builder: (context) => const Text('Showing 12 of 48 photos'),
    ),
  ),
)`.trim();
