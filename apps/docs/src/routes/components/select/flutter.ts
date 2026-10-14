// The Flutter usage shown on the Select page: read, not invented, from packages/flutter/lib/src/components/select.dart.
export const FLUTTER_SELECT = `
Select<String>(
  label: 'Country',
  value: country,
  placeholder: 'Choose a country',
  onChanged: (value) => setState(() => country = value),
  options: const [
    ListboxOption(value: 'fr', label: 'France'),
    ListboxOption(value: 'de', label: 'Germany'),
    ListboxOption(value: 'it', label: 'Italy', disabled: true),
  ],
)`.trim();
