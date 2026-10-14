// 11.21 Tabs, 11.22 Accordion, 11.23 TopBar (and ScreenBar).
import 'package:flutter/widgets.dart';
import 'package:tsuya/tsuya.dart';

import '../app/entry.dart';
import '../ui/demo.dart';
import '../ui/icons.dart';

void _noop() {}

/// The screens of the disclosure and bar components.
final navigationEntries = [
  GalleryEntry.component('tabs', 'Tabs', 'A row of text tabs, each with its panel.', _tabs),
  GalleryEntry.component('accordion', 'Accordion', 'Rows that open to show more.', _accordion),
  GalleryEntry.component(
    'top-bar',
    'TopBar',
    'The app bar of a website or desktop app, and the bar of a pushed screen.',
    _topBar,
  ),
];

Widget _tabs(BuildContext context) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Demo(
      'With panels',
      child: Hold<String>(
        initial: 'tracks',
        builder: (context, value, set) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Tabs<String>(
              label: 'Album',
              selected: value,
              onChanged: set,
              tabs: const [
                TabItem(value: 'tracks', label: 'Tracks'),
                TabItem(value: 'credits', label: 'Credits'),
                TabItem(value: 'reviews', label: 'Reviews'),
              ],
            ),
            for (final (id, text) in const [
              ('tracks', '11 tracks, 48 minutes.'),
              ('credits', 'Written and produced by Mira Vale.'),
              ('reviews', 'No reviews yet.'),
            ])
              TabView<String>(
                value: id,
                selected: value,
                label: id,
                child: Padding(
                  padding: const EdgeInsets.only(top: TsuyaSpace.s16),
                  child: _Body(text),
                ),
              ),
          ],
        ),
      ),
    ),
    Demo(
      'Too many to fit: they scroll sideways',
      child: Hold<String>(
        initial: 'rock',
        builder: (context, value, set) => Tabs<String>(
          label: 'Genre',
          selected: value,
          onChanged: set,
          tabs: const [
            TabItem(value: 'rock', label: 'Rock'),
            TabItem(value: 'jazz', label: 'Jazz'),
            TabItem(value: 'folk', label: 'Folk'),
            TabItem(value: 'electronic', label: 'Electronic'),
            TabItem(value: 'classical', label: 'Classical'),
            TabItem(value: 'ambient', label: 'Ambient', disabled: true),
          ],
        ),
      ),
    ),
    Demo(
      'Manual activation: arrows move, Enter chooses',
      child: Hold<String>(
        initial: 'a',
        builder: (context, value, set) => Tabs<String>(
          label: 'Plan',
          manual: true,
          selected: value,
          onChanged: set,
          tabs: const [
            TabItem(value: 'a', label: 'Monthly'),
            TabItem(value: 'b', label: 'Yearly'),
          ],
        ),
      ),
    ),
  ],
);

class _Body extends StatelessWidget {
  const _Body(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(text);
}

Widget _accordion(BuildContext context) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Demo(
      'One open at a time',
      child: Hold<List<String>>(
        initial: ['shipping'],
        builder: (context, value, set) => Accordion(
          value: value,
          onChanged: set,
          items: const [
            AccordionItemData(
              value: 'shipping',
              label: 'Shipping',
              content: _Body('Vinyl ships in 3 to 5 days, with tracking.'),
            ),
            AccordionItemData(
              value: 'returns',
              label: 'Returns',
              content: _Body('Sealed records can be returned within 30 days.'),
            ),
            AccordionItemData(value: 'care', label: 'Care', content: _Body('Store them upright, away from heat.')),
          ],
        ),
      ),
    ),
    Demo(
      'Several open, one disabled',
      child: Hold<List<String>>(
        initial: ['a', 'b'],
        builder: (context, value, set) => Accordion(
          multiple: true,
          value: value,
          onChanged: set,
          items: const [
            AccordionItemData(value: 'a', label: 'Sides', content: _Body('Two sides of 22 minutes.')),
            AccordionItemData(value: 'b', label: 'Pressing', content: _Body('180 g, cut at half speed.')),
            AccordionItemData(value: 'c', label: 'Bonus tracks', content: _Body('Digital only.'), disabled: true),
          ],
        ),
      ),
    ),
  ],
);

Widget _topBar(BuildContext context) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Demo(
      'App bar, glass over the page; the links collapse into a menu when narrow',
      child: OverArtwork(
        height: 200,
        cover: 1,
        child: Align(
          alignment: Alignment.topCenter,
          child: TopBar(
            start: const Text('tsuya', style: TextStyle(fontWeight: FontWeight.w800)),
            links: [
              TopBarLink(label: 'Listen', current: true, onPressed: _noop),
              TopBarLink(label: 'Library', onPressed: _noop),
              TopBarLink(label: 'Radio', onPressed: _noop),
            ],
            end: const IconButton(
              icon: Glyph(TsuyaGlyph.search),
              label: 'Search',
              kind: IconButtonKind.plain,
              onPressed: _noop,
            ),
          ),
        ),
      ),
    ),
    const Demo(
      'Screen bar',
      child: Stacked([
        ScreenBar(title: 'Settings', onBack: _noop, backLabel: 'Back'),
        ScreenBar(
          title: 'Low Tide',
          subtitle: 'The Harbour Club',
          onBack: _noop,
          backLabel: 'Back',
          action: IconButton(icon: GIconView(GIcon.more), label: 'More', kind: IconButtonKind.plain, onPressed: _noop),
        ),
        ScreenBar(
          title: 'A title that is far too long to fit between the back button and the action',
          onBack: _noop,
          backLabel: 'Back',
          action: IconButton(
            icon: GIconView(GIcon.share),
            label: 'Share',
            kind: IconButtonKind.plain,
            onPressed: _noop,
          ),
        ),
      ], gap: TsuyaSpace.s8),
    ),
  ],
);
