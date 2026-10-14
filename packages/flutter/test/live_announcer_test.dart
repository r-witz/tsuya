// Announcing a change to screen readers without a visible live region (DESIGN.md, Foundations: Accessibility).
// G5: assistive technology gets the message.
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/src/foundation/live_announcer.dart';

import 'support.dart';

void main() {
  testWidgets('announces politely by default, assertively when asked', (tester) async {
    final messages = <Map<dynamic, dynamic>>[];
    tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(SystemChannels.accessibility, (
      message,
    ) async {
      messages.add(message as Map<dynamic, dynamic>);
      return null;
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
        SystemChannels.accessibility,
        null,
      ),
    );

    late BuildContext context;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      ),
    );

    announce(context, 'Saved');
    await tester.pump();
    expect(messages, hasLength(1));
    expect(messages[0]['type'], 'announce');
    var data = messages[0]['data'] as Map<dynamic, dynamic>;
    expect(data['message'], 'Saved');
    expect(data.containsKey('assertiveness'), isFalse, reason: 'polite is the default, and omitted from the map');

    announce(context, 'Something went wrong', assertive: true);
    await tester.pump();
    expect(messages, hasLength(2));
    data = messages[1]['data'] as Map<dynamic, dynamic>;
    expect(data['message'], 'Something went wrong');
    expect(data['assertiveness'], Assertiveness.assertive.index);
  });
}
