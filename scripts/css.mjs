// packages/core/src/css/tokens.css: custom properties in the tokens layer. Light by default; dark from the system
// unless the root says light, and under data-theme="dark" on any element. The accent follows the nearest
// mode: each mode block mixes the pair --t-accent-light / --t-accent-dark with --t-mode-dark.
import { core, cssName, fontStack, HEADER, modes, referenced } from './tokens.mjs';

export const LAYERS = '@layer tsuya.tokens, tsuya.base, tsuya.material, tsuya.components;';
const P = '--t';
const px = ({ value, unit }) => `${value}${unit}`;

function cssValue(token) {
  const target = referenced(token.value);
  if (target) return `var(${cssName(target.path)})`;
  const v = token.value;
  switch (token.type) {
    case 'color':
    case 'number':
      return String(v);
    case 'dimension':
    case 'duration':
      return px(v);
    case 'cubicBezier':
      return `cubic-bezier(${v.join(', ')})`;
    case 'fontFamily':
      return fontStack(v);
    case 'shadow':
      return `${px(v.offsetX)} ${px(v.offsetY)} ${px(v.blur)} ${px(v.spread)} ${v.color}`;
    default:
      throw new Error(`No CSS for $type ${token.type} (${token.path.join('.')})`);
  }
}

// a type token gives the `font` shorthand and its tracking: font: var(--t-type-body); letter-spacing: var(…-tracking)
function declarations(token) {
  if (token.type !== 'typography') return [`${cssName(token.path)}: ${cssValue(token)};`];
  const v = token.value;
  const family = cssName(referenced(v.fontFamily).path);
  return [
    `${cssName(token.path)}: ${v.fontWeight} ${px(v.fontSize)}/${v.lineHeight} var(${family});`,
    `${cssName(token.path)}-tracking: ${px(v.letterSpacing)};`,
  ];
}

const accentOf = (mode) => modes[mode].find((t) => t.path.join('.') === 'color.accent').value;
const MIXED_ACCENT = `${P}-accent: color-mix(in srgb, var(${P}-accent-dark) calc(var(${P}-mode-dark) * 100%), var(${P}-accent-light));`;

function modeDeclarations(mode) {
  return [
    `color-scheme: ${mode};`,
    `${P}-mode-dark: ${mode === 'dark' ? 1 : 0};`,
    ...modes[mode].flatMap((t) => (t.path.join('.') === 'color.accent' ? [MIXED_ACCENT] : declarations(t))),
  ];
}

const block = (selector, lines, indent = '  ') =>
  [`${indent}${selector} {`, ...lines.map((l) => `${indent}  ${l}`), `${indent}}`].join('\n');

export function buildCss() {
  const root = [
    `${P}-accent-light: ${accentOf('light')};`,
    `${P}-accent-dark: ${accentOf('dark')};`,
    ...core.flatMap(declarations),
  ];
  return `/* ${HEADER} */
${LAYERS}

@layer tsuya.tokens {
${block(':root', root)}

${block(':root,\n  [data-theme="light"]', modeDeclarations('light'))}

  @media (prefers-color-scheme: dark) {
${block(':root:not([data-theme="light"])', modeDeclarations('dark'), '    ')}
  }

${block('[data-theme="dark"]', modeDeclarations('dark'))}
}
`;
}
