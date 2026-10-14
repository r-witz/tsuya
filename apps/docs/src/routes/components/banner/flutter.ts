// The Flutter usage shown on the Banner page: read, not invented, from packages/flutter/lib/src/components/banner.dart.
export const FLUTTER_BANNER = `
// Banner also exists in package:flutter/widgets.dart: hide the SDK's one…
import 'package:flutter/widgets.dart' hide Banner;
import 'package:tsuya/tsuya.dart';
// …or import tsuya with a prefix, and write t.Banner.

Banner(
  tone: BannerTone.danger,
  title: 'Sync failed',
  message: 'The last 12 changes were not sent.',
  actions: [
    Button(label: 'Details', kind: ButtonKind.ghost, size: ButtonSize.sm, onPressed: () {}),
    Button(label: 'Try again', size: ButtonSize.sm, onPressed: () {}),
  ],
)`.trim();

export const FLUTTER_CLOSABLE = `
Banner(
  tone: BannerTone.info,
  title: 'Tip',
  message: 'Press F6 to reach a toast from the keyboard.',
  onClose: () => setState(() => showTip = false),
)`.trim();
