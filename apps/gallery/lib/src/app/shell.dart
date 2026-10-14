// The gallery's own navigation, built from the package's shells (DESIGN.md, Layout): a sidebar from desktop width, a
// floating tab bar and pushed screens with a screen bar below it.
import 'package:flutter/widgets.dart';
import 'package:tsuya/tsuya.dart';

import '../ui/icons.dart';
import 'controls.dart';
import 'entry.dart';
import 'host.dart';
import 'registry.dart';

/// The gallery: a sidebar beside the screen and the switches on desktop, tabs and pushed screens on phone.
class GalleryShell extends StatefulWidget {
  /// The shell, opening on [initial] (the first entry by default).
  const GalleryShell({super.key, this.initial});

  /// The entry shown first on desktop.
  final GalleryEntry? initial;

  @override
  State<GalleryShell> createState() => _GalleryShellState();
}

enum _Tab { components, blocks, controls }

class _GalleryShellState extends State<GalleryShell> {
  late GalleryEntry _selected = widget.initial ?? allEntries.first;
  _Tab _tab = _Tab.components;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => constraints.maxWidth >= TsuyaBreakpoint.desktop ? _desktop(context) : _phone(),
  );

  Widget _desktop(BuildContext context) {
    final colors = TsuyaTheme.of(context).colors;
    BoxDecoration edge({required bool start}) => BoxDecoration(
      color: colors.bg,
      border: BorderDirectional(
        start: start ? BorderSide(color: colors.border) : BorderSide.none,
        end: start ? BorderSide.none : BorderSide(color: colors.border),
      ),
    );
    return Row(
      children: [
        DecoratedBox(
          decoration: edge(start: false),
          child: SingleChildScrollView(
            child: Sidebar(
              label: 'Gallery',
              children: [
                for (final kind in EntryKind.values)
                  SidebarGroup(
                    label: kind.label,
                    children: [
                      for (final entry in allEntries.where((e) => e.kind == kind))
                        SidebarItem(
                          icon: GIconView(kind.icon),
                          label: entry.title,
                          current: entry == _selected,
                          onPressed: () => setState(() => _selected = entry),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        Expanded(child: EntryBody(_selected, key: ValueKey(_selected.id))),
        DecoratedBox(
          decoration: edge(start: true),
          child: const SizedBox(
            width: 280,
            child: SingleChildScrollView(padding: EdgeInsets.all(TsuyaSpace.s20), child: ControlsPanel()),
          ),
        ),
      ],
    );
  }

  Widget _phone() => Screen(
    dock: TabBar<_Tab>(
      label: 'Gallery',
      current: _tab,
      onSelect: (tab) => setState(() => _tab = tab),
      items: const [
        TabBarItem(value: _Tab.components, label: 'Components', icon: GIconView(GIcon.box)),
        TabBarItem(value: _Tab.blocks, label: 'Blocks', icon: GIconView(GIcon.layout)),
        TabBarItem(value: _Tab.controls, label: 'Controls', icon: GIconView(GIcon.settings)),
      ],
    ),
    builder: (context, padding) => SingleChildScrollView(
      padding: padding.copyWith(top: padding.top + TsuyaSpace.s24),
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: switch (_tab) {
            _Tab.components => _list(context, 'Components', [EntryKind.component, EntryKind.material]),
            _Tab.blocks => _list(context, 'Blocks', [EntryKind.block]),
            _Tab.controls => const _Controls(),
          },
        ),
      ),
    ),
  );

  Widget _list(BuildContext context, String title, List<EntryKind> kinds) {
    final count = allEntries.where((e) => kinds.contains(e.kind)).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: TsuyaSpace.s8),
          child: PageHeader(title: title, subtitle: '$count screens'),
        ),
        for (final kind in kinds)
          Section(
            label: kind.label,
            children: [
              for (final entry in allEntries.where((e) => e.kind == kind))
                ListItem(
                  title: entry.title,
                  subtitle: entry.summary,
                  navigates: true,
                  onPressed: () =>
                      Navigator.of(context).push(fadeRoute<void>(const RouteSettings(), (_) => _EntryRoute(entry))),
                ),
            ],
          ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls();

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.only(bottom: TsuyaSpace.s24),
        child: PageHeader(title: 'Controls', subtitle: 'They apply to the whole gallery'),
      ),
      ControlsPanel(),
    ],
  );
}

/// A pushed screen: the screen bar above the entry.
class _EntryRoute extends StatelessWidget {
  const _EntryRoute(this.entry);

  final GalleryEntry entry;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: TsuyaTheme.of(context).colors.bg,
    child: Column(
      children: [
        ScreenBar(title: entry.title, onBack: () => Navigator.of(context).pop(), backLabel: 'Back'),
        Expanded(child: EntryBody(entry)),
      ],
    ),
  );
}
