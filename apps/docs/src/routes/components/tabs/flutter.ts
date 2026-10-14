// The Flutter usage shown on the Tabs page: read, not invented, from packages/flutter/lib/src/components/tabs.dart.
export const FLUTTER_BASIC = `
Tabs<String>(
  label: 'Product',
  tabs: const [
    TabItem(value: 'overview', label: 'Overview'),
    TabItem(value: 'reviews', label: 'Reviews'),
  ],
  selected: selected,
  onChanged: (value) => setState(() => selected = value),
)

// below it, one panel per tab:
TabView<String>(
  value: 'reviews',
  selected: selected,
  label: 'Reviews',
  child: const Text('4.6 out of 5, from 128 reviews'),
)`.trim();
