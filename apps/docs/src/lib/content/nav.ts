// Every page of the docs site, in one place: drives the Sidebar's page tree, the TopBar's top-level
// links, the components index, each page's <meta name="description"> and the index at /llms.txt. Adding a
// component page is one entry here plus its route folder.
import { BLOCKS } from './blocks.ts';

export interface NavEntry {
  /** The route path; '' is the home page. */
  slug: string;
  title: string;
  /** One sentence: what the page is about. Its meta description, and its line in an index. */
  summary: string;
}

export interface NavGroup {
  label: string;
  entries: NavEntry[];
}

/** The sidebar's page tree, shown from the desktop breakpoint. */
export const NAV: NavGroup[] = [
  {
    label: 'Start',
    entries: [
      {
        slug: '',
        title: 'Home',
        summary: 'Neutral surfaces, familiar layouts, and one material that comes from whatever is on screen.',
      },
      {
        slug: 'getting-started',
        title: 'Getting started',
        summary:
          'Install tsuya in a SvelteKit app, a site without a framework or a Flutter app: a first screen, dark mode without a flash, an accent from an image.',
      },
    ],
  },
  {
    label: 'Foundations',
    entries: [
      {
        slug: 'foundations',
        title: 'Foundations',
        summary:
          'Colour, type, space, radius, motion and state are plain CSS custom properties and Dart constants, generated from the same JSON (@tsuya/core/tokens).',
      },
      {
        slug: 'material',
        title: 'Material',
        summary:
          'The content leads: its colour becomes the accent, its image lights the background. The same engine runs on Svelte and Flutter, bit-identical.',
      },
      {
        slug: 'theming',
        title: 'Theming',
        summary: 'Three knobs for an app to make tsuya its own, and one check that keeps it honest.',
      },
    ],
  },
  {
    label: 'Components',
    entries: [
      {
        slug: 'components',
        title: 'Components',
        summary:
          "Every page follows the same template: a live preview, Svelte usage and the HTML it renders, Flutter usage, the props of both, variants, keyboard and screen reader behaviour, and do and don't.",
      },
      { slug: 'components/button', title: 'Button', summary: 'A labelled action: the pill button of the system.' },
      { slug: 'components/text-input', title: 'TextInput', summary: 'A text field, a text area and a search field.' },
      { slug: 'components/field', title: 'Field', summary: 'The frame of a form control: label, hint and error.' },
      { slug: 'components/icon-button', title: 'IconButton', summary: 'An icon-only action or a toggle.' },
      { slug: 'components/checkbox', title: 'Checkbox', summary: 'A choice that is part of a form.' },
      { slug: 'components/radio-group', title: 'RadioGroup', summary: 'One choice among a few, all seen together.' },
      {
        slug: 'components/segmented-control',
        title: 'SegmentedControl',
        summary: '2 to 5 options seen together, one always selected.',
      },
      {
        slug: 'components/slider',
        title: 'Slider',
        summary: 'A value on a range, picked by dragging or with the keys.',
      },
      { slug: 'components/select', title: 'Select', summary: 'A choice among more than five options.' },
      { slug: 'components/combobox', title: 'Combobox', summary: 'A text input that filters a list of options.' },
      { slug: 'components/chip', title: 'Chip', summary: 'A filter or a sort option, alone or in a group.' },
      { slug: 'components/spinner', title: 'Spinner', summary: 'Progress that cannot be estimated.' },
      { slug: 'components/tooltip', title: 'Tooltip', summary: 'A short label for a control, on hover and focus.' },
      { slug: 'components/popover', title: 'Popover', summary: 'A non-modal panel anchored to a trigger.' },
      { slug: 'components/switch', title: 'Switch', summary: 'A toggle that applies at once, with no save step.' },
      { slug: 'components/menu', title: 'Menu', summary: 'Actions anchored to the control that opens them.' },
      { slug: 'components/avatar', title: 'Avatar', summary: 'A person, as a photo or initials.' },
      {
        slug: 'components/thumbnail',
        title: 'Thumbnail',
        summary: 'The picture of a content: an album, a poster, a photo.',
      },
      { slug: 'components/badge', title: 'Badge', summary: 'A count or a dot pinned on a host.' },
      { slug: 'components/progress', title: 'Progress', summary: 'A bar that fills while something loads.' },
      { slug: 'components/skeleton', title: 'Skeleton', summary: 'Placeholders for what is about to load.' },
      { slug: 'components/list', title: 'List', summary: 'Full-width rows that link, act or inform.' },
      { slug: 'components/page-header', title: 'PageHeader', summary: 'A page title, and the title of a section.' },
      { slug: 'components/tabs', title: 'Tabs', summary: 'Text tabs, each with its panel.' },
      { slug: 'components/accordion', title: 'Accordion', summary: 'Rows that open their content below.' },
      { slug: 'components/top-bar', title: 'TopBar', summary: 'The app bar, and the bar of a pushed screen.' },
      { slug: 'components/tab-bar', title: 'TabBar', summary: 'The tab bar and the shell of a phone app.' },
      { slug: 'components/sidebar', title: 'Sidebar', summary: 'The navigation of a desktop shell.' },
      { slug: 'components/banner', title: 'Banner', summary: 'A lasting state: offline, an error, a trial.' },
      { slug: 'components/dialog', title: 'Dialog', summary: 'A decision that needs an answer.' },
      { slug: 'components/sheet', title: 'Sheet', summary: 'Content that rises from an edge.' },
      { slug: 'components/toast', title: 'Toast', summary: 'A short message about what just happened.' },
      { slug: 'components/command-palette', title: 'CommandPalette', summary: 'A search-driven list of commands.' },
    ],
  },
  {
    label: 'Blocks',
    entries: [
      {
        slug: 'blocks',
        title: 'Blocks',
        summary:
          'Blocks are examples, not packaged components: the patterns of the system, built only from its public API, live, in light and dark, at a phone and at a desktop width.',
      },
      ...BLOCKS.map((block) => ({ slug: `blocks/${block.slug}`, title: block.title, summary: block.summary })),
    ],
  },
  {
    label: 'Resources',
    entries: [
      {
        slug: 'for-agents',
        title: 'For agents',
        summary: 'Where an agent reads tsuya: DESIGN.md, the contract, and llms.txt, an index of this site.',
      },
      {
        slug: 'changelog',
        title: 'Changelog',
        summary: '@tsuya/core, @tsuya/svelte and tsuya (Flutter) are released together, with one version.',
      },
    ],
  },
];

/** Every page, flattened, in the order of the page tree. */
export const PAGES: NavEntry[] = NAV.flatMap((group) => group.entries);

/** The TopBar's centre links; it folds them into a menu below the tablet width. */
export const TOP_LINKS: NavEntry[] = [
  'getting-started',
  'foundations',
  'material',
  'theming',
  'components',
  'blocks',
  'for-agents',
  'changelog',
].map((slug) => PAGES.find((page) => page.slug === slug) as NavEntry);
