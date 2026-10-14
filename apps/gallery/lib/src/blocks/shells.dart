// Blocks: the phone shell, the desktop shell and the website.
import 'package:flutter/widgets.dart' hide Banner, RadioGroup;
import 'package:tsuya/tsuya.dart';

import '../ui/block.dart';
import '../ui/covers.dart';
import '../ui/demo.dart';
import '../ui/icons.dart';
import '../ui/text.dart';

void _noop() {}

Widget _albums(BuildContext context, {int count = 4, double size = 148}) => SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [
      for (final cover in covers.take(count))
        Padding(
          padding: const EdgeInsetsDirectional.only(end: TsuyaSpace.s16),
          child: SizedBox(
            width: size,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Thumbnail(image: cover.image, size: size, label: cover.title),
                const SizedBox(height: TsuyaSpace.s8),
                styled(context, TsuyaType.bodyStrong, cover.title, maxLines: 1),
                styled(context, TsuyaType.small, cover.artist, muted: true, maxLines: 1),
              ],
            ),
          ),
        ),
    ],
  ),
);

/// The phone shell: margins of 20, a floating glass tab bar, the first cover lighting the top. Wider than a phone it
/// is shown in a phone-sized frame.
class PhoneShellBlock extends StatelessWidget {
  /// The phone shell.
  const PhoneShellBlock({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final shell = Hold<String>(
        initial: 'home',
        builder: (context, tab, set) => Accent(
          pair: covers[0].accent,
          child: Screen(
            ambient: covers[0].image,
            dock: TabBar<String>(
              label: 'Main',
              current: tab,
              onSelect: set,
              items: const [
                TabBarItem(value: 'home', label: 'Home', icon: GIconView(GIcon.home, size: 24)),
                TabBarItem(value: 'library', label: 'Library', icon: GIconView(GIcon.library, size: 24)),
                TabBarItem(value: 'search', label: 'Search', icon: Glyph(TsuyaGlyph.search, size: 24)),
                TabBarItem(
                  value: 'inbox',
                  label: 'Inbox',
                  icon: GIconView(GIcon.mail, size: 24),
                  badge: TabBarBadge(count: 2, label: '2 new'),
                ),
              ],
            ),
            builder: (context, padding) => ListView(
              padding: padding.copyWith(top: padding.top + TsuyaSpace.s24),
              children: [
                const PageHeader(title: 'Good evening', subtitle: 'Pick up where you left off'),
                const SectionHeader(title: 'Recently played', count: '12', actionLabel: 'See all', onAction: _noop),
                _albums(context),
                const SectionHeader(title: 'Made for you'),
                for (final cover in covers.skip(2))
                  ListItem(
                    title: cover.title,
                    subtitle: cover.artist,
                    leading: Thumbnail(image: cover.image, size: 48),
                    onPressed: _noop,
                  ),
              ],
            ),
          ),
        ),
      );
      if (constraints.maxWidth < TsuyaBreakpoint.tablet) return shell;
      final colors = TsuyaTheme.of(context).colors;
      return ColoredBox(
        color: colors.fill,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(TsuyaSpace.s24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(TsuyaRadius.lg),
              child: SizedBox(
                width: 390,
                height: constraints.maxHeight - 2 * TsuyaSpace.s24,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(size: const Size(390, 844)),
                  child: shell,
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// The desktop shell: a sidebar (icons only below `desktop`), a content column of at most 1200, a top bar.
class DesktopShellBlock extends StatelessWidget {
  /// The desktop shell.
  const DesktopShellBlock({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final collapsed = constraints.maxWidth < TsuyaBreakpoint.desktop;
      final colors = TsuyaTheme.of(context).colors;
      return Accent(
        pair: covers[2].accent,
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.bg,
                border: BorderDirectional(end: BorderSide(color: colors.border)),
              ),
              child: Sidebar(
                collapsed: collapsed,
                label: 'Main',
                children: [
                  SidebarGroup(
                    label: 'Listen',
                    children: [
                      SidebarItem(icon: const GIconView(GIcon.home), label: 'Home', current: true, onPressed: _noop),
                      SidebarItem(icon: const Glyph(TsuyaGlyph.search), label: 'Search', onPressed: _noop),
                      SidebarItem(icon: const GIconView(GIcon.library), label: 'Library', count: 412, onPressed: _noop),
                    ],
                  ),
                  SidebarGroup(
                    label: 'Playlists',
                    children: [
                      SidebarItem(icon: const GIconView(GIcon.list), label: 'Morning', onPressed: _noop),
                      SidebarItem(icon: const GIconView(GIcon.list), label: 'Focus', onPressed: _noop),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlockScreen(
                ambient: covers[2].image,
                builder: (context, layout) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const PageHeader(
                      title: 'Good evening',
                      subtitle: 'Pick up where you left off',
                      actions: Button(label: 'Shuffle all', kind: ButtonKind.primary, onPressed: _noop),
                    ),
                    const SectionHeader(title: 'Recently played', count: '12', actionLabel: 'See all', onAction: _noop),
                    _albums(context, count: 6, size: 160),
                    const SectionHeader(title: 'Made for you'),
                    Section(
                      label: 'Today',
                      children: [
                        for (final cover in covers.skip(3))
                          ListItem(
                            title: cover.title,
                            subtitle: cover.artist,
                            leading: Thumbnail(image: cover.image, size: 48),
                            onPressed: _noop,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// The website: a glass app bar floating 12 from the top over a hero lit by the product's own imagery.
class WebsiteBlock extends StatelessWidget {
  /// The website.
  const WebsiteBlock({super.key});

  @override
  Widget build(BuildContext context) => Accent(
    pair: covers[3].accent,
    child: Stack(
      children: [
        BlockScreen(
          ambient: covers[3].image,
          builder: (context, layout) {
            final phone = layout == Layout.phone;
            final copy = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                styled(context, phone ? TsuyaType.displayM : TsuyaType.displayL, 'Listen to what you own'),
                const SizedBox(height: TsuyaSpace.s16),
                styled(
                  context,
                  TsuyaType.bodyL,
                  'A music player that takes its colours from the record on screen, and stays quiet otherwise.',
                  muted: true,
                ),
                const SizedBox(height: TsuyaSpace.s24),
                const Variants([
                  Button(label: 'Get the app', kind: ButtonKind.primary, size: ButtonSize.lg, onPressed: _noop),
                  Button(label: 'See how it works', size: ButtonSize.lg, onPressed: _noop),
                ]),
              ],
            );
            final art = coverShadow(
              context,
              radius: TsuyaRadius.lg,
              child: Thumbnail(image: covers[3].image, size: phone ? 280 : 360, label: 'Field Notes'),
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: TsuyaSize.bar + TsuyaSpace.s32),
                if (phone) ...[
                  copy,
                  const SizedBox(height: TsuyaSpace.s32),
                  Center(child: art),
                ] else
                  Row(
                    children: [
                      Expanded(child: copy),
                      const SizedBox(width: TsuyaSpace.s48),
                      art,
                    ],
                  ),
                const SizedBox(height: TsuyaSpace.s48),
                const Section(
                  label: 'Why it is different',
                  children: [
                    ListItem(
                      title: 'Colour from the cover',
                      subtitle: 'Every screen takes the accent of what you play.',
                    ),
                    ListItem(title: 'Nothing loops', subtitle: 'Motion follows a change and stops.'),
                    ListItem(title: 'Yours offline', subtitle: 'Downloads keep playing without a signal.'),
                  ],
                ),
              ],
            );
          },
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: TopBar(
            start: styled(context, TsuyaType.bodyStrong, 'tsuya'),
            links: [
              TopBarLink(label: 'Product', current: true, onPressed: _noop),
              TopBarLink(label: 'Pricing', onPressed: _noop),
              TopBarLink(label: 'Docs', onPressed: _noop),
            ],
            // an icon, not a labelled button: a button's label would not fit beside the brand at 300 % text
            end: const IconButton(
              icon: GIconView(GIcon.user),
              label: 'Sign in',
              kind: IconButtonKind.plain,
              onPressed: _noop,
            ),
          ),
        ),
      ],
    ),
  );
}
