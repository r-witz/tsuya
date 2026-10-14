// Motion follows a change; reduced motion makes every change instant (DESIGN.md, Foundations: Motion).
import 'package:flutter/widgets.dart';

/// Whether [context] asks for reduced motion (`MediaQuery.disableAnimations`).
bool reducedMotion(BuildContext context) => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// [duration], or zero under [reducedMotion]. Pass the result to every `AnimationController`, `AnimatedContainer` and
/// similar.
Duration motionOf(BuildContext context, Duration duration) => reducedMotion(context) ? Duration.zero : duration;
