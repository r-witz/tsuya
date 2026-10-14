// What the tokens must hold before the build writes anything: well-formed values, the same tokens in both modes, one
// token per CSS name, and the contrast guarantees (G1, G2) at their worst (packages/core/src/engine/check.ts).
import { checkMode, looksLike } from '../packages/core/src/engine/check.ts';
import { core, cssName, modeObject, modes, RESERVED, valueOf } from './tokens.mjs';

const HEX = /^#([0-9A-F]{6}|[0-9A-F]{8})$/;

function checkValue(token) {
  const where = token.path.join('.');
  const value = valueOf(token);
  const unit = (v, expected) =>
    v?.unit === expected ? [] : [`${where}: ${JSON.stringify(v)} must be in ${expected}.`];
  switch (token.type) {
    case 'color':
      return HEX.test(value) ? [] : [`${where}: ${value} must be #RRGGBB or #RRGGBBAA, upper case.`];
    case 'dimension':
      return unit(value, 'px');
    case 'duration':
      return unit(value, 'ms');
    case 'shadow':
      return [
        ...unit(value.offsetX, 'px'),
        ...unit(value.offsetY, 'px'),
        ...unit(value.blur, 'px'),
        ...unit(value.spread, 'px'),
        ...(HEX.test(value.color) ? [] : [`${where}: ${value.color} must be upper-case hex.`]),
      ];
    case 'typography':
      return [...unit(value.fontSize, 'px'), ...unit(value.letterSpacing, 'px')];
    case 'number':
      return typeof value === 'number' ? [] : [`${where}: ${value} must be a number.`];
    case 'fontFamily':
    case 'cubicBezier':
      return Array.isArray(value) ? [] : [`${where}: ${value} must be a list.`];
    default:
      return [`${where}: unsupported $type ${token.type}.`];
  }
}

export function checkStructure(coreTokens = core, modeTokens = modes) {
  const errors = [...coreTokens, ...modeTokens.light, ...modeTokens.dark].flatMap(checkValue);
  const signature = (tokens) => tokens.map((t) => `${t.path.join('.')}: ${t.type}`).join('\n');
  if (signature(modeTokens.light) !== signature(modeTokens.dark)) {
    errors.push(
      'tokens/light.json and tokens/dark.json must define the same tokens, with the same types, in the same order.',
    );
  }
  const owner = new Map(RESERVED.map((name) => [name, 'tokens.css itself']));
  for (const token of [...coreTokens, ...modeTokens.light]) {
    const name = cssName(token.path);
    // a type token also writes its tracking: --t-type-body and --t-type-body-tracking
    for (const css of token.type === 'typography' ? [name, `${name}-tracking`] : [name]) {
      if (owner.has(css)) errors.push(`${token.path.join('.')} and ${owner.get(css)} both write ${css}.`);
      owner.set(css, token.path.join('.'));
    }
  }
  return errors;
}

/** Every contrast check (G1, G2) in both modes with its worst case, and the failures as messages. */
export function checkContrast() {
  const glassValue = (name) => valueOf(core.find((t) => t.path.join('.') === `glass.${name}`));
  const glass = { opacity: glassValue('opacity'), tint: glassValue('tint') };
  const report = [];
  const errors = [];
  for (const [mode, tokens] of Object.entries(modes)) {
    const theme = modeObject(tokens);
    if (!looksLike(theme, mode)) errors.push(`${mode}: bg does not look like ${mode} mode.`);
    for (const result of checkMode(theme, glass)) {
      report.push({ mode, ...result });
      if (result.ratio < result.min) {
        const worst = result.worst ? ` (worst: ${result.worst})` : '';
        errors.push(`${mode}: ${result.check} is ${result.ratio.toFixed(2)}:1, needs ${result.min}:1${worst}.`);
      }
    }
  }
  return { report, errors };
}

/** The worst case of each check, one line each, both modes side by side. */
export function formatReport(report) {
  const lines = [];
  for (const check of [...new Set(report.map((r) => r.check))]) {
    const cells = ['light', 'dark'].map((mode) => {
      const r = report.find((x) => x.mode === mode && x.check === check);
      return `${r.ratio.toFixed(2).padStart(6)}${r.ratio < r.min ? ' ✗' : '  '}`;
    });
    const min = report.find((x) => x.check === check).min;
    lines.push(`  ${check.padEnd(58)} ${cells.join(' ')}   (min ${min})`);
  }
  return [`  ${'check'.padEnd(58)}  light    dark`, ...lines].join('\n');
}
