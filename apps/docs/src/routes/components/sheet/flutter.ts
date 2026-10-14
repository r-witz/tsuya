// The Flutter usage shown on the Sheet page: read, not invented, from packages/flutter/lib/src/components/sheet.dart.
export const FLUTTER_SHEET = `
final sort = await Sheet.show<String>(
  context,
  builder: (sheetContext) => Sheet(
    label: 'Sort by',
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SectionHeader(title: 'Sort by'),
        ListItem(title: 'Name', onPressed: () => Sheet.close(sheetContext, 'name')),
        ListItem(title: 'Date added', onPressed: () => Sheet.close(sheetContext, 'date')),
      ],
    ),
  ),
);`.trim();

export const FLUTTER_SIDE = `
await Sheet.show<void>(
  context,
  side: SheetSide.end,
  builder: (sheetContext) => Sheet(
    label: 'Filters',
    child: Button(
      label: 'Apply',
      kind: ButtonKind.primary,
      onPressed: () => Sheet.close(sheetContext),
    ),
  ),
);`.trim();
