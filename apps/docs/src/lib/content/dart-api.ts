// The shape of scripts/dart_api's output, apps/docs/src/lib/generated/dart-api/<Name>.json (committed), and its
// lookup, for DartApi.svelte (the live tables).
export interface DartParam {
  name: string;
  type: string;
  required: boolean;
  named: boolean;
  default: string;
  description: string;
}

export interface DartConstructor {
  /** '' is the default constructor; otherwise the name after the dot (`Badge.count`). */
  name: string;
  description: string;
  params: DartParam[];
}

export interface DartStatic {
  name: string;
  signature: string;
  description: string;
}

export interface DartEnumValue {
  name: string;
  description: string;
}

export interface DartType {
  kind: 'class' | 'enum';
  description: string;
  constructors?: DartConstructor[];
  statics?: DartStatic[];
  values?: DartEnumValue[];
}

const files = import.meta.glob<DartType>('../generated/dart-api/*.json', { eager: true, import: 'default' });

/** One public Flutter type by name; throws on an unknown name so a page cannot list a type that does not exist. */
export function dartType(name: string): DartType {
  const type = files[`../generated/dart-api/${name}.json`];
  if (!type) throw new Error(`no Dart API file for ${name}`);
  return type;
}

/** "Badge" or "Badge.count": how a constructor is called. */
export const constructorLabel = (type: string, ctor: DartConstructor): string =>
  ctor.name ? `${type}.${ctor.name}` : type;
