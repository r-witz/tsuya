// How a picture shown with BoxFit.cover is decoded (Thumbnail, Avatar).
import 'package:flutter/widgets.dart';

/// [image] decoded once for a [width] × [height] box (logical px) shown with [BoxFit.cover]: at physical pixels
/// (the device pixel ratio), along the dimension cover scales from, with the other following the picture so its
/// aspect is kept: a squashed decode would not crop. A picture and a box of different shapes are not known apart
/// before decoding, so it is the height for a box as tall as wide or taller (a landscape photo, the usual one) and
/// the width for a wider one; a picture of the other shape decodes a little soft rather than distorted.
ImageProvider coverDecoded(BuildContext context, ImageProvider image, {required double width, required double height}) {
  final ratio = MediaQuery.devicePixelRatioOf(context);
  return width > height
      ? ResizeImage(image, width: (width * ratio).round(), policy: ResizeImagePolicy.fit)
      : ResizeImage(image, height: (height * ratio).round(), policy: ResizeImagePolicy.fit);
}
