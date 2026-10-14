// Whether the platform is a touch one, as Pressable's own minimum target decides.
import 'package:flutter/foundation.dart';

/// Whether the platform is a touch one (Android, iOS, Fuchsia): the web's `pointer: coarse`.
bool get touchPlatform => switch (defaultTargetPlatform) {
  TargetPlatform.android || TargetPlatform.iOS || TargetPlatform.fuchsia => true,
  _ => false,
};
