// @tsuya/core: the colour engine, the helpers that use the DOM, and the labels.
export * from './engine/index.ts';
export { accentFromImage } from './dom/image.ts';
export { clearAccent, fadeAccent, setAccent, setAmbient, shownAccent, type RegionPair } from './dom/material.ts';
export { themeScript } from './dom/theme.ts';
export { labelsEn, labelsFr, type TsuyaLabels } from './labels.ts';
