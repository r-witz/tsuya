// The Flutter usage shown on the TextInput page: read, not invented, from packages/flutter/lib/src/components/text_field.dart.
export const FLUTTER_TEXT_FIELD = `
final controller = TextEditingController();

TextField(
  label: 'Email',
  controller: controller,
  placeholder: 'you@example.com',
  hint: 'We only use it to sign you in.',
  required: true,
  clearable: true,
  keyboardType: TextInputType.emailAddress,
  onChanged: (value) {
    // …
  },
)`.trim();

export const FLUTTER_TEXTAREA = `
TextField(
  label: 'Notes',
  optional: true,
  minLines: 2,
  maxLines: 8,
)`.trim();

export const FLUTTER_SEARCH = `
TextField.search(
  label: 'Search the docs',
  placeholder: 'Search',
  onChanged: (query) {
    // …
  },
)`.trim();
