// The library / grid block: counts, sort and filter chips, a grid or list switch, and its empty, no-result and
// loading states.
import 'package:flutter/widgets.dart' hide Banner, RadioGroup;
import 'package:tsuya/tsuya.dart';

import '../ui/block.dart';
import '../ui/covers.dart';
import '../ui/icons.dart';
import '../ui/state.dart';
import '../ui/text.dart';

enum _Data { loaded, loading, empty, noMatch }

/// The albums of a library.
class LibraryBlock extends StatefulWidget {
  /// A library, showing [data] first.
  const LibraryBlock({super.key, this.loading = false});

  /// Starts on the loading state.
  final bool loading;

  @override
  State<LibraryBlock> createState() => _LibraryBlockState();
}

class _LibraryBlockState extends State<LibraryBlock> {
  late _Data _data = widget.loading ? _Data.loading : _Data.loaded;
  bool _grid = true;
  Set<String> _sort = {'recent'};
  Set<String> _filters = {'downloaded'};

  @override
  Widget build(BuildContext context) => BlockScreen(
    builder: (context, layout) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          title: 'Albums',
          subtitle: '412 albums · 3 208 tracks',
          actions: SegmentedControl<bool>(
            label: 'View',
            selected: _grid,
            onChanged: (grid) => setState(() => _grid = grid),
            segments: const [
              Segment(value: true, label: 'Grid', icon: GIconView(GIcon.grid)),
              Segment(value: false, label: 'List', icon: GIconView(GIcon.list)),
            ],
          ),
        ),
        const SizedBox(height: TsuyaSpace.s16),
        ChipGroup<String>(
          label: 'Sort',
          value: _sort,
          onChanged: (v) => setState(() => _sort = v),
          chips: const [
            ChipOption(value: 'recent', label: 'Recent'),
            ChipOption(value: 'title', label: 'Title'),
            ChipOption(value: 'artist', label: 'Artist'),
          ],
        ),
        const SizedBox(height: TsuyaSpace.s8),
        ChipGroup<String>(
          label: 'Filters',
          multiple: true,
          value: _filters,
          onChanged: (v) => setState(() => _filters = v),
          chips: const [
            ChipOption(value: 'downloaded', label: 'Downloaded', icon: GIconView(GIcon.download)),
            ChipOption(value: 'favourites', label: 'Favourites', icon: GIconView(GIcon.heart)),
            ChipOption(value: 'new', label: 'New'),
          ],
        ),
        const SizedBox(height: TsuyaSpace.s24),
        _body(context, layout),
        const SizedBox(height: TsuyaSpace.s24),
        // the states are shown by choice here; an app shows the one its data is in
        SegmentedControl<_Data>(
          label: 'Preview the state',
          expand: true,
          selected: _data,
          onChanged: (data) => setState(() => _data = data),
          segments: const [
            Segment(value: _Data.loaded, label: 'Albums'),
            Segment(value: _Data.loading, label: 'Loading'),
            Segment(value: _Data.empty, label: 'Empty'),
            Segment(value: _Data.noMatch, label: 'No match'),
          ],
        ),
      ],
    ),
  );

  Widget _body(BuildContext context, Layout layout) => switch (_data) {
    _Data.empty => const StateView(
      icon: GIcon.album,
      title: 'Your library is empty',
      message: 'Add an album and it will show up here.',
      actionLabel: 'Browse albums',
    ),
    _Data.noMatch => const StateView(
      icon: GIcon.filter,
      title: 'No album matches',
      message: 'Remove a filter to see more of your library.',
      actionLabel: 'Clear filters',
    ),
    _ when !_grid => _list(),
    _ => _gridOf(context),
  };

  // columns at least 148 wide, gaps 16
  Widget _gridOf(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const gap = TsuyaSpace.s16;
      final columns = ((constraints.maxWidth + gap) / (148 + gap)).floor().clamp(2, 8);
      final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: TsuyaSpace.s24,
        children: [
          for (var i = 0; i < 12; i++)
            SizedBox(
              width: width,
              child: _data == _Data.loading
                  ? _SkeletonCell(width: width)
                  : _Cell(cover: covers[i % covers.length], width: width),
            ),
        ],
      );
    },
  );

  Widget _list() => Column(
    children: [
      for (var i = 0; i < 6; i++)
        if (_data == _Data.loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: TsuyaSpace.s8),
            child: Row(
              children: [
                Skeleton(width: 48, height: 48, radius: TsuyaRadius.xs),
                SizedBox(width: TsuyaSpace.s12),
                Expanded(child: Skeleton.text(lines: 2)),
              ],
            ),
          )
        else
          ListItem(
            title: covers[i].title,
            subtitle: covers[i].artist,
            leading: Thumbnail(image: covers[i].image, size: 48),
            onPressed: () {},
          ),
    ],
  );
}

// a grid item keeps its own accent region
class _Cell extends StatelessWidget {
  const _Cell({required this.cover, required this.width});

  final Cover cover;
  final double width;

  @override
  Widget build(BuildContext context) => Accent(
    pair: cover.accent,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Thumbnail(image: cover.image, size: width, label: '${cover.title}, ${cover.artist}'),
        const SizedBox(height: TsuyaSpace.s8),
        styled(context, TsuyaType.bodyStrong, cover.title, maxLines: 1),
        styled(context, TsuyaType.small, cover.artist, muted: true, maxLines: 1),
      ],
    ),
  );
}

class _SkeletonCell extends StatelessWidget {
  const _SkeletonCell({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Skeleton(width: width, height: width, radius: width <= 160 ? TsuyaRadius.md : TsuyaRadius.lg),
      const SizedBox(height: TsuyaSpace.s8),
      Skeleton(width: width * 0.7, height: 16, radius: TsuyaRadius.xs),
      const SizedBox(height: TsuyaSpace.s4),
      Skeleton(width: width * 0.45, height: 12, radius: TsuyaRadius.xs),
    ],
  );
}
