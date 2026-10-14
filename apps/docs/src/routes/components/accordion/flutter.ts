// The Flutter usage shown on the Accordion page: read, not invented, from packages/flutter/lib/src/components/accordion.dart.
export const FLUTTER_BASIC = `
Accordion(
  multiple: false,
  value: open,
  onChanged: (next) => setState(() => open = next),
  items: const [
    AccordionItemData(
      value: 'shipping',
      label: 'Shipping',
      content: Text('Free over 50 €, 3 to 5 days.'),
    ),
    AccordionItemData(
      value: 'returns',
      label: 'Returns',
      content: Text('Within 30 days, unused.'),
    ),
  ],
)`.trim();
