// Every system string, in English and French, and the provider that carries them (DESIGN.md, Labels).
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

void main() {
  test('English labels match DESIGN.md exactly', () {
    const en = TsuyaLabels.en;
    expect(en.close, 'Close');
    expect(en.dismiss, 'Dismiss');
    expect(en.loading, 'Loading');
    expect(en.more, 'More');
    expect(en.clear, 'Clear');
    expect(en.search, 'Search');
    expect(en.noResults, 'No results');
    expect(en.copy, 'Copy');
    expect(en.cut, 'Cut');
    expect(en.paste, 'Paste');
    expect(en.selectAll, 'Select all');
    expect(en.showPassword, 'Show password');
    expect(en.hidePassword, 'Hide password');
    expect(en.required, 'Required');
    expect(en.optional, 'Optional');
    expect(en.selected, 'Selected');
    expect(en.results(1), '1 result');
    expect(en.results(4), '4 results');
  });

  test('French labels match DESIGN.md exactly', () {
    const fr = TsuyaLabels.fr;
    expect(fr.close, 'Fermer');
    expect(fr.dismiss, 'Ignorer');
    expect(fr.loading, 'Chargement');
    expect(fr.more, 'Plus');
    expect(fr.clear, 'Effacer');
    expect(fr.search, 'Rechercher');
    expect(fr.noResults, 'Aucun résultat');
    expect(fr.copy, 'Copier');
    expect(fr.cut, 'Couper');
    expect(fr.paste, 'Coller');
    expect(fr.selectAll, 'Tout sélectionner');
    expect(fr.showPassword, 'Afficher le mot de passe');
    expect(fr.hidePassword, 'Masquer le mot de passe');
    expect(fr.required, 'Obligatoire');
    expect(fr.optional, 'Facultatif');
    expect(fr.selected, 'Sélectionné');
    expect(fr.results(1), '1 résultat');
    expect(fr.results(4), '4 résultats');
  });

  testWidgets('TsuyaLabels.of reads the nearest TsuyaLabelsScope', (tester) async {
    late TsuyaLabels labels;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) {
            labels = TsuyaLabels.of(context);
            return const SizedBox();
          },
        ),
        labels: TsuyaLabels.fr,
      ),
    );
    expect(labels.close, 'Fermer');
  });

  testWidgets('a nested scope overrides the labels for its subtree only', (tester) async {
    late TsuyaLabels outer;
    late TsuyaLabels inner;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) {
            outer = TsuyaLabels.of(context);
            return TsuyaLabelsScope(
              labels: TsuyaLabels.fr,
              child: Builder(
                builder: (context) {
                  inner = TsuyaLabels.of(context);
                  return const SizedBox();
                },
              ),
            );
          },
        ),
      ),
    );
    expect(outer.close, 'Close');
    expect(inner.close, 'Fermer');
  });

  testWidgets('without a provider, TsuyaLabels.of throws a FlutterError in debug mode', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (c) {
              context = c;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(() => TsuyaLabels.of(context), throwsFlutterError);
  });
}
