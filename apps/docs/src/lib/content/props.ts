// The shape scripts/generate-props.mjs writes to apps/docs/.generated/props/*.json, read by PropsTable.svelte.
export interface PropRow {
  name: string;
  type: string;
  required: boolean;
  default: string;
  description: string;
}
