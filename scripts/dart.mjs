// packages/flutter/lib/src/foundation/tokens.g.dart: one class per core group (TsuyaSpace.s16), and three classes with
// a `light` and a `dark` instance for what changes with the mode: colours, shadows and material values.
import {
  camel,
  core,
  cssName,
  group,
  groupNames,
  HEADER,
  memberName,
  modes,
  parseHex,
  pascal,
  referenced,
} from './tokens.mjs';

const P = 'Tsuya';
const dartDouble = (n) => (Number.isInteger(n) ? n.toFixed(1) : String(n));
const hex2 = (n) => Math.round(n).toString(16).padStart(2, '0').toUpperCase();

function dartColor(hex) {
  const { r, g, b, a } = parseHex(hex);
  return `Color(0x${hex2(a * 255)}${hex2(r)}${hex2(g)}${hex2(b)})`;
}

const px = (dimension) => dartDouble(dimension.value);

// CSS draws a shadow blur of B with a Gaussian of σ = B / 2; Flutter turns blurRadius r into σ = 0.57735 r + 0.5
const blurRadius = (blur) => dartDouble(Math.round(((blur.value / 2 - 0.5) / 0.57735) * 100) / 100);

// a Dart name cannot start with a digit: space.16 becomes TsuyaSpace.s16
function member(path) {
  const name = memberName(path);
  return /^\d/.test(name) ? `${path[0][0]}${name}` : name;
}

const coreClass = (groupName) => `${P}${pascal(groupName)}`;

function dartValue(token) {
  const target = referenced(token.value);
  if (target) return `${coreClass(target.path[0])}.${member(target.path)}`;
  const v = token.value;
  switch (token.type) {
    case 'color':
      return dartColor(v);
    case 'dimension':
      return px(v);
    case 'number':
      return dartDouble(v);
    case 'duration':
      return `Duration(milliseconds: ${v.value})`;
    case 'cubicBezier':
      return `Cubic(${v.map(dartDouble).join(', ')})`;
    case 'fontFamily':
      return `'${v[0]}'`;
    case 'shadow':
      return `[BoxShadow(color: ${dartColor(v.color)}, offset: Offset(${px(v.offsetX)}, ${px(v.offsetY)}), blurRadius: ${blurRadius(v.blur)}, spreadRadius: ${px(v.spread)})]`;
    case 'typography':
      return (
        `TextStyle(package: 'tsuya', fontFamily: '${referenced(v.fontFamily).value[0]}', ` +
        `fontSize: ${px(v.fontSize)}, fontWeight: FontWeight.w${v.fontWeight}, height: ${dartDouble(v.lineHeight)}, ` +
        `letterSpacing: ${px(v.letterSpacing)}, leadingDistribution: TextLeadingDistribution.even)`
      );
    default:
      throw new Error(`No Dart for $type ${token.type} (${token.path.join('.')})`);
  }
}

const doc = (token, indent) => `${indent}/// ${token.description ?? `The \`${cssName(token.path)}\` token.`}\n`;

function coreConstants(groupName) {
  const members = group(core, groupName).map(
    (t) => `${doc(t, '  ')}  static const ${member(t.path)} = ${dartValue(t)};`,
  );
  return `/// The \`${groupName}\` tokens.\nabstract final class ${coreClass(groupName)} {\n${members.join('\n\n')}\n}`;
}

// colours and shadows get a class each; every other mode group (accent, ambient, glow) goes into the material class
// (`field`: the member of the theme data, foundation/theme.dart, that holds the mode's instance)
const MODE_CLASSES = [
  { name: `${P}Colors`, doc: 'The colours of a mode.', type: 'Color', groups: ['color'], member, field: 'colors' },
  {
    name: `${P}Shadows`,
    doc: 'The shadows of a mode.',
    type: 'List<BoxShadow>',
    groups: ['shadow'],
    member,
    field: 'shadows',
  },
  {
    name: `${P}Material`,
    doc: 'The material values of a mode: the accent tone band, the ambient limits and the glow.',
    type: 'double',
    groups: groupNames(modes.light).filter((g) => g !== 'color' && g !== 'shadow'),
    member: (path) => camel(path.join('-')),
    field: 'material',
  },
];

function modeClass({ name, doc: classDoc, type, groups, member: name_, field }) {
  const pick = (mode) => modes[mode].filter((t) => groups.includes(t.path[0]));
  const fields = pick('light').map((t) => `${doc(t, '  ')}  final ${type} ${name_(t.path)};`);
  const instance = (mode) =>
    `  /// The ${mode} mode.\n  static const ${mode} = ${name}(\n${pick(mode)
      .map((t) => `    ${name_(t.path)}: ${dartValue(t)},`)
      .join('\n')}\n  );`;
  return `/// ${classDoc}
final class ${name} {
  /// Values of one mode; use [light] or [dark].
  const ${name}({${pick('light')
    .map((t) => `required this.${name_(t.path)}`)
    .join(', ')}});

${instance('light')}

${instance('dark')}

  /// The values of the nearest [${P}Theme]'s mode.
  static ${name} of(BuildContext context) => ${P}Theme.of(context).${field};

${fields.join('\n\n')}
}`;
}

export function buildDart() {
  return `// ${HEADER}
import 'package:flutter/widgets.dart';

import 'theme.dart';

${[...MODE_CLASSES.map(modeClass), ...groupNames(core).map(coreConstants)].join('\n\n')}
`;
}
