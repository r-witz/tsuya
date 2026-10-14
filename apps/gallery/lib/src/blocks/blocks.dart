// The blocks of DESIGN.md (Patterns and blocks), as screens of the gallery. They are examples to copy, not
// components of the package.
import '../app/entry.dart';
import 'auth.dart';
import 'content_page.dart';
import 'dashboard.dart';
import 'forms.dart';
import 'library.dart';
import 'player.dart';
import 'settings.dart';
import 'shells.dart';

/// The blocks.
final blockEntries = [
  GalleryEntry.block(
    'content-page',
    'Content page',
    'An album: the cover large, its colour on the page.',
    (_) => const ContentPageBlock(),
  ),
  GalleryEntry.block(
    'library',
    'Library and grid',
    'Counts, chips, a grid or list, and its states.',
    (_) => const LibraryBlock(),
  ),
  GalleryEntry.block(
    'settings',
    'Settings',
    'Neutral glass, rows, switches that apply at once.',
    (_) => const SettingsBlock(),
  ),
  GalleryEntry.block(
    'forms',
    'Forms',
    'One column, validation on blur, focus on the first error.',
    (_) => const FormsBlock(),
  ),
  GalleryEntry.block('auth', 'Auth', 'Sign in, sign up and reset with the brand accent.', (_) => const AuthBlock()),
  GalleryEntry.block(
    'phone-shell',
    'Phone shell',
    'Margins of 20, a floating tab bar, sheets from the bottom.',
    (_) => const PhoneShellBlock(),
  ),
  GalleryEntry.block(
    'desktop-shell',
    'Desktop shell',
    'A sidebar and a content column of at most 1200.',
    (_) => const DesktopShellBlock(),
  ),
  GalleryEntry.block(
    'website',
    'Website',
    'A glass app bar over a hero lit by the product.',
    (_) => const WebsiteBlock(),
  ),
  GalleryEntry.block(
    'player',
    'Player',
    'Now playing: the ambient background and control glass.',
    (_) => const PlayerBlock(),
  ),
  GalleryEntry.block(
    'dashboard',
    'Dashboard',
    'A header, rows of tabular figures and a list.',
    (_) => const DashboardBlock(),
  ),
  GalleryEntry.block(
    'states',
    'Empty, error, offline',
    'A short title, one sentence, one action; a banner for lasting states.',
    (_) => const StatesBlock(),
  ),
];
