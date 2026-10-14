// The settings block: neutral glass, the account first, sections of two to six rows, switches that apply at
// once, a destructive row alone at the end; on desktop a column of at most 560 beside a sidebar.
import 'package:flutter/widgets.dart' hide Banner, RadioGroup;
import 'package:tsuya/tsuya.dart';

import '../ui/block.dart';
import '../ui/demo.dart';
import '../ui/icons.dart';
import '../ui/text.dart';

void _noop() {}

/// The settings of a music app.
class SettingsBlock extends StatelessWidget {
  /// The settings screen.
  const SettingsBlock({super.key});

  @override
  Widget build(BuildContext context) => GlassScope(
    neutral: true,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final desktop = Layout.of(constraints.maxWidth) == Layout.desktop;
        final column = BlockScreen(maxWidth: 560, builder: (context, layout) => _Column(layout: layout));
        if (!desktop) return column;
        return Row(
          children: [
            const _CategoryBar(),
            Expanded(child: column),
          ],
        );
      },
    ),
  );
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar();

  @override
  Widget build(BuildContext context) {
    final colors = TsuyaTheme.of(context).colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.bg,
        border: BorderDirectional(end: BorderSide(color: colors.border)),
      ),
      child: Sidebar(
        label: 'Settings',
        children: [
          SidebarGroup(
            label: 'Settings',
            children: [
              SidebarItem(icon: const GIconView(GIcon.user), label: 'Account', onPressed: _noop),
              SidebarItem(icon: const GIconView(GIcon.play), label: 'Playback', current: true, onPressed: _noop),
              SidebarItem(icon: const GIconView(GIcon.bell), label: 'Notifications', onPressed: _noop),
              SidebarItem(icon: const GIconView(GIcon.lock), label: 'Privacy', onPressed: _noop),
            ],
          ),
        ],
      ),
    );
  }
}

class _Column extends StatelessWidget {
  const _Column({required this.layout});

  final Layout layout;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const PageHeader(title: 'Settings'),
      const SizedBox(height: TsuyaSpace.s16),
      const ListItem(
        title: 'Mira Vale',
        subtitle: 'mira@example.com',
        leading: Avatar(initials: 'MV'),
        tall: true,
        navigates: true,
        onPressed: _noop,
      ),
      Section(
        label: 'Playback',
        children: [
          _toggle('Crossfade', 'Blend the end of a track into the next', true),
          _toggle('Normalise volume', null, true),
          _toggle('Gapless playback', null, false),
          ListItem(
            title: 'Streaming quality',
            trailing: styled(context, TsuyaType.small, 'High', muted: true),
            navigates: true,
            onPressed: _noop,
          ),
        ],
      ),
      Section(
        label: 'Notifications',
        children: [_toggle('New releases', 'From artists you follow', true), _toggle('Concerts nearby', null, false)],
      ),
      const Section(
        label: 'About',
        children: [
          ListItem(title: 'Terms of use', navigates: true, onPressed: _noop),
          ListItem(title: 'Open source licences', navigates: true, onPressed: _noop),
          ListItem(title: 'Version', trailing: Text('1.0.0')),
        ],
      ),
      const Section(
        label: 'Account',
        children: [ListItem(title: 'Sign out', destructive: true, onPressed: _noop)],
      ),
    ],
  );

  // a switch applies at once: there is no Save
  Widget _toggle(String title, String? subtitle, bool initial) => Hold<bool>(
    initial: initial,
    builder: (context, on, set) => ListItem(
      title: title,
      subtitle: subtitle,
      trailing: Switch(value: on, onChanged: set),
    ),
  );
}
