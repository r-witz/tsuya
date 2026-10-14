// The Flutter usage shown on the Dialog page: read, not invented, from packages/flutter/lib/src/components/dialog.dart.
export const FLUTTER_DIALOG = `
final deleted = await Dialog.show<bool>(
  context,
  builder: (dialogContext) => Dialog(
    title: 'Delete photo?',
    body: 'It leaves every album it is in. This cannot be undone.',
    actions: [
      Button(label: 'Cancel', onPressed: () => Dialog.close(dialogContext)),
      Button(
        label: 'Delete',
        kind: ButtonKind.danger,
        onPressed: () => Dialog.close(dialogContext, true),
      ),
    ],
  ),
);`.trim();

export const FLUTTER_REQUIRED = `
await Dialog.show<void>(
  context,
  dismissible: false,
  builder: (dialogContext) => Dialog(
    title: 'Your session has expired',
    body: 'Sign in again to keep your changes.',
    alert: true,
    size: DialogSize.lg,
    actions: [
      Button(
        label: 'Sign in',
        kind: ButtonKind.primary,
        onPressed: () => Dialog.close(dialogContext),
      ),
    ],
  ),
);`.trim();
