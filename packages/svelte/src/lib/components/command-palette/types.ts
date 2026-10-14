// The commands of a palette (DESIGN.md, CommandPalette), in a module of their own: a plain .ts file reads a type
// from here, where a type from a .svelte file is past what the type-aware lint resolves.

/** A command: what `onselect` receives. */
export interface Command {
  /** Passed to `onselect`. */
  value: string;
  /** The text shown. */
  label: string;
  /** Shown, but cannot run. */
  disabled?: boolean;
}

/** Commands under a heading. */
export interface CommandGroup {
  /** The group's heading. */
  label: string;
  /** Its commands. */
  commands: Command[];
}
