// The auth block: sign in, sign up and reset, with the brand accent and the glow (no content leads).
import 'package:flutter/widgets.dart' hide Banner, RadioGroup;
import 'package:tsuya/tsuya.dart';

import '../ui/block.dart';
import '../ui/demo.dart';
import '../ui/text.dart';

void _noop() {}

// the product's own colour: it replaces the neutral accent here
final _brand = accentFromColor('#5B5BD6');

/// Sign in, sign up and reset on one screen.
class AuthBlock extends StatelessWidget {
  /// The auth screen, on [initial] (`in`, `up` or `reset`).
  const AuthBlock({super.key, this.initial = 'in'});

  /// The tab shown first.
  final String initial;

  @override
  Widget build(BuildContext context) => Accent(
    pair: _brand,
    child: BlockScreen(
      maxWidth: 400,
      builder: (context, layout) => Hold<String>(
        initial: initial,
        builder: (context, tab, set) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: TsuyaSpace.s32),
            styled(context, TsuyaType.displayS, 'tsuya', align: TextAlign.center),
            const SizedBox(height: TsuyaSpace.s8),
            styled(context, TsuyaType.body, 'Music that stays out of the way', muted: true, align: TextAlign.center),
            const SizedBox(height: TsuyaSpace.s32),
            Tabs<String>(
              label: 'Account',
              selected: tab,
              onChanged: set,
              tabs: const [
                TabItem(value: 'in', label: 'Sign in'),
                TabItem(value: 'up', label: 'Create account'),
                TabItem(value: 'reset', label: 'Reset'),
              ],
            ),
            const SizedBox(height: TsuyaSpace.s24),
            switch (tab) {
              'up' => _form(const [
                TextField(label: 'Name', autofillHints: ['name']),
                TextField(label: 'Email', keyboardType: TextInputType.emailAddress),
                TextField(label: 'Password', obscureText: true, hint: 'At least 8 characters'),
              ], 'Create account'),
              'reset' => _form(const [
                TextField(label: 'Email', hint: 'We send a link to reset your password'),
              ], 'Send the link'),
              _ => _form(
                const [
                  TextField(label: 'Email', keyboardType: TextInputType.emailAddress),
                  TextField(label: 'Password', obscureText: true),
                ],
                'Sign in',
                extra: const Button(label: 'Forgot your password?', kind: ButtonKind.ghost, onPressed: _noop),
              ),
            },
          ],
        ),
      ),
    ),
  );

  Widget _form(List<Widget> fields, String action, {Widget? extra}) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Stacked(fields),
      const SizedBox(height: TsuyaSpace.s24),
      Button(label: action, kind: ButtonKind.primary, size: ButtonSize.lg, block: true, onPressed: _noop),
      if (extra != null) ...[const SizedBox(height: TsuyaSpace.s8), extra],
    ],
  );
}
