// The Flutter usage shown on the RadioGroup page: read, not invented, from packages/flutter/lib/src/components/radio_group.dart.
export const FLUTTER_RADIO_GROUP = `
// RadioGroup also exists in package:flutter/widgets.dart: import tsuya with a prefix…
import 'package:tsuya/tsuya.dart' as t;
// …or hide the SDK's one, and import tsuya as it is:
// import 'package:flutter/widgets.dart' hide RadioGroup;

t.RadioGroup<String>(
  label: 'Size',
  value: size,
  onChanged: (value) => setState(() => size = value),
  options: const [
    t.RadioOption(value: 's', label: 'Small'),
    t.RadioOption(value: 'm', label: 'Medium'),
    t.RadioOption(value: 'l', label: 'Large'),
  ],
)`.trim();
