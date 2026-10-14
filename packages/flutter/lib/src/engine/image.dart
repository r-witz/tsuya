// The accent of an image provider: decoded small, computed off the UI thread (packages/core/src/dom/image.ts is the
// browser's counterpart).
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'color.dart';

/// The accent pair of an image: decoded at most [size] pixels on a side, computed off the UI thread (an isolate,
/// except on the web). Decoders differ between platforms: for the same accent everywhere, compute the pair from the
/// pixels once (`accentFromPixels` in Node at upload time) and store it with the content.
Future<AccentPair> accentFromImage(ImageProvider image, {int size = 256}) async {
  final provider = ResizeImage(image, width: size, height: size, policy: ResizeImagePolicy.fit, allowUpscaling: false);
  final completer = Completer<ui.Image>();
  final stream = provider.resolve(ImageConfiguration.empty);
  late final ImageStreamListener listener;
  listener = ImageStreamListener(
    (info, _) {
      stream.removeListener(listener);
      completer.complete(info.image);
    },
    onError: (error, stack) {
      stream.removeListener(listener);
      completer.completeError(error, stack);
    },
  );
  stream.addListener(listener);
  final decoded = await completer.future;
  final width = decoded.width;
  final height = decoded.height;
  final data = await decoded.toByteData(format: ui.ImageByteFormat.rawStraightRgba);
  decoded.dispose();
  if (data == null) throw StateError('accentFromImage: the decoded image could not be read');
  return compute(_accentOfPixels, (data.buffer.asUint8List(), width, height));
}

AccentPair _accentOfPixels((Uint8List, int, int) image) => accentFromPixels(image.$1, image.$2, image.$3);
