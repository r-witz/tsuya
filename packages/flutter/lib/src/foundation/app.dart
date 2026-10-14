// The app root: tsuya's theme, labels and page transitions (DESIGN.md, Theme and mode).
import 'package:flutter/widgets.dart';

import 'labels.dart';
import 'page_route.dart';
import 'theme.dart';
import 'tokens.g.dart';

/// Installs tsuya's theme and labels for an app that keeps its own `MaterialApp`, `CupertinoApp` or `WidgetsApp`:
/// put this in that app's `builder`. [TsuyaApp] uses it internally; use this instead when you need the other
/// app's own navigator, localizations or other features.
class TsuyaScope extends StatelessWidget {
  /// A scope around [child] with [labels] and the theme of [mode], [light], [dark] and [typeface].
  const TsuyaScope({
    super.key,
    this.mode,
    this.light,
    this.dark,
    this.typeface,
    required this.labels,
    required this.child,
  });

  /// The mode of the region, or null for the system's.
  final TsuyaMode? mode;

  /// The light mode's tokens, when the app changes them.
  final TsuyaThemeData? light;

  /// The dark mode's tokens, when the app changes them.
  final TsuyaThemeData? dark;

  /// The font family that replaces Inter in both modes.
  final String? typeface;

  /// Every system string tsuya's controls need.
  final TsuyaLabels labels;

  /// The app.
  final Widget child;

  @override
  Widget build(BuildContext context) => TsuyaTheme(
    mode: mode,
    light: light,
    dark: dark,
    typeface: typeface,
    child: TsuyaLabelsScope(labels: labels, child: child),
  );
}

/// A `WidgetsApp` with tsuya's theme and labels around every route, and pages that fade in over
/// [TsuyaDuration.base] (DESIGN.md, Theme and mode). Its `Navigator` and `Overlay` are what menus, dialogs and
/// sheets need; an app that keeps `MaterialApp`, `CupertinoApp` or another `WidgetsApp` uses [TsuyaScope] in its
/// `builder` instead.
///
/// A localized app passes [localizationsDelegates] and [supportedLocales] here, not in a `Localizations` around its
/// routes: dialogs, sheets and toasts live in the root `Overlay`, above the routes, and only see what is above the
/// `Navigator`. With no [labels], tsuya's own strings follow the resolved locale: [TsuyaLabels.fr] for French,
/// [TsuyaLabels.en] otherwise; pass [labels] for any other language.
class TsuyaApp extends StatelessWidget {
  /// An app showing [home], or routing through [routes] or [onGenerateRoute].
  const TsuyaApp({
    super.key,
    this.title = '',
    this.onGenerateTitle,
    this.mode,
    this.light,
    this.dark,
    this.typeface,
    this.labels,
    this.home,
    this.routes = const <String, WidgetBuilder>{},
    this.initialRoute,
    this.onGenerateRoute,
    this.onGenerateInitialRoutes,
    this.onUnknownRoute,
    this.navigatorObservers = const <NavigatorObserver>[],
    this.navigatorKey,
    this.builder,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.restorationScopeId,
    this.shortcuts,
    this.actions,
    this.debugShowCheckedModeBanner = true,
  }) : routerConfig = null,
       routeInformationParser = null,
       routerDelegate = null,
       routeInformationProvider = null,
       backButtonDispatcher = null;

  /// An app driven by a `Router`: give a [routerConfig], or a [routerDelegate] with the other router parts.
  const TsuyaApp.router({
    super.key,
    this.title = '',
    this.onGenerateTitle,
    this.mode,
    this.light,
    this.dark,
    this.typeface,
    this.labels,
    this.routerConfig,
    this.routeInformationParser,
    this.routerDelegate,
    this.routeInformationProvider,
    this.backButtonDispatcher,
    this.builder,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.restorationScopeId,
    this.shortcuts,
    this.actions,
    this.debugShowCheckedModeBanner = true,
  }) : home = null,
       routes = const <String, WidgetBuilder>{},
       initialRoute = null,
       onGenerateRoute = null,
       onGenerateInitialRoutes = null,
       onUnknownRoute = null,
       navigatorObservers = const <NavigatorObserver>[],
       navigatorKey = null;

  /// The task switcher's title.
  final String title;

  /// The task switcher's title built from the app's localizations, which wins over [title].
  final GenerateAppTitle? onGenerateTitle;

  /// The mode of the app, or null for the system's.
  final TsuyaMode? mode;

  /// The light mode's tokens, when the app changes them.
  final TsuyaThemeData? light;

  /// The dark mode's tokens, when the app changes them.
  final TsuyaThemeData? dark;

  /// The font family that replaces Inter in both modes.
  final String? typeface;

  /// Every system string tsuya's controls need, or null to follow the resolved locale ([TsuyaLabels.forLocale]).
  final TsuyaLabels? labels;

  /// The widget for the initial route, when not using [routes] or [onGenerateRoute].
  final Widget? home;

  /// The app's named routes.
  final Map<String, WidgetBuilder> routes;

  /// The name of the first route, instead of `/`.
  final String? initialRoute;

  /// Builds a route for a name not found in [routes].
  final RouteFactory? onGenerateRoute;

  /// Builds the routes pushed at start, from the initial route's name.
  final InitialRouteListFactory? onGenerateInitialRoutes;

  /// Builds a route when neither [routes] nor [onGenerateRoute] knows a name.
  final RouteFactory? onUnknownRoute;

  /// Told of every push, pop and replace of the app's [Navigator].
  final List<NavigatorObserver> navigatorObservers;

  /// The app's [Navigator], for apps that need to reach it from outside the widget tree.
  final GlobalKey<NavigatorState>? navigatorKey;

  /// Wraps the [Navigator] or `Router`, inside tsuya's theme and the app's localizations (its `context` reaches both).
  final TransitionBuilder? builder;

  /// Forces the app's locale; the system's otherwise.
  final Locale? locale;

  /// The delegates of the app's own localizations (`AppLocalizations.delegates`).
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;

  /// Picks the locale from the system's whole list of preferred locales.
  final LocaleListResolutionCallback? localeListResolutionCallback;

  /// Picks the locale from the system's first preferred locale.
  final LocaleResolutionCallback? localeResolutionCallback;

  /// The locales the app has strings for (`AppLocalizations.supportedLocales`).
  final Iterable<Locale> supportedLocales;

  /// Makes the app's navigation state restorable, under this id.
  final String? restorationScopeId;

  /// The app's keyboard shortcuts, over the default ones.
  final Map<ShortcutActivator, Intent>? shortcuts;

  /// The app's actions, over the default ones.
  final Map<Type, Action<Intent>>? actions;

  /// Whether a debug build shows the "DEBUG" banner.
  final bool debugShowCheckedModeBanner;

  /// The router's configuration, for an app made with [TsuyaApp.router].
  final RouterConfig<Object>? routerConfig;

  /// Turns the route information into a configuration, for [TsuyaApp.router].
  final RouteInformationParser<Object>? routeInformationParser;

  /// Builds the pages from the configuration, for [TsuyaApp.router].
  final RouterDelegate<Object>? routerDelegate;

  /// Reports the platform's route information, for [TsuyaApp.router].
  final RouteInformationProvider? routeInformationProvider;

  /// Handles the system's back button, for [TsuyaApp.router].
  final BackButtonDispatcher? backButtonDispatcher;

  Widget _scope(BuildContext context, Widget? child) => TsuyaScope(
    mode: mode,
    light: light,
    dark: dark,
    typeface: typeface,
    labels: labels ?? TsuyaLabels.forLocale(Localizations.localeOf(context)),
    child: builder == null ? child ?? const SizedBox.shrink() : Builder(builder: (context) => builder!(context, child)),
  );

  @override
  Widget build(BuildContext context) {
    final color = TsuyaColors.light.accent;
    if (routerDelegate != null || routerConfig != null) {
      return WidgetsApp.router(
        title: title,
        onGenerateTitle: onGenerateTitle,
        color: color,
        locale: locale,
        localizationsDelegates: localizationsDelegates,
        localeListResolutionCallback: localeListResolutionCallback,
        localeResolutionCallback: localeResolutionCallback,
        supportedLocales: supportedLocales,
        restorationScopeId: restorationScopeId,
        shortcuts: shortcuts,
        actions: actions,
        debugShowCheckedModeBanner: debugShowCheckedModeBanner,
        routerConfig: routerConfig,
        routeInformationParser: routeInformationParser,
        routerDelegate: routerDelegate,
        routeInformationProvider: routeInformationProvider,
        backButtonDispatcher: backButtonDispatcher,
        builder: _scope,
      );
    }
    return WidgetsApp(
      title: title,
      onGenerateTitle: onGenerateTitle,
      color: color,
      locale: locale,
      localizationsDelegates: localizationsDelegates,
      localeListResolutionCallback: localeListResolutionCallback,
      localeResolutionCallback: localeResolutionCallback,
      supportedLocales: supportedLocales,
      restorationScopeId: restorationScopeId,
      shortcuts: shortcuts,
      actions: actions,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      home: home,
      routes: routes,
      initialRoute: initialRoute,
      onGenerateRoute: onGenerateRoute,
      onGenerateInitialRoutes: onGenerateInitialRoutes,
      onUnknownRoute: onUnknownRoute,
      navigatorObservers: navigatorObservers,
      navigatorKey: navigatorKey,
      builder: _scope,
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) =>
          TsuyaPageRoute<T>(settings: settings, builder: builder),
    );
  }
}
