// The Flutter usage shown on the CommandPalette page: read, not invented, from
// packages/flutter/lib/src/components/command_palette.dart.
export const FLUTTER_COMMAND_PALETTE = `
CommandPalette.show<String>(
  context,
  groups: const [
    CommandGroup(
      label: 'Recent',
      commands: [Command(value: 'open', label: 'Open file…')],
    ),
    CommandGroup(
      label: 'Navigation',
      commands: [
        Command(value: 'settings', label: 'Go to settings'),
        Command(value: 'archive', label: 'Go to archive', disabled: true),
      ],
    ),
  ],
  onSelected: (value) {
    // …
  },
);`.trim();
