/// The tsuya gallery: every component and block, with switches for mode, accent, text scale, direction and
/// transparency.
library;

import 'package:flutter/widgets.dart';

import 'src/app/host.dart';
import 'src/app/settings.dart';
import 'src/app/shell.dart';

/// Starts the gallery.
void main() => runApp(GalleryHost(controller: GalleryController(), home: const GalleryShell()));
