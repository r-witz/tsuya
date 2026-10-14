// The empty, error and offline states of DESIGN.md's Patterns and blocks: a short title, one sentence, one action.
import 'package:flutter/widgets.dart';
import 'package:tsuya/tsuya.dart';

import 'icons.dart';
import 'text.dart';

/// A state that replaces content: [icon] in a round fill, [title], one sentence, and one action.
class StateView extends StatelessWidget {
  /// A state saying [title] and [message], with [actionLabel] to leave it.
  const StateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    this.onAction,
  });

  /// What the state looks like.
  final GIcon icon;

  /// A few words.
  final String title;

  /// One sentence that says what to do.
  final String message;

  /// The one action.
  final String actionLabel;

  /// What it does.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = TsuyaTheme.of(context).colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TsuyaSpace.s32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(color: colors.fill, shape: BoxShape.circle),
                child: Padding(
                  padding: const EdgeInsets.all(TsuyaSpace.s16),
                  child: GIconView(icon, size: TsuyaSize.iconLg, color: colors.textMuted),
                ),
              ),
              const SizedBox(height: TsuyaSpace.s16),
              styled(context, TsuyaType.titleM, title, align: TextAlign.center),
              const SizedBox(height: TsuyaSpace.s8),
              styled(context, TsuyaType.body, message, muted: true, align: TextAlign.center),
              const SizedBox(height: TsuyaSpace.s24),
              Button(label: actionLabel, kind: ButtonKind.primary, onPressed: onAction ?? _noop),
            ],
          ),
        ),
      ),
    );
  }
}

void _noop() {}
