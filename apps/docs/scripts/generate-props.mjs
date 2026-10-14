// Generates the props table of each component page from the built @tsuya/svelte declarations: the
// TypeScript compiler API reads packages/svelte/dist/index.d.ts, resolves each export's Props type, and lists its
// own members (an inherited HTML attribute, such as `onmousedown` or `style`, is told apart by its declaration
// sitting outside packages/svelte/dist). Name, type and required/optional come from the type; the description and a
// stated default come from the property's JSDoc ("Default 'md'."). Run by `npm run build` and `npm run dev` of this
// app; the output is not committed.
import { mkdirSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

import ts from 'typescript';

const ROOT = fileURLToPath(new URL('../../../', import.meta.url));
const ENTRY = `${ROOT}packages/svelte/dist/index.d.ts`;
const DIST = `${ROOT}packages/svelte/dist/`;
const OUT_DIR = fileURLToPath(new URL('../.generated/props/', import.meta.url));

// out: the JSON file name; export: the dotted path into @tsuya/svelte's exports ("Menu.Item" reads the `Item`
// property of the `Menu` export, itself an object of components).
const TARGETS = [
  { out: 'button', export: 'Button' },
  { out: 'text-input', export: 'TextInput' },
  { out: 'textarea', export: 'Textarea' },
  { out: 'search-input', export: 'SearchInput' },
  { out: 'field', export: 'Field' },
  { out: 'icon-button', export: 'IconButton' },
  { out: 'checkbox', export: 'Checkbox' },
  { out: 'radio-group', export: 'RadioGroup' },
  { out: 'radio', export: 'Radio' },
  { out: 'segmented-control', export: 'SegmentedControl' },
  { out: 'slider', export: 'Slider' },
  { out: 'select', export: 'Select' },
  { out: 'select-root', export: 'Select.Root' },
  { out: 'select-trigger', export: 'Select.Trigger' },
  { out: 'select-content', export: 'Select.Content' },
  { out: 'select-item', export: 'Select.Item' },
  { out: 'select-group', export: 'Select.Group' },
  { out: 'combobox', export: 'Combobox' },
  { out: 'chip', export: 'Chip' },
  { out: 'chip-group', export: 'ChipGroup' },
  { out: 'spinner', export: 'Spinner' },
  { out: 'tooltip', export: 'Tooltip' },
  { out: 'popover-root', export: 'Popover.Root' },
  { out: 'popover-trigger', export: 'Popover.Trigger' },
  { out: 'popover-content', export: 'Popover.Content' },
  { out: 'switch', export: 'Switch' },
  { out: 'menu-root', export: 'Menu.Root' },
  { out: 'menu-trigger', export: 'Menu.Trigger' },
  { out: 'menu-content', export: 'Menu.Content' },
  { out: 'menu-item', export: 'Menu.Item' },
  { out: 'menu-checkbox-item', export: 'Menu.CheckboxItem' },
  { out: 'menu-radio-group', export: 'Menu.RadioGroup' },
  { out: 'menu-radio-item', export: 'Menu.RadioItem' },
  { out: 'avatar', export: 'Avatar' },
  { out: 'badge', export: 'Badge' },
  { out: 'banner', export: 'Banner' },
  { out: 'list', export: 'List' },
  { out: 'list-item', export: 'ListItem' },
  { out: 'section', export: 'Section' },
  { out: 'page-header', export: 'PageHeader' },
  { out: 'section-header', export: 'SectionHeader' },
  { out: 'thumbnail', export: 'Thumbnail' },
  { out: 'progress', export: 'Progress' },
  { out: 'skeleton', export: 'Skeleton' },
  { out: 'skeleton-text', export: 'Skeleton.Text' },
  { out: 'tabs-root', export: 'Tabs.Root' },
  { out: 'tabs-list', export: 'Tabs.List' },
  { out: 'tabs-trigger', export: 'Tabs.Trigger' },
  { out: 'tabs-content', export: 'Tabs.Content' },
  { out: 'accordion-root', export: 'Accordion.Root' },
  { out: 'accordion-item', export: 'Accordion.Item' },
  { out: 'accordion-trigger', export: 'Accordion.Trigger' },
  { out: 'accordion-content', export: 'Accordion.Content' },
  { out: 'top-bar', export: 'TopBar' },
  { out: 'screen-bar', export: 'ScreenBar' },
  { out: 'tab-bar', export: 'TabBar' },
  { out: 'screen', export: 'Screen' },
  { out: 'sidebar', export: 'Sidebar' },
  { out: 'sidebar-group', export: 'SidebarGroup' },
  { out: 'sidebar-item', export: 'SidebarItem' },
  { out: 'dialog-root', export: 'Dialog.Root' },
  { out: 'dialog-trigger', export: 'Dialog.Trigger' },
  { out: 'dialog-content', export: 'Dialog.Content' },
  { out: 'dialog-title', export: 'Dialog.Title' },
  { out: 'dialog-description', export: 'Dialog.Description' },
  { out: 'dialog-actions', export: 'Dialog.Actions' },
  { out: 'dialog-close', export: 'Dialog.Close' },
  { out: 'sheet-root', export: 'Sheet.Root' },
  { out: 'sheet-content', export: 'Sheet.Content' },
  { out: 'sheet-title', export: 'Sheet.Title' },
  { out: 'command-palette', export: 'CommandPalette' },
  { out: 'toast-options', type: 'ToastOptions' },
  { out: 'toast-action', type: 'ToastAction' },
];

const options = {
  moduleResolution: ts.ModuleResolutionKind.Bundler,
  module: ts.ModuleKind.ESNext,
  target: ts.ScriptTarget.ES2022,
  strict: true,
  allowImportingTsExtensions: true,
  noEmit: true,
};

const program = ts.createProgram([ENTRY], options);
const checker = program.getTypeChecker();
const source = program.getSourceFile(ENTRY);
if (!source) throw new Error(`cannot read ${ENTRY}; run npm run build -w @tsuya/svelte first.`);
const moduleSymbol = checker.getSymbolAtLocation(source);
if (!moduleSymbol) throw new Error(`${ENTRY} is not a module`);
const moduleExports = checker.getExportsOfModule(moduleSymbol);

function resolveExport(path) {
  const parts = path.split('.');
  const root = moduleExports.find((e) => e.getName() === parts[0]);
  if (!root) throw new Error(`@tsuya/svelte has no export named ${parts[0]}`);
  let type = checker.getTypeOfSymbolAtLocation(root, root.valueDeclaration ?? source);
  for (const part of parts.slice(1)) {
    const prop = checker.getPropertyOfType(type, part);
    if (!prop) throw new Error(`${path}: no property ${part}`);
    type = checker.getTypeOfSymbolAtLocation(prop, prop.valueDeclaration ?? source);
  }
  return type;
}

// "Default 'md'." or "Default true." in the doc comment, kept out of the shown description.
const DEFAULT_RE = /\s*Default ([^.]+)\.\s*/;

// A function type keeps the parens a union needed ("(() => void) | undefined"): drop them once undefined is gone,
// but only when they wrap the whole string as a single matching pair.
function stripOuterParens(text) {
  if (text[0] !== '(' || !text.endsWith(')')) return text;
  let depth = 0;
  for (let i = 0; i < text.length; i++) {
    if (text[i] === '(') depth++;
    else if (text[i] === ')') {
      depth--;
      if (depth === 0) return i === text.length - 1 ? text.slice(1, -1) : text;
    }
  }
  return text;
}

function cleanType(text) {
  return stripOuterParens(
    text
      .replace(/ \| undefined$/, '')
      .replace(/undefined \| /, '')
      .replace(/Snippet<\[\]>/g, 'Snippet'),
  );
}

/** The component's own props: name, type, required, default and description, in declaration order. */
function propsOf(exportPath) {
  const resolved = resolveExport(exportPath);
  // Skeleton is a component with Skeleton.Text attached: an intersection, whose first member is the component
  const type = resolved.isIntersection()
    ? (resolved.types.find((t) => checker.getTypeArguments(t).length) ?? resolved)
    : resolved;
  // a generic component (Select, Combobox) is not a Component<Props, …>: its props are the second parameter of its
  // call signature, with the type parameter left as it is
  const call = type.getCallSignatures()[0];
  const callProps = call?.getParameters()[1];
  const args = checker.getTypeArguments(type);
  const propsType =
    args?.[0] ??
    (callProps ? checker.getTypeOfSymbolAtLocation(callProps, callProps.valueDeclaration ?? source) : undefined);
  if (!propsType) throw new Error(`${exportPath}: not a Component<Props, …> type (${checker.typeToString(type)})`);
  return rowsOf(propsType);
}

/** The members of an exported interface (type: 'ToastOptions'), for what is not a component, such as `toast()`'s options. */
function membersOf(typeName) {
  const root = moduleExports.find((e) => e.getName() === typeName);
  if (!root) throw new Error(`@tsuya/svelte has no export named ${typeName}`);
  return rowsOf(checker.getDeclaredTypeOfSymbol(root));
}

function rowsOf(propsType) {
  const rows = [];
  for (const prop of checker.getPropertiesOfType(propsType)) {
    const decl = prop.declarations?.[0];
    if (!decl || !decl.getSourceFile().fileName.startsWith(DIST)) continue; // an inherited HTML attribute
    const propType = checker.getTypeOfSymbolAtLocation(prop, decl);
    const doc = ts.displayPartsToString(prop.getDocumentationComment(checker));
    const defaultMatch = DEFAULT_RE.exec(doc);
    rows.push({
      name: prop.getName(),
      type: cleanType(checker.typeToString(propType, decl, ts.TypeFormatFlags.NoTruncation)),
      required: (prop.flags & ts.SymbolFlags.Optional) === 0,
      default: defaultMatch?.[1] ?? '',
      description: doc.replace(DEFAULT_RE, ' ').trim(),
    });
  }
  return rows;
}

mkdirSync(OUT_DIR, { recursive: true });
for (const { out, export: exportPath, type } of TARGETS) {
  writeFileSync(`${OUT_DIR}${out}.json`, JSON.stringify(type ? membersOf(type) : propsOf(exportPath), null, 2) + '\n');
  console.log(`✓ ${out}.json (${exportPath ?? type})`);
}
