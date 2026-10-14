// Type-ahead search (roving focus and the listbox share it): the same search as the web's typeahead.ts.
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/src/foundation/type_ahead.dart';

void main() {
  const labels = ['Albums', 'Artists', 'Audiobooks', 'Books', 'Podcasts'];

  test('the timeout is 500 ms, the same as the web', () {
    expect(typeAheadTimeout, const Duration(milliseconds: 500));
  });

  test('one letter searches from just after the current index, wrapping', () {
    expect(TypeAhead().type('a', labels, 0), 1); // after "Albums": "Artists"
    expect(TypeAhead().type('a', labels, 2), 0); // after "Audiobooks", wrapping: "Albums"
  });

  test('more letters make the search more specific, and may stay on the current label', () {
    final typeAhead = TypeAhead();
    expect(typeAhead.type('a', labels, -1), 0); // "Albums"
    expect(typeAhead.type('u', labels, 0), 2); // "au": "Audiobooks"
    expect(typeAhead.type('d', labels, 2), 2); // "aud" stays on "Audiobooks"
  });

  test('the same letter again moves through the labels that start with it', () {
    final typeAhead = TypeAhead();
    expect(typeAhead.type('a', labels, -1), 0);
    expect(typeAhead.type('a', labels, 0), 1);
    expect(typeAhead.type('a', labels, 1), 2);
    expect(typeAhead.type('a', labels, 2), 0);
  });

  test('matching is case-insensitive', () {
    expect(TypeAhead().type('B', labels, -1), 3); // "Books"
  });

  test('no match returns null and keeps the active index unchanged by the caller', () {
    expect(TypeAhead().type('z', labels, 2), isNull);
  });

  test('an empty list of labels never matches', () {
    expect(TypeAhead().type('a', const [], 0), isNull);
  });

  test('a pause starts a new search instead of adding up', () async {
    final typeAhead = TypeAhead();
    expect(typeAhead.type('a', labels, -1), 0); // "Albums"
    await Future<void>.delayed(typeAheadTimeout + const Duration(milliseconds: 100));
    // "u" alone matches no label: the buffer was reset, not "au"
    expect(typeAhead.type('u', labels, 0), isNull);
  });

  test('reset clears the buffer at once', () {
    final typeAhead = TypeAhead();
    expect(typeAhead.type('a', labels, -1), 0);
    typeAhead.reset();
    expect(typeAhead.type('u', labels, 0), isNull);
  });
}
