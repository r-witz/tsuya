// The Tokens section of DESIGN.md, between its markers, and the check that the rest of the text names only tokens
// that exist (by their CSS names, --t-…).
import { core, cssName, fontStack, group, HEADER, modes, referenced, RESERVED, valueOf } from './tokens.mjs';

const MARKERS = ['<!-- tokens:start -->', '<!-- tokens:end -->'];

function plain(token) {
  const target = referenced(token.value);
  if (target) return `\`${cssName(target.path)}\``;
  const v = token.value;
  switch (token.type) {
    case 'dimension':
    case 'duration':
      return `${v.value} ${v.unit}`;
    case 'cubicBezier':
      return `cubic-bezier(${v.join(', ')})`;
    case 'fontFamily':
      return fontStack(v);
    case 'shadow':
      return `${v.offsetX.value} ${v.offsetY.value} ${v.blur.value} ${v.spread.value} ${v.color}`;
    default:
      return String(v);
  }
}

const row = (cells) => `| ${cells.join(' | ')} |`;
const table = (head, rows) => [row(head), row(head.map(() => '---')), ...rows.map(row)].join('\n');
const code = (token) => `\`${cssName(token.path)}\``;

function modeTable(groups, last = 'use') {
  const pick = (mode) => modes[mode].filter((t) => groups.includes(t.path[0]));
  const dark = pick('dark');
  return table(
    ['token', 'light', 'dark', last],
    pick('light').map((t, i) => [code(t), plain(t), plain(dark[i]), t.description ?? '']),
  );
}

function typeTable() {
  return table(
    ['style', 'font', 'size', 'line height', 'weight', 'tracking', 'use'],
    group(core, 'type').map((t) => {
      const v = valueOf(t);
      const tracking = Math.round((v.letterSpacing.value / v.fontSize.value) * 1000) / 1000;
      return [
        code(t),
        referenced(v.fontFamily).value[0],
        `${v.fontSize.value} px`,
        v.lineHeight,
        v.fontWeight,
        `${tracking} em`,
        t.description ?? '',
      ];
    }),
  );
}

// "Cells under…" reads "cells under…" inside a list; "CIE…" stays as it is
const lowerFirst = (text) => (/^[A-Z]{2}/.test(text) ? text : text[0].toLowerCase() + text.slice(1));
const described = (t) => (t.description ? ` (${lowerFirst(t.description.replace(/\.$/, ''))})` : '');
const coreList = (name) =>
  group(core, name)
    .map((t) => `${code(t)} ${plain(t)}${described(t)}`)
    .join(' · ');

const LISTS = [
  'font',
  'space',
  'radius',
  'size',
  'breakpoint',
  'container',
  'duration',
  'easing',
  'state',
  'accent',
  'ambient',
  'glass',
  'grain',
  'glow',
];

function tokensSection() {
  const modeGroups = [...new Set(modes.light.map((t) => t.path[0]))].filter((g) => g !== 'color' && g !== 'shadow');
  return [
    HEADER.replace('Do not edit: change the JSON and rebuild.', 'Do not edit this section.'),
    '',
    'Colours, per mode:',
    '',
    modeTable(['color'], 'role'),
    '',
    'Shadows (offset x, offset y, blur, spread, colour), per mode:',
    '',
    modeTable(['shadow']),
    '',
    'Material values, per mode:',
    '',
    modeTable(modeGroups),
    '',
    'Type:',
    '',
    typeTable(),
    '',
    ...LISTS.map((name) => `- **${name}**: ${coreList(name)}`),
  ].join('\n');
}

/** DESIGN.md with its Tokens section regenerated, and the token names its text uses that do not exist. */
export function buildDesign(text) {
  const [start, end] = MARKERS.map((m) => text.indexOf(m));
  if (start < 0 || end < start) throw new Error(`DESIGN.md needs the markers ${MARKERS.join(' and ')}`);
  const known = new Set([
    ...RESERVED,
    ...[...core, ...modes.light].flatMap((t) =>
      t.type === 'typography' ? [cssName(t.path), `${cssName(t.path)}-tracking`] : [cssName(t.path)],
    ),
  ]);
  const prose = text.slice(0, start) + text.slice(end);
  const used = prose.match(/(?<![\w-])--t-[a-z0-9]+(?:-[a-z0-9]+)*/g) ?? [];
  const unknown = [...new Set(used)].filter((name) => !known.has(name));
  return { text: `${text.slice(0, start + MARKERS[0].length)}\n${tokensSection()}\n${text.slice(end)}`, unknown };
}
