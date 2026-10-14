// TsuyaApp and TsuyaScope (DESIGN.md, Theme and mode). TsuyaScope under a MaterialApp builder is the one
// place this package's tests may import Material (spec: "tests may import Material where they check TsuyaScope
// under a MaterialApp").

import 'dart:async';

import 'package:flutter/material.dart' show MaterialApp;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

class _Observer extends NavigatorObserver {
  final pushed = <String?>[];
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => pushed.add(route.settings.name);
}

class _Parser extends RouteInformationParser<String> {
  @override
  Future<String> parseRouteInformation(RouteInformation information) async => information.uri.path;
}

class _Delegate extends RouterDelegate<String> with ChangeNotifier {
  String path = '/';
  @override
  String get currentConfiguration => path;
  @override
  Future<void> setNewRoutePath(String configuration) async => path = configuration;
  @override
  Future<bool> popRoute() async => false;
  @override
  Widget build(BuildContext context) => Text('page $path', textDirection: TextDirection.ltr);
}

String _close(WidgetTester tester) => TsuyaLabels.of(tester.element(find.byType(SizedBox))).close;

class _Strings {
  const _Strings(this.hello);
  final String hello;
  static _Strings of(BuildContext context) => Localizations.of<_Strings>(context, _Strings)!;
}

class _StringsDelegate extends LocalizationsDelegate<_Strings> {
  const _StringsDelegate();
  @override
  bool isSupported(Locale locale) => true;
  @override
  Future<_Strings> load(Locale locale) async => _Strings('hello ${locale.languageCode}');
  @override
  bool shouldReload(_StringsDelegate old) => false;
}

Widget _opener() => Builder(
  builder: (context) => Button(
    label: 'Open',
    onPressed: () => Dialog.show<void>(context, builder: (context) => Text(_Strings.of(context).hello)),
  ),
);

void main() {
  testWidgets('TsuyaApp puts the mode, Inter and labels around its routes', (tester) async {
    late TextStyle style;
    late TsuyaLabels labels;
    await tester.pumpWidget(
      TsuyaApp(
        mode: TsuyaMode.dark,
        labels: TsuyaLabels.fr,
        home: Builder(
          builder: (context) {
            style = DefaultTextStyle.of(context).style;
            labels = TsuyaLabels.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(style.fontFamily, 'packages/tsuya/Inter');
    expect(style.color, TsuyaColors.dark.text);
    expect(labels.close, 'Fermer');
  });

  testWidgets('a pushed page fades in over TsuyaDuration.base', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      TsuyaApp(
        navigatorKey: navigatorKey,
        labels: TsuyaLabels.en,
        home: const Text('Home'),
        routes: {'/next': (context) => const Text('Next')},
      ),
    );
    unawaited(navigatorKey.currentState!.pushNamed('/next'));
    await tester.pump();
    await tester.pump(TsuyaDuration.base ~/ 2);
    final fade = tester.widget<FadeTransition>(
      find.ancestor(of: find.text('Next'), matching: find.byType(FadeTransition)).first,
    );
    expect(fade.opacity.value, greaterThan(0));
    expect(fade.opacity.value, lessThan(1));
    await tester.pumpAndSettle();
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('TsuyaScope installs the theme and labels inside a MaterialApp builder', (tester) async {
    late Color accent;
    late TsuyaLabels labels;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => TsuyaScope(mode: TsuyaMode.dark, labels: TsuyaLabels.fr, child: child!),
        home: Builder(
          builder: (context) {
            accent = Accent.of(context);
            labels = TsuyaLabels.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(accent, TsuyaColors.dark.accent);
    expect(labels.close, 'Fermer');
  });

  // What TsuyaApp passes through to its WidgetsApp, and its router constructor.
  testWidgets('navigatorObservers see the initial route and a push', (tester) async {
    final observer = _Observer();
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      TsuyaApp(
        navigatorKey: key,
        navigatorObservers: [observer],
        labels: TsuyaLabels.en,
        routes: {'/': (_) => const Text('Home'), '/next': (_) => const Text('Next')},
      ),
    );
    unawaited(key.currentState!.pushNamed('/next'));
    await tester.pumpAndSettle();
    expect(observer.pushed, ['/', '/next']);
  });

  testWidgets('initialRoute picks the first route', (tester) async {
    await tester.pumpWidget(
      TsuyaApp(
        initialRoute: '/two',
        labels: TsuyaLabels.en,
        routes: {'/': (_) => const Text('One'), '/two': (_) => const Text('Two')},
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Two'), findsOneWidget);
  });

  testWidgets('onUnknownRoute builds a route no other factory knows', (tester) async {
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      TsuyaApp(
        navigatorKey: key,
        labels: TsuyaLabels.en,
        routes: {'/': (_) => const Text('Home')},
        onUnknownRoute: (settings) =>
            TsuyaPageRoute<void>(settings: settings, builder: (_) => Text('Unknown ${settings.name}')),
      ),
    );
    unawaited(key.currentState!.pushNamed('/missing'));
    await tester.pumpAndSettle();
    expect(find.text('Unknown /missing'), findsOneWidget);
  });

  testWidgets("builder wraps the navigator inside tsuya's theme", (tester) async {
    late TsuyaLabels labels;
    await tester.pumpWidget(
      TsuyaApp(
        labels: TsuyaLabels.fr,
        home: const Text('Home'),
        builder: (context, child) {
          labels = TsuyaLabels.of(context);
          return Column(
            children: [
              const Text('Above'),
              Expanded(child: child!),
            ],
          );
        },
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Above'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(labels.close, 'Fermer');
  });

  testWidgets('without labels, they follow the locale: French for fr, English otherwise', (tester) async {
    Future<void> pump(Locale locale) =>
        tester.pumpWidget(TsuyaApp(locale: locale, supportedLocales: [locale], home: const SizedBox()));
    await pump(const Locale('fr'));
    expect(_close(tester), 'Fermer');
    await pump(const Locale('de'));
    expect(_close(tester), 'Close');
  });

  testWidgets("TsuyaApp.router shows the router delegate's page inside the scope", (tester) async {
    await tester.pumpWidget(
      TsuyaApp.router(
        labels: TsuyaLabels.fr,
        routerConfig: RouterConfig<String>(
          routeInformationProvider: PlatformRouteInformationProvider(
            initialRouteInformation: RouteInformation(uri: Uri.parse('/inbox')),
          ),
          routeInformationParser: _Parser(),
          routerDelegate: _Delegate(),
        ),
        builder: (context, child) => Column(
          children: [
            Text(TsuyaLabels.of(context).close),
            Expanded(child: child!),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('page /inbox'), findsOneWidget);
    expect(find.text('Fermer'), findsOneWidget);
  });

  testWidgets('TsuyaApp.router takes a delegate with a parser', (tester) async {
    await tester.pumpWidget(
      TsuyaApp.router(labels: TsuyaLabels.en, routeInformationParser: _Parser(), routerDelegate: _Delegate()),
    );
    await tester.pumpAndSettle();
    expect(find.text('page /'), findsOneWidget);
  });

  testWidgets('TsuyaPageRoute fades in a page of a plain WidgetsApp', (tester) async {
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      WidgetsApp(
        color: const Color(0xFF000000),
        navigatorKey: key,
        home: const Text('Home'),
        pageRouteBuilder: <T>(settings, builder) => TsuyaPageRoute<T>(settings: settings, builder: builder),
        routes: {'/next': (_) => const Text('Next')},
      ),
    );
    unawaited(key.currentState!.pushNamed('/next'));
    await tester.pump();
    await tester.pump(TsuyaDuration.base ~/ 2);
    final fade = tester.widget<FadeTransition>(
      find.ancestor(of: find.text('Next'), matching: find.byType(FadeTransition)).first,
    );
    expect(fade.opacity.value, inExclusiveRange(0, 1));
    await tester.pumpAndSettle();
  });

  // TsuyaApp for a localized app: the root overlay, where dialogs, sheets and toasts live, sits inside the app's
  // `Localizations`.
  testWidgets('a dialog reads the app localizations when the app passes its delegates', (tester) async {
    await tester.pumpWidget(
      TsuyaApp(
        labels: TsuyaLabels.fr,
        locale: const Locale('fr'),
        supportedLocales: const [Locale('fr')],
        localizationsDelegates: const [_StringsDelegate()],
        home: _opener(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('hello fr'), findsOneWidget);
  });
}
