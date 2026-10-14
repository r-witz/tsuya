// One screen of the gallery: a component, a piece of the material, or a block.
import 'package:flutter/widgets.dart';
import 'package:tsuya/tsuya.dart';

import '../ui/icons.dart';

/// What an entry shows; the navigation groups by it.
enum EntryKind {
  /// A component of DESIGN.md (and the glyphs the package draws).
  component('Components', GIcon.box),

  /// The material: accent, ambient, glass, grain.
  material('Material', GIcon.drop),

  /// A block of DESIGN.md's Patterns and blocks: an example to copy, not a component.
  block('Blocks', GIcon.layout);

  const EntryKind(this.label, this.icon);

  /// The group's name.
  final String label;

  /// The icon of its entries in the sidebar.
  final GIcon icon;
}

/// A screen of the gallery.
class GalleryEntry {
  /// An entry [id] (a file name: the golden is named after it) titled [title].
  const GalleryEntry(this.kind, this.id, this.title, this.summary, this.build);

  /// A component's screen.
  const GalleryEntry.component(this.id, this.title, this.summary, this.build) : kind = EntryKind.component;

  /// A screen of the material.
  const GalleryEntry.material(this.id, this.title, this.summary, this.build) : kind = EntryKind.material;

  /// A block.
  const GalleryEntry.block(this.id, this.title, this.summary, this.build) : kind = EntryKind.block;

  /// Lower-case words joined by dashes.
  final String id;

  /// The name shown in lists and on the screen.
  final String title;

  /// One line: what it is for.
  final String summary;

  /// Component, material or block.
  final EntryKind kind;

  /// A component or material entry builds the variants (a page wraps them); a block builds a whole screen that
  /// fills the space it is given and adapts to its width.
  final WidgetBuilder build;

  /// Whether [build] makes a whole screen, not a list of variants.
  bool get isBlock => kind == EntryKind.block;
}

/// The body of an [entry]: the screen of a block as it is, or a page of variants under the entry's header.
class EntryBody extends StatelessWidget {
  /// The body of [entry].
  const EntryBody(this.entry, {super.key});

  /// The entry to show.
  final GalleryEntry entry;

  @override
  Widget build(BuildContext context) {
    if (entry.isBlock) return entry.build(context);
    return Screen(
      builder: (context, padding) => SingleChildScrollView(
        padding: padding.copyWith(top: padding.top + TsuyaSpace.s24),
        child: Align(
          alignment: AlignmentDirectional.topStart,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: TsuyaSpace.s32),
                  child: PageHeader(title: entry.title, subtitle: entry.summary),
                ),
                entry.build(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
