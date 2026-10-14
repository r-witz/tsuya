// The README's localized-app snippets, compiled here so they cannot rot (see test/readme_test.dart).
import 'package:flutter/widgets.dart';
import 'package:tsuya/tsuya.dart';

import 'l10n_stub.dart';

Widget localizedApp() => TsuyaApp(
  title: 'My app',
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: const Center(child: Text('Bonjour')),
);

Widget routerApp(RouterConfig<Object> router) => TsuyaApp.router(routerConfig: router);

Widget ownLabels(Locale locale) =>
    TsuyaApp(locale: locale, labels: locale.languageCode == 'de' ? germanLabels : null, home: const SizedBox());

const germanLabels = TsuyaLabels.en;
