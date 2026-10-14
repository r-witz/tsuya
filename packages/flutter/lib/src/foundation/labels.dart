// Every system string tsuya's controls need (DESIGN.md, Labels): components hold no text of their own.
import 'package:flutter/widgets.dart';

/// One string per system label a tsuya control may need. Build a custom set for another language, or start from
/// [en] or [fr].
@immutable
class TsuyaLabels {
  /// A custom set of labels.
  const TsuyaLabels({
    required this.close,
    required this.dismiss,
    required this.loading,
    required this.more,
    required this.clear,
    required this.search,
    required this.noResults,
    required this.copy,
    required this.cut,
    required this.paste,
    required this.selectAll,
    required this.showPassword,
    required this.hidePassword,
    required this.required,
    required this.optional,
    required this.selected,
    required this.results,
  });

  /// English.
  static const en = TsuyaLabels(
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
    results: _resultsEn,
  );

  /// French.
  static const fr = TsuyaLabels(
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
    results: _resultsFr,
  );

  // the fallback TsuyaLabels.of returns in release when no provider is found: the field name itself, so missing
  // labels are visible in the UI instead of crashing
  static const _placeholder = TsuyaLabels(
    close: 'close',
    dismiss: 'dismiss',
    loading: 'loading',
    more: 'more',
    clear: 'clear',
    search: 'search',
    noResults: 'noResults',
    copy: 'copy',
    cut: 'cut',
    paste: 'paste',
    selectAll: 'selectAll',
    showPassword: 'showPassword',
    hidePassword: 'hidePassword',
    required: 'required',
    optional: 'optional',
    selected: 'selected',
    results: _resultsKey,
  );

  static String _resultsEn(int count) => count == 1 ? '1 result' : '$count results';

  static String _resultsFr(int count) => count == 1 ? '1 résultat' : '$count résultats';

  static String _resultsKey(int count) => 'results';

  /// "Close" an overlay or a sheet.
  final String close;

  /// "Dismiss" a banner or a toast without acting on it.
  final String dismiss;

  /// An in-progress state.
  final String loading;

  /// Opens a menu of actions that did not fit.
  final String more;

  /// Empties a field.
  final String clear;

  /// A search field or action.
  final String search;

  /// An empty search or filter result.
  final String noResults;

  /// The copy edit action.
  final String copy;

  /// The cut edit action.
  final String cut;

  /// The paste edit action.
  final String paste;

  /// The select-all edit action.
  final String selectAll;

  /// Reveals an obscured password field.
  final String showPassword;

  /// Obscures a revealed password field.
  final String hidePassword;

  /// Marks a required form field.
  final String required;

  /// Marks an optional form field.
  final String optional;

  /// Announces a selected item or option.
  final String selected;

  /// The number of options a search or a filter found, one or more: "4 results".
  final String Function(int count) results;

  /// [fr] for the French language, [en] for any other: what `TsuyaApp` uses with no `labels` of its own.
  static TsuyaLabels forLocale(Locale locale) => locale.languageCode == 'fr' ? fr : en;

  /// The labels of the nearest [TsuyaLabelsScope] (usually installed once by `TsuyaApp` or `TsuyaScope`). Without
  /// one, this throws a [FlutterError] in debug and profile builds; in release builds it returns labels whose
  /// values are their field names, so a missing provider is visible in the UI instead of crashing in production.
  static TsuyaLabels of(BuildContext context) {
    final labels = context.dependOnInheritedWidgetOfExactType<TsuyaLabelsScope>()?.labels;
    if (labels != null) return labels;
    assert(() {
      throw FlutterError(
        'No TsuyaLabels found.\n'
        'TsuyaLabels.of() was called with a context that has no TsuyaLabelsScope above it (TsuyaApp and '
        'TsuyaScope install one). Every tsuya control that needs a system string (Close, Loading, Copy…) reads '
        'it from the labels given once at the root: wrap the app in TsuyaApp(labels: TsuyaLabels.en, …) or '
        'TsuyaScope(labels: TsuyaLabels.en, …).',
      );
    }());
    return _placeholder;
  }
}

/// Provides [labels] to [TsuyaLabels.of] for this subtree; the nearest scope wins. `TsuyaApp` and `TsuyaScope`
/// install one at the root; nest another to override the labels (for example the language) of one region.
class TsuyaLabelsScope extends InheritedTheme {
  /// A scope carrying [labels].
  const TsuyaLabelsScope({super.key, required this.labels, required super.child});

  /// The labels this scope provides.
  final TsuyaLabels labels;

  @override
  Widget wrap(BuildContext context, Widget child) => TsuyaLabelsScope(labels: labels, child: child);

  @override
  bool updateShouldNotify(TsuyaLabelsScope oldWidget) => labels != oldWidget.labels;
}
