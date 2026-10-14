// Carrying tsuya's scopes into an overlay built elsewhere in the tree (DESIGN.md, Foundations: Theme
// and mode).
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/src/foundation/portal.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

void main() {
  testWidgets('wraps the theme, accent, glass scope and labels from where it is opened', (tester) async {
    late BuildContext openerContext;
    final pair = AccentPair(light: const Color(0xFF123456), dark: const Color(0xFF654321));
    await tester.pumpWidget(
      host(
        TsuyaTheme(
          mode: TsuyaMode.light,
          child: Accent(
            pair: pair,
            child: GlassScope(
              neutral: true,
              child: TsuyaLabelsScope(
                labels: TsuyaLabels.fr,
                child: Builder(
                  builder: (context) {
                    openerContext = context;
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );

    late Brightness capturedBrightness;
    late Color capturedAccent;
    late bool capturedNeutral;
    late TsuyaLabels capturedLabels;
    final content = Builder(
      builder: (context) {
        capturedBrightness = TsuyaTheme.of(context).brightness;
        capturedAccent = Accent.of(context);
        capturedNeutral = GlassScope.of(context).neutral;
        capturedLabels = TsuyaLabels.of(context);
        return const SizedBox();
      },
    );
    final wrapped = TsuyaPortal.wrap(from: openerContext, child: content);

    // mount the captured content under a DIFFERENT ambient scope, as an Overlay route built where the Navigator
    // lives would: the capture must win over its new surroundings.
    await tester.pumpWidget(
      host(
        TsuyaTheme(
          mode: TsuyaMode.dark,
          child: Accent(
            pair: AccentPair(light: const Color(0xFFAAAAAA), dark: const Color(0xFFBBBBBB)),
            child: GlassScope(
              neutral: false,
              child: TsuyaLabelsScope(labels: TsuyaLabels.en, child: wrapped),
            ),
          ),
        ),
      ),
    );

    expect(capturedBrightness, Brightness.light);
    expect(capturedAccent, pair.light);
    expect(capturedNeutral, isTrue);
    expect(capturedLabels.close, TsuyaLabels.fr.close);
  });
}
