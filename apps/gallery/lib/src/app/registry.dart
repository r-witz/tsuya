// Every screen of the gallery, in the order of DESIGN.md's components and blocks.
import '../blocks/blocks.dart';
import '../components/actions.dart';
import '../components/choice_inputs.dart';
import '../components/content.dart';
import '../components/feedback.dart';
import '../components/lists.dart';
import '../components/material.dart';
import '../components/navigation.dart';
import '../components/overlays.dart';
import '../components/shells.dart';
import '../components/text_inputs.dart';
import 'entry.dart';

/// The components, the material and the blocks.
final List<GalleryEntry> allEntries = [
  ...actionEntries,
  ...textInputEntries,
  ...choiceInputEntries,
  ...listEntries,
  ...contentEntries,
  ...navigationEntries,
  ...shellEntries,
  ...overlayEntries,
  ...feedbackEntries,
  ...materialEntries,
  ...blockEntries,
];
