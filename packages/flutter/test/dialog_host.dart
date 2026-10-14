// A dialog opened from a button, for the Dialog tests.
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

bool? dialogResult;

Widget dialogApp({
  bool dismissible = true,
  bool alert = false,
  DialogSize size = DialogSize.md,
  String? barrierLabel,
  Widget? content,
  String body = 'This cannot be undone.',
  TsuyaMode mode = TsuyaMode.light,
  TextDirection direction = TextDirection.ltr,
  double textScale = 1,
  bool animate = false,
  EdgeInsets viewInsets = EdgeInsets.zero,
  Size viewport = const Size(800, 600),
}) => host(
  Align(
    alignment: Alignment.topLeft,
    child: Builder(
      builder: (context) => Button(
        label: 'Open',
        onPressed: () => unawaited(
          Dialog.show<bool>(
            context,
            dismissible: dismissible,
            barrierLabel: barrierLabel,
            builder: (context) => Dialog(
              title: 'Delete photo?',
              body: body,
              content: content,
              size: size,
              alert: alert,
              actions: [
                Button(label: 'Cancel', kind: ButtonKind.ghost, onPressed: () => Dialog.close(context, false)),
                Button(label: 'Delete', kind: ButtonKind.danger, onPressed: () => Dialog.close(context, true)),
              ],
            ),
          ).then((value) => dialogResult = value),
        ),
      ),
    ),
  ),
  size: viewport,
  mode: mode,
  direction: direction,
  textScale: textScale,
  animate: animate,
  viewInsets: viewInsets,
);

Future<void> openDialog(WidgetTester tester) async {
  dialogResult = null;
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}
