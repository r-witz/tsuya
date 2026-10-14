// The Flutter usage shown on the Chip page: read, not invented, from packages/flutter/lib/src/components/chip.dart.
export const FLUTTER_CHIP = `
ChipGroup<String>(
  label: 'Sort by',
  value: {sort},
  onChanged: (selection) => setState(() => sort = selection.first),
  chips: const [
    ChipOption(value: 'recent', label: 'Recent'),
    ChipOption(value: 'title', label: 'Title'),
    ChipOption(value: 'artist', label: 'Artist'),
  ],
)`.trim();

export const FLUTTER_CHIP_ALONE = `
Chip(
  label: 'Downloaded',
  selected: downloaded,
  icon: const Glyph(TsuyaGlyph.check), // tsuya draws a few glyphs itself; bring your own icons for the rest
  onPressed: () => setState(() => downloaded = !downloaded),
)

ChipGroup<String>(
  label: 'Genres',
  multiple: true,
  value: genres,
  onChanged: (selection) => setState(() => genres = selection),
  chips: const [
    ChipOption(value: 'jazz', label: 'Jazz'),
    ChipOption(value: 'rock', label: 'Rock'),
  ],
)`.trim();
