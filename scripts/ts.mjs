// packages/core/src/tokens.ts: the token values for scripts, the colour engine and checkTheme. Lengths are numbers
// in px, durations in ms; each mode is a `Mode` (colours, shadows, material values); keys are camelCase.
import { core, fontStack, group, groupNames, HEADER, memberName, modes, referenced, valueOf } from './tokens.mjs';

const number = (dimension) => dimension.value;

function tsValue(token) {
  const v = valueOf(token);
  switch (token.type) {
    case 'dimension':
    case 'duration':
      return number(v);
    case 'fontFamily':
      return fontStack(v);
    case 'shadow':
      return {
        color: v.color,
        offsetX: number(v.offsetX),
        offsetY: number(v.offsetY),
        blur: number(v.blur),
        spread: number(v.spread),
      };
    case 'typography':
      return {
        fontFamily: fontStack(referenced(v.fontFamily).value),
        fontSize: number(v.fontSize),
        fontWeight: v.fontWeight,
        lineHeight: v.lineHeight,
        letterSpacing: number(v.letterSpacing),
      };
    default:
      return v;
  }
}

const TS_TYPES = { color: 'string', number: 'number', dimension: 'number', shadow: 'Shadow' };
const object = (tokens) => Object.fromEntries(tokens.map((t) => [memberName(t.path), tsValue(t)]));
const json = (value) => JSON.stringify(value, null, 2);

function modeInterface() {
  const groups = groupNames(modes.light).map((g) => {
    const members = group(modes.light, g).map((t) => {
      const type = TS_TYPES[t.type];
      if (!type) throw new Error(`No TypeScript type for $type ${t.type} (${t.path.join('.')})`);
      return `    readonly ${memberName(t.path)}: ${type};`;
    });
    return `  readonly ${g}: {\n${members.join('\n')}\n  };`;
  });
  return `/** The tokens that change with the mode: colours, shadows and material values. */\nexport interface Mode {\n${groups.join('\n')}\n}`;
}

const modeValue = (name) => Object.fromEntries(groupNames(modes[name]).map((g) => [g, object(group(modes[name], g))]));

export function buildTs() {
  return (
    [
      `// ${HEADER}`,
      '/** A shadow: colour, then offsets, blur and spread in px. */\nexport interface Shadow {\n  readonly color: string;\n  readonly offsetX: number;\n  readonly offsetY: number;\n  readonly blur: number;\n  readonly spread: number;\n}',
      modeInterface(),
      `export const light: Mode = ${json(modeValue('light'))};`,
      `export const dark: Mode = ${json(modeValue('dark'))};`,
      ...groupNames(core).map((g) => `export const ${g} = ${json(object(group(core, g)))} as const;`),
    ].join('\n\n') + '\n'
  );
}
