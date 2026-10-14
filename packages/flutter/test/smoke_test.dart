// Each component below, built at text scale 2 and 3 on a 320 px wide view (G7), and right to left under reduced
// motion (G9, G14), without an overflow or any other error. Its own tests check what more it does there.

import 'package:flutter/widgets.dart' hide RadioGroup;
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

const _star = SizedBox(width: 20, height: 20);

final _components = <String, Widget Function()>{
  'Accordion': () => Accordion(
    items: const [
      AccordionItemData(value: 'shipping', label: 'Shipping', content: Text('Ships in 2 days.')),
      AccordionItemData(value: 'returns', label: 'Returns', content: Text('Start a return')),
    ],
    value: const ['shipping'],
    onChanged: (_) {},
  ),
  'Avatar': () => const Center(
    child: Avatar(initials: 'JD', label: 'Jamie Doe'),
  ),
  'Button': () => Center(
    child: Button(label: 'A fairly long button label', onPressed: () {}),
  ),
  'Checkbox': () => Center(
    child: Checkbox(value: false, onChanged: (_) {}, label: 'A fairly long checkbox label'),
  ),
  'Chip': () => Center(
    child: Chip(label: 'A fairly long chip label', selected: false, onPressed: () {}),
  ),
  'ChipGroup': () => ChipGroup<String>(
    label: 'Sort by',
    value: const {'recent'},
    onChanged: (_) {},
    chips: const [
      ChipOption(value: 'recent', label: 'Recent'),
      ChipOption(value: 'popular', label: 'Popular'),
      ChipOption(value: 'top', label: 'Top'),
    ],
  ),
  'Field': () => const Field(
    label: 'A fairly long label for this field',
    hint: 'A fairly long hint that explains what to do',
    child: SizedBox(height: 44, width: 200),
  ),
  'Field with an error': () => const Field(
    label: 'Email',
    error: 'Enter a valid email address to continue',
    child: SizedBox(height: 44, width: 200),
  ),
  'IconButton': () => Center(
    child: IconButton(icon: _star, label: 'Share', onPressed: () {}),
  ),
  'ListItem': () => ListItem(
    title: 'A fairly long title that keeps going',
    subtitle: 'A fairly long subtitle that keeps going too',
    onPressed: () {},
    navigates: true,
  ),
  'PageHeader': () => const PageHeader(
    title: 'A fairly long page title that keeps going and going',
    subtitle: 'A fairly long subtitle that keeps going too',
    actions: SizedBox(width: 44, height: 44),
  ),
  'RadioGroup': () => Center(
    child: RadioGroup<String>(
      label: 'Size',
      value: 'md',
      onChanged: (_) {},
      options: const [
        RadioOption(value: 'sm', label: 'Small'),
        RadioOption(value: 'md', label: 'Medium'),
        RadioOption(value: 'lg', label: 'Large'),
      ],
    ),
  ),
  'Screen': () => Screen(
    builder: (context, padding) => ListView(
      padding: padding,
      children: [for (var i = 0; i < 30; i++) SizedBox(height: 40, child: Text('Row $i'))],
    ),
    dock: const SizedBox(height: 66),
  ),
  'ScreenBar': () => ScreenBar(title: 'Order 1042', subtitle: 'Shipped', onBack: () {}, backLabel: 'Back'),
  'Section': () => const Section(
    label: 'Network',
    children: [
      ListItem(title: 'Wi-Fi'),
      ListItem(title: 'Bluetooth'),
    ],
  ),
  'SectionHeader': () => const SectionHeader(title: 'A fairly long section title', count: '24', actionLabel: 'See all'),
  'SegmentedControl': () => Center(
    child: SegmentedControl<String>(
      label: 'View',
      segments: const [
        Segment(value: 'list', label: 'List'),
        Segment(value: 'grid', label: 'Grid'),
      ],
      selected: 'list',
      onChanged: (_) {},
    ),
  ),
  'Sidebar': () => const Align(
    alignment: Alignment.topLeft,
    child: Sidebar(
      label: 'Library',
      children: [
        SidebarItem(icon: _star, label: 'Home', current: true),
        SidebarGroup(
          label: 'Collection',
          children: [
            SidebarItem(icon: _star, label: 'Albums', count: 12),
            SidebarItem(icon: _star, label: 'Artists'),
          ],
        ),
      ],
    ),
  ),
  'Skeleton': () => const Skeleton.text(),
  'Slider': () => Center(
    child: SizedBox(
      width: 200,
      child: Slider(value: 10, onChanged: (_) {}, label: 'Volume'),
    ),
  ),
  'Switch': () => Center(
    child: Switch(value: false, onChanged: (_) {}, label: 'A fairly long switch label'),
  ),
  'TabBar': () => TabBar<String>(
    items: const [
      TabBarItem(value: 'home', label: 'Home', icon: Glyph(TsuyaGlyph.search)),
      TabBarItem(value: 'library', label: 'Your music library', icon: Glyph(TsuyaGlyph.search)),
      TabBarItem(
        value: 'inbox',
        label: 'Inbox',
        icon: Glyph(TsuyaGlyph.search),
        badge: TabBarBadge(count: 3, label: '3 new'),
      ),
      TabBarItem(value: 'settings', label: 'Settings', icon: Glyph(TsuyaGlyph.search)),
    ],
    current: 'home',
    onSelect: (_) {},
  ),
  'Tabs': () => Tabs<String>(
    label: 'Product',
    tabs: const [
      TabItem(value: 'overview', label: 'Overview'),
      TabItem(value: 'reviews', label: 'Reviews'),
      TabItem(value: 'details', label: 'Details'),
    ],
    selected: 'overview',
    onChanged: (_) {},
  ),
  'TextField': () => const SizedBox(
    width: 220,
    child: TextField(label: 'A fairly long label', placeholder: 'A fairly long placeholder text'),
  ),
  'Thumbnail': () => const Center(child: Thumbnail()),
  'TopBar': () => TopBar(
    links: [
      TopBarLink(label: 'Catalog', current: true, onPressed: () {}),
      TopBarLink(label: 'Orders', onPressed: () {}),
      TopBarLink(label: 'Help', onPressed: () {}),
    ],
  ),
};

void main() {
  const view = Size(320, 800);

  for (final MapEntry(key: name, value: build) in _components.entries) {
    testWidgets('G7: $name at text scale 2 and 3 on a 320 view overflows nothing', (tester) async {
      viewAt(tester, view);
      for (final scale in [2.0, 3.0]) {
        await tester.pumpWidget(host(build(), size: view, textScale: scale));
        expect(tester.takeException(), isNull, reason: 'scale $scale');
      }
    });

    testWidgets('G9, G14: $name builds right to left under reduced motion', (tester) async {
      viewAt(tester, view);
      // host turns animations off unless asked: reduced motion
      await tester.pumpWidget(host(build(), size: view, direction: TextDirection.rtl));
      expect(tester.takeException(), isNull);
    });
  }
}
