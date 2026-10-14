// The system strings of the components: components hold no text of their own, and the app passes one of
// these objects, or its own, once at the root. The Dart TsuyaLabels holds the same keys and strings.

/** Every system string a component may need. */
export interface TsuyaLabels {
  close: string;
  dismiss: string;
  loading: string;
  more: string;
  clear: string;
  search: string;
  noResults: string;
  copy: string;
  cut: string;
  paste: string;
  selectAll: string;
  showPassword: string;
  hidePassword: string;
  required: string;
  optional: string;
  selected: string;
  /** The number of options a search or a filter found, one or more: "4 results". */
  results: (count: number) => string;
}

export const labelsEn: TsuyaLabels = {
  close: 'Close',
  dismiss: 'Dismiss',
  loading: 'Loading',
  more: 'More',
  clear: 'Clear',
  search: 'Search',
  noResults: 'No results',
  copy: 'Copy',
  cut: 'Cut',
  paste: 'Paste',
  selectAll: 'Select all',
  showPassword: 'Show password',
  hidePassword: 'Hide password',
  required: 'Required',
  optional: 'Optional',
  selected: 'Selected',
  results: (count) => (count === 1 ? '1 result' : `${String(count)} results`),
};

export const labelsFr: TsuyaLabels = {
  close: 'Fermer',
  dismiss: 'Ignorer',
  loading: 'Chargement',
  more: 'Plus',
  clear: 'Effacer',
  search: 'Rechercher',
  noResults: 'Aucun résultat',
  copy: 'Copier',
  cut: 'Couper',
  paste: 'Coller',
  selectAll: 'Tout sélectionner',
  showPassword: 'Afficher le mot de passe',
  hidePassword: 'Masquer le mot de passe',
  required: 'Obligatoire',
  optional: 'Facultatif',
  selected: 'Sélectionné',
  results: (count) => (count === 1 ? '1 résultat' : `${String(count)} résultats`),
};
