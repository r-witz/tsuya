# tsuya for Flutter

The tsuya design system on the widgets layer: no Material, no Cupertino. Tokens, the material (accent, ambient, glass,
grain) and the components, in light and dark. Early: the API may still change before 1.0.

[`DESIGN.md`](DESIGN.md), next to this file, is the contract: the rules, the material, every component's spec and the
tokens. Read it before building a screen.

## Install

Until the package is published, depend on it by git:

```yaml
dependencies:
  tsuya:
    git:
      url: https://github.com/r-witz/tsuya.git
      path: packages/flutter
```

Once it is published: `flutter pub add tsuya`. It needs Flutter 3.44 or later and bundles Inter and Geist Mono.

## Quick start

```dart
import 'package:flutter/widgets.dart';
import 'package:tsuya/tsuya.dart';

void quickStart() => runApp(
  const TsuyaApp(title: 'My app', labels: TsuyaLabels.en, home: Center(child: Text('Hello'))),
);
```

`TsuyaApp` is a `WidgetsApp` with tsuya's theme, labels and page fade around every route. It follows the system's light
or dark mode (`mode:` forces one) and takes the usual `WidgetsApp` parameters: `routes`, `initialRoute`,
`onGenerateRoute`, `onUnknownRoute`, `navigatorObservers`, `navigatorKey`, `restorationScopeId`, `builder`,
`shortcuts`, `actions` and the locale ones below.

`TsuyaApp.router` is the same for an app driven by a `Router`:

```dart
TsuyaApp.router(routerConfig: router)
```

An app that must keep `MaterialApp`, `CupertinoApp` or its own `WidgetsApp` puts `TsuyaScope(labels: …, child: child!)`
in that app's `builder` instead. Use `TsuyaPageRoute` as its `pageRouteBuilder` (or in a router package's page builder)
for tsuya's fade.

### A localized app

Pass the app's localizations to `TsuyaApp`, not to a `Localizations` around your routes: dialogs, sheets and toasts
live in the root overlay, above the routes, and only see what is above the `Navigator`.

```dart
TsuyaApp(
  title: 'My app',
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: const Center(child: Text('Bonjour')),
)
```

`AppLocalizations` is what `flutter gen-l10n` generates. `localeResolutionCallback` and
`localeListResolutionCallback` are there too.

tsuya's own strings (Close, Loading, Copy…) are `TsuyaLabels`. With no `labels`, they follow the resolved locale:
`TsuyaLabels.fr` for French, `TsuyaLabels.en` for any other language. For another language, build a `TsuyaLabels` with
your strings and pass it when the locale needs it:

```dart
TsuyaApp(
  locale: locale,
  labels: locale.languageCode == 'de' ? germanLabels : null,
  home: const SizedBox(),
)
```

## A screen with tabs

`Screen` is the phone shell: scrolling content padded for the safe areas and the dock, and a `TabBar` floating over it.

```dart
Screen(
  builder: (context, padding) => ListView(
    padding: padding,
    children: [PageHeader(title: _tab.name)],
  ),
  dock: TabBar<Tab>(
    current: _tab,
    onSelect: (tab) => setState(() => _tab = tab),
    items: const [
      TabBarItem(value: Tab.inbox, label: 'Inbox', icon: Glyph(TsuyaGlyph.menu)),
      TabBarItem(value: Tab.settings, label: 'Settings', icon: Glyph(TsuyaGlyph.info)),
    ],
  ),
)
```

## The accent from an image

An `Accent` region takes its colour from the content that leads the screen. `accentFromImage` computes the pair for
both modes, off the UI thread; `Screen.ambient` lights the top with the same image. Compute it once per image and keep
it (`pair.seed` is the value to store with the content).

```dart
accentFromImage(widget.image).then((pair) {
  if (mounted) setState(() => _accent = pair);
});
```

```dart
Accent(
  pair: _accent,
  child: Screen(
    ambient: widget.image,
    builder: (context, padding) => ListView(padding: padding),
  ),
)
```

## Dialogs, sheets and toasts

They are shown, not placed in the tree: `Dialog.show`, `Sheet.show` and `Toast.show` take a `BuildContext` under
`TsuyaApp` and draw in the root overlay. Close a dialog or a sheet with `Dialog.close(context, result)` and
`Sheet.close(context, result)`, not with `Navigator.pop`: they are not routes.

```dart
final confirmed = await Dialog.show<bool>(
  context,
  builder: (context) => Dialog(
    title: 'Delete photo?',
    body: 'This cannot be undone.',
    actions: [
      Button(label: 'Cancel', kind: ButtonKind.ghost, onPressed: () => Dialog.close(context, false)),
      Button(label: 'Delete', kind: ButtonKind.danger, onPressed: () => Dialog.close(context, true)),
    ],
  ),
);
if (confirmed == true && context.mounted) Toast.show(context, message: 'Photo deleted');
```

```dart
Sheet.show<void>(
  context,
  builder: (context) => const Sheet(label: 'Filters', child: Text('Filters go here')),
)
```

## Icons

tsuya ships no icon set. Bring your own (an icon font, SVGs): `TabBarItem.icon`, `IconButton.icon` and the like take
any widget. `Glyph` and `TsuyaGlyph` are the few shapes tsuya draws inside its own controls (a check, a chevron,
a close cross…), available to you, not a library.

## Names that clash

Components keep plain names (`Button`, `Switch`). Two of them are also widgets of `package:flutter/widgets.dart`,
which every app imports: `RadioGroup` and `Banner`. Many more are in Material (`Switch`, `Slider`, `Tooltip`,
`Dialog`, `Chip`, `Checkbox`, `Radio`, `Badge`, `TextField`, `IconButton`…). Where a file uses one of them, import
tsuya with a prefix, or hide the SDK's:

```dart
import 'package:flutter/widgets.dart' hide Banner, RadioGroup;
import 'package:tsuya/tsuya.dart';
```

Or, next to Material:

```dart
import 'package:flutter/material.dart';
import 'package:tsuya/tsuya.dart' as t;
```

## Example

[`example/`](example) is a small app: `TsuyaApp`, a tab bar, a list, a dialog, a toast and an accent from a generated
image. The snippets above are compiled in `example/lib/readme/`, and a test checks they still match this file.

## AI agents

`dart run tsuya:init`, in a project that depends on `tsuya`, copies `DESIGN.md` into the project and adds a line to
`AGENTS.md` and `CLAUDE.md` (made when missing) that tells the project's agents to read and follow it. It leaves a
`DESIGN.md` of the project's own alone. Run it again after an upgrade to refresh the copy; the line is written once.
