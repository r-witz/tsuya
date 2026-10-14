// Blocks: dashboard-lite, and the empty, error and offline states.
import 'package:flutter/widgets.dart' hide Banner, RadioGroup;
import 'package:tsuya/tsuya.dart';

import '../ui/block.dart';
import '../ui/covers.dart';
import '../ui/demo.dart';
import '../ui/icons.dart';
import '../ui/state.dart';
import '../ui/text.dart';

void _noop() {}

/// A page header, rows of tabular figures and a list.
class DashboardBlock extends StatelessWidget {
  /// The dashboard.
  const DashboardBlock({super.key});

  @override
  Widget build(BuildContext context) => BlockScreen(
    builder: (context, layout) {
      const stats = [
        ('Hours listened', '128.4', '+12 %'),
        ('Tracks played', '2 041', '+5 %'),
        ('New artists', '37', '-3 %'),
      ];
      final plays = [412, 318, 266, 190, 121, 87];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHeader(title: 'Listening', subtitle: 'The last 30 days'),
          const SizedBox(height: TsuyaSpace.s16),
          Hold<String>(
            initial: 'month',
            builder: (context, range, set) => SegmentedControl<String>(
              label: 'Range',
              expand: true,
              selected: range,
              onChanged: set,
              segments: const [
                Segment(value: 'week', label: 'Week'),
                Segment(value: 'month', label: 'Month'),
                Segment(value: 'year', label: 'Year'),
              ],
            ),
          ),
          const SizedBox(height: TsuyaSpace.s24),
          // figures in rows under hairlines, not in cards
          if (layout == Layout.phone)
            Column(
              children: [for (final s in stats) _Stat(label: s.$1, value: s.$2, change: s.$3, wide: false)],
            )
          else
            Row(
              children: [
                for (final s in stats)
                  Expanded(
                    child: _Stat(label: s.$1, value: s.$2, change: s.$3, wide: true),
                  ),
              ],
            ),
          const SectionHeader(title: 'Top albums', actionLabel: 'See all', onAction: _noop),
          for (final (i, plays) in plays.indexed)
            ListItem(
              title: covers[i % covers.length].title,
              subtitle: covers[i % covers.length].artist,
              leading: Thumbnail(image: covers[i % covers.length].image, size: 48),
              trailing: SizedBox(
                width: layout == Layout.phone ? 64 : 160,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    styled(context, tabular(TsuyaType.small), '$plays plays', muted: true),
                    const SizedBox(height: TsuyaSpace.s4),
                    Progress(value: plays / 412, label: '${covers[i % covers.length].title}, $plays plays', thin: true),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.change, required this.wide});

  final String label;
  final String value;
  final String change;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final colors = TsuyaTheme.of(context).colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: TsuyaSpace.s16),
        // a Wrap: at large text the figure goes under its label rather than past the edge
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: TsuyaSpace.s12,
          runSpacing: TsuyaSpace.s4,
          children: [
            styled(context, TsuyaType.small, label, muted: true),
            styled(context, tabular(wide ? TsuyaType.displayS : TsuyaType.titleL), wide ? value : '$value  $change'),
          ],
        ),
      ),
    );
  }
}

/// The three states that replace content: empty, error and, as a banner above it, offline.
class StatesBlock extends StatelessWidget {
  /// The states.
  const StatesBlock({super.key});

  @override
  Widget build(BuildContext context) => BlockScreen(
    builder: (context, layout) {
      const empty = StateView(
        icon: GIcon.download,
        title: 'No downloads yet',
        message: 'Download an album and it plays without a connection.',
        actionLabel: 'Browse albums',
      );
      const error = StateView(
        icon: GIcon.warning,
        title: 'We could not load your library',
        message: 'Check your connection, then try again.',
        actionLabel: 'Try again',
      );
      final offline = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Banner(
            tone: BannerTone.warning,
            title: 'You are offline',
            message: 'Downloaded music still plays.',
            actions: [Button(label: 'Go to downloads', size: ButtonSize.sm, onPressed: _noop)],
          ),
          const SizedBox(height: TsuyaSpace.s16),
          for (final cover in covers.take(3))
            ListItem(
              title: cover.title,
              subtitle: cover.artist,
              leading: Thumbnail(image: cover.image, size: 48),
              onPressed: _noop,
            ),
        ],
      );
      Widget titled(String label, Widget child) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: TsuyaSpace.s8),
            child: styled(context, TsuyaType.label, label, muted: true),
          ),
          child,
        ],
      );
      final parts = [titled('Empty', empty), titled('Error', error), titled('Offline', offline)];
      return layout == Layout.desktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final p in parts)
                  Expanded(
                    child: Padding(padding: const EdgeInsets.all(TsuyaSpace.s12), child: p),
                  ),
              ],
            )
          : Stacked(parts, gap: TsuyaSpace.s24);
    },
  );
}
