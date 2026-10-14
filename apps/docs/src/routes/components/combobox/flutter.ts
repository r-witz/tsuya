// The Flutter usage shown on the Combobox page: read, not invented, from packages/flutter/lib/src/components/combobox.dart.
export const FLUTTER_COMBOBOX = `
Combobox<String>(
  label: 'City',
  placeholder: 'Type a city',
  onSelected: (city) {
    // …
  },
  options: const [
    ListboxOption(value: 'paris', label: 'Paris'),
    ListboxOption(value: 'lyon', label: 'Lyon'),
    ListboxOption(value: 'lille', label: 'Lille'),
  ],
)`.trim();
