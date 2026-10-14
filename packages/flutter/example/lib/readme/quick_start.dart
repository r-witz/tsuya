// The README's quick start snippet, compiled here so they cannot rot (see test/readme_test.dart).
import 'package:flutter/widgets.dart';
import 'package:tsuya/tsuya.dart';

void quickStart() => runApp(
  const TsuyaApp(
    title: 'My app',
    labels: TsuyaLabels.en,
    home: Center(child: Text('Hello')),
  ),
);
