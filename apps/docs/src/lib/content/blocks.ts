// The blocks of the Blocks section: one entry per page under /blocks, in reading order. The index
// page, the page tree (nav.ts) and every block's page read it, so a block's rules are written once.
// Adding a block is one entry here plus its route folder and its example in lib/examples/blocks, named after its
// slug (content-page → ContentPage.svelte).

export interface Block {
  /** The route under /blocks. */
  slug: string;
  title: string;
  /** One sentence: what the block is for. */
  summary: string;
  /** The rules that the example shows, one line each. */
  rules: string[];
  /** The width the live example opens at. */
  width?: 'phone' | 'desktop';
  /** The example shows the sample covers: its page draws them first, then passes them in. */
  covers?: boolean;
}

export const BLOCKS: Block[] = [
  {
    slug: 'content-page',
    title: 'Content page',
    summary:
      'The page of one piece of content (an album, a film, a person, a place): the content large, and the whole page takes its accent and its light from the content’s own picture.',
    rules: [
      'The content comes first: its cover is large, with `shadow-lg`; centred on a phone, on the left on desktop with the text aligned to its bottom.',
      'Then, in this order: the kind label, the title, a line of key facts, a description in `body-l` of at most 60 characters a line, and the actions.',
      'One primary action, then icon buttons; the rest goes into “more”.',
      'Then sections of rows or of grids, each under its section header with a count.',
      'The page’s accent and its ambient background come from its picture (rule 1 and rule 2): `accentFromImage` once, `AccentRegion` for the accent, `Screen`’s `ambient` for the light.',
      'In a grid no item leads: each item keeps the region of its own cover, so its focus ring is in its own accent.',
    ],
    covers: true,
  },
  {
    slug: 'library',
    title: 'Library and grid',
    summary:
      'A collection of content as a grid or a list, with its counts, its sort and filter chips, and the three states that are not “some items”: loading, empty and no result.',
    rules: [
      'The page header carries the counts (“412 albums · 3 208 tracks”); the chips (sort, filters) and a grid / list segmented control sit under it.',
      'Grid columns are at least 148 wide, with gaps of 16 across and 24 down.',
      'No item leads in a grid: the controls keep the brand or neutral accent, and each item keeps the accent region of its own picture.',
      'The ambient background follows the hovered or focused item, and that item gets a focus-like ring in its own accent (on touch, the item at the top of the viewport).',
      'Loading is skeletons at the final size of what loads, in a container that is `aria-busy`; they are hidden from screen readers.',
      'Empty (“Your library is empty”) and no result (“No album matches”) each have a short title, one sentence and one action; the action of no result clears what hides the items.',
      'The number of results is announced when it changes.',
    ],
    covers: true,
  },
  {
    slug: 'settings',
    title: 'Settings',
    summary:
      'The page where a person sets the app up: the account first, then short sections of rows, switches that act at once, and the one destructive row alone at the end.',
    rules: [
      'Neutral glass: no content leads, so `GlassScope neutral` (the tab bar, menus and sheets here carry no tint).',
      'The account row comes first, as a tall row with an avatar.',
      'Sections of 2 to 6 rows, each under its section label; rows are full width with hairlines, never cards.',
      'Switches apply at once: there is no Save button, and a row named by its title names its switch the same.',
      'A destructive row stands alone in the last group, its title in `--t-danger`, and asks before it acts: the dialog’s initial focus is on the least destructive action.',
      'From about 20 settings, a search field goes above the account row.',
      'On desktop the column is at most 560 wide and a sidebar picks the section; on a phone every section is one list and the tab bar floats at the bottom.',
    ],
  },
  {
    slug: 'forms',
    title: 'Forms',
    summary:
      'A form in one column that says what is wrong when it can, in its own words, and never before the person has had a chance to fill the field.',
    rules: [
      'One column; every label is always visible above its field (never a placeholder in place of a label); 16 between fields.',
      'A required field is not marked, it is announced as required; an optional one says “optional” after its label.',
      'Validation on blur: a field is checked when it loses focus, not while the person is still typing in it for the first time.',
      'Once a field is in error it is checked on every input, so the error leaves as soon as it is fixed.',
      'On submit every field is checked and the focus goes to the first field in error.',
      'An error says what to do next, not a code; it replaces the hint and is read with the control.',
      'The actions come last: on a phone a full-width primary at the bottom, on desktop at the end of the row, with one accent action only.',
    ],
  },
  {
    slug: 'auth',
    title: 'Auth',
    summary:
      'Sign in, sign up and reset password: three short screens on the brand’s own accent, lit by the glow, since no content leads them.',
    rules: [
      'Brand accent and glow: with no content in view the accent is the brand colour (`accentFromColor`, computed once), and `Screen` shows the neutral glow where an ambient image would be.',
      'One column, no card; one accent-filled action per screen, the full-width button, and plain ghost buttons for the other ways through.',
      'Fields follow the Forms block: labels always visible, validation on blur then on input once in error, focus the first error on submit.',
      'A password field can be revealed (the `showPassword` and `hidePassword` labels name the button); the autocomplete attributes say which password it is.',
      'Moving between the three screens moves the focus to the new title, so it is announced.',
      'A reset never says whether the address has an account: the banner reads the same either way.',
    ],
  },
  {
    slug: 'phone-shell',
    title: 'Phone shell',
    summary:
      'The shell of an app on a phone: a screen with its margins, a floating glass tab bar, sheets from the bottom, and the player as the showcase of what the material does when content leads.',
    rules: [
      'Side margins of 20 (`--t-space-20`), the content scrolling under a glass tab bar that floats 12 from the edges and fades the content into the background.',
      'Three to five tabs; choosing the current tab scrolls to the top; a badge’s meaning is part of its tab’s name.',
      'Sheets rise from the bottom, at most the tablet width, with a handle; they follow the glass of what opens them, and the surface otherwise.',
      'The player is the showcase: the cover leads, so the accent (`AccentRegion`) and the ambient light (`Screen`’s `ambient`) come from it; on the other tabs no content leads, so there is the glow only.',
      'Control glass is for small controls over artwork, here the like and share buttons on a mid-to-dark cover; never straight on a very light picture.',
      'One accent-filled action per screen: the play button, whose neighbours are plain icon buttons.',
      'A pushed screen has a screen bar: a round back button, a centred title, at most one action.',
    ],
    covers: true,
  },
  {
    slug: 'desktop-shell',
    title: 'Desktop shell',
    summary:
      'The shell of an app on a desktop: a sidebar where a phone has its tab bar, a content column that stops growing, and a player bar of glass floating over what scrolls under it.',
    rules: [
      'A sidebar replaces the tab bar from the desktop width (1024): 240 wide, its items `--t-size-control-sm` tall with an icon, a label and a count; the current one is `--t-fill-strong`.',
      'It can collapse to its icons (72 wide), each label then a tooltip at the end of its item.',
      'The content column is at most 1200 wide (`--t-container-max-width`), centred in the room that is left.',
      'The player showcases the material again: the cover leads, so the accent and the ambient light come from it; with another track, both change.',
      'Control glass sits over the artwork (like, more); the player bar is glass above the content, with the shadow of a bar. At most three glass layers on screen.',
      'One accent-filled action per screen: the play button; previous and next are plain icon buttons.',
    ],
    width: 'desktop',
    covers: true,
  },
  {
    slug: 'website',
    title: 'Website',
    summary:
      'The front page of a product: a glass app bar floating above the page, and a hero lit by the product’s own imagery.',
    rules: [
      'The app bar is glass, floating 12 from the top and the sides, sticky, with the shadow of a bar; brand at the start, links in the middle, buttons at the end.',
      'Below the tablet width the bar folds its links into a menu, a popover from a plain icon button named by the `more` label; choosing a link closes it.',
      'The hero is lit by the product’s own imagery: the picture shown in it gives the page its accent (the bar’s glass is tinted by it) and the light at the top; choosing another one changes all three.',
      'One accent-filled action in the hero; the others are secondary or ghost.',
      'Below the hero, rows rather than cards, under a section title in `title-l`.',
      'A website has no tab bar: its navigation is the bar’s links.',
    ],
    width: 'desktop',
    covers: true,
  },
  {
    slug: 'dashboard',
    title: 'Dashboard-lite',
    summary:
      'A page of figures without charts: its header, its numbers as rows, and a list. Charts come in a later phase.',
    rules: [
      'A page header with its count line (here the period and when the data was updated), and its controls at the end.',
      'Stats as rows, not cards: a hairline above each, a short label, the figure in `title-l`, and its change.',
      'Figures are tabular (`font-variant-numeric: tabular-nums`) so that columns of numbers line up.',
      'A change is told by its sign and an arrow, never by colour alone; a status colour is text on an opaque ground only, and the background here is the glow.',
      'Then a list under a section header with its count; a number in a row is tabular and muted.',
      'No accent and no ambient light: nothing leads the page, only the neutral glow.',
    ],
    width: 'desktop',
  },
  {
    slug: 'states',
    title: 'Empty, error and offline',
    summary:
      'What a screen says when there is nothing to show, when something failed, and when the connection is gone: a short title, one sentence, one action.',
    rules: [
      'A short title, one sentence and one action: the title says what is missing or what happened, the sentence what to do next, never a code.',
      'An empty state says what is missing and offers one action; that action is the accent action of the screen.',
      'An error that replaces what the person waited for is centred in its place and read out when it appears (`role="alert"`); its action retries, and shows loading while it does.',
      'A state that lasts, such as offline, is a banner above the content, which stays usable; the banner holds its own action.',
      'A transient result (“Back online”) is a toast, which replaces the banner’s news without asking for anything.',
      'Status colours are marks and banner fills here (3:1), never text over glass or the ambient light.',
    ],
  },
];

export function getBlock(slug: string): Block {
  const block = BLOCKS.find((b) => b.slug === slug);
  if (!block) throw new Error(`no block "${slug}" in blocks.ts`);
  return block;
}
