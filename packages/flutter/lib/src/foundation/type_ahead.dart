// Type-ahead search, shared by RovingFocus and Listbox. The same search as
// packages/core/src/primitives/typeahead.ts.
import 'package:flutter/services.dart';

/// How long typed letters add up; the same on the web.
const Duration typeAheadTimeout = Duration(milliseconds: 500);

/// Whether [event] should add to a type-ahead search: one printable character, not Space, with no Ctrl, Cmd (Meta)
/// or Alt held. The same rule as the web's `typed()` in `typeahead.ts`.
bool isTypeAheadKey(KeyEvent event) {
  final char = event.character;
  return char != null &&
      char.trim().isNotEmpty &&
      !HardwareKeyboard.instance.isControlPressed &&
      !HardwareKeyboard.instance.isMetaPressed &&
      !HardwareKeyboard.instance.isAltPressed;
}

/// Matches typed characters against a list of labels, for composite widgets with one tab stop (menus, tabs,
/// listboxes): feed each keystroke to [type], which returns the index to move to, or null. Letters typed within
/// [typeAheadTimeout] of each other add up; the same letter again moves through the labels that start with it.
class TypeAhead {
  /// A fresh search buffer.
  TypeAhead();

  String _buffer = '';
  DateTime? _last;

  /// [char] typed while [labels] are on screen and [current] is the active index (-1 for none): the index of the
  /// label (case-insensitive) that starts with what has been typed, or null when nothing matches. One letter, or the
  /// same letter again, looks from just after [current]; more letters may stay on it. The search wraps.
  int? type(String char, List<String> labels, int current) {
    if (labels.isEmpty) return null;
    final now = DateTime.now();
    if (_last == null || now.difference(_last!) > typeAheadTimeout) _buffer = '';
    _last = now;
    _buffer += char.toLowerCase();
    final repeated = _buffer.replaceAll(_buffer[0], '').isEmpty;
    final search = repeated ? _buffer.substring(0, 1) : _buffer;
    final start = repeated ? current + 1 : (current < 0 ? 0 : current);
    for (var i = 0; i < labels.length; i++) {
      final index = (start + i) % labels.length;
      if (labels[index].trim().toLowerCase().startsWith(search)) return index;
    }
    return null;
  }

  /// Clears the buffer, for example when the group loses focus.
  void reset() {
    _buffer = '';
    _last = null;
  }
}
