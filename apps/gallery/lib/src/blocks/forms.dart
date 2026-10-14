// The forms block: one column, labels always visible, 16 between fields, validation on blur and then on input
// once in error, focus on the first error on submit, actions at the end (a full-width primary at the bottom on phone).
import 'package:flutter/widgets.dart' hide Banner, RadioGroup;
import 'package:tsuya/tsuya.dart';

import '../ui/block.dart';
import '../ui/demo.dart';

const _countries = [
  ListboxOption(value: 'fr', label: 'France'),
  ListboxOption(value: 'de', label: 'Germany'),
  ListboxOption(value: 'es', label: 'Spain'),
  ListboxOption(value: 'gb', label: 'United Kingdom'),
];

/// A sign-up form that validates as DESIGN.md says.
class FormsBlock extends StatefulWidget {
  /// The form; [touched] names the fields already left, as after a first pass.
  const FormsBlock({super.key, this.touched = const {'email'}});

  /// The fields that show their error from the start.
  final Set<String> touched;

  @override
  State<FormsBlock> createState() => _FormsBlockState();
}

class _FormsBlockState extends State<FormsBlock> {
  final _name = TextEditingController(text: 'Mira Vale');
  final _email = TextEditingController(text: 'mira@example');
  final _password = TextEditingController();
  final _focus = {
    for (final id in ['name', 'email', 'password']) id: FocusNode(),
  };
  late final Set<String> _touched = {...widget.touched};
  String? _country;
  bool _terms = false;

  @override
  void initState() {
    super.initState();
    // validation on blur: leaving a field makes its error visible
    for (final MapEntry(:key, :value) in _focus.entries) {
      value.addListener(() {
        if (!value.hasFocus && _touched.add(key)) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _email, _password]) {
      c.dispose();
    }
    for (final node in _focus.values) {
      node.dispose();
    }
    super.dispose();
  }

  Map<String, String> get _errors => {
    if (_name.text.trim().isEmpty) 'name': 'Enter your name',
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_email.text)) 'email': 'Enter an address like name@example.com',
    if (_password.text.length < 8) 'password': 'Use at least 8 characters',
  };

  // an error shows once the field has been left, and then follows each keystroke
  String? _error(String id) => _touched.contains(id) ? _errors[id] : null;

  void _submit() {
    setState(() => _touched.addAll(_focus.keys));
    final first = _errors.keys.firstOrNull;
    if (first != null) _focus[first]!.requestFocus();
  }

  @override
  Widget build(BuildContext context) => BlockScreen(
    maxWidth: 480,
    builder: (context, layout) {
      final phone = layout == Layout.phone;
      final submit = Button(
        label: 'Create account',
        kind: ButtonKind.primary,
        size: phone ? ButtonSize.lg : ButtonSize.md,
        block: phone,
        onPressed: _submit,
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHeader(title: 'Create your account', subtitle: 'It takes a minute'),
          const SizedBox(height: TsuyaSpace.s24),
          Stacked([
            TextField(
              label: 'Name',
              controller: _name,
              focusNode: _focus['name'],
              error: _error('name'),
              required: true,
              onChanged: (_) => setState(() {}),
            ),
            TextField(
              label: 'Email',
              controller: _email,
              focusNode: _focus['email'],
              error: _error('email'),
              required: true,
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => setState(() {}),
            ),
            TextField(
              label: 'Password',
              controller: _password,
              focusNode: _focus['password'],
              hint: 'At least 8 characters',
              error: _error('password'),
              obscureText: true,
              required: true,
              onChanged: (_) => setState(() {}),
            ),
            Select<String>(
              label: 'Country',
              value: _country,
              onChanged: (v) => setState(() => _country = v),
              placeholder: 'Choose your country',
              options: _countries,
            ),
            Checkbox(value: _terms, onChanged: (v) => setState(() => _terms = v!), label: 'I accept the terms of use'),
          ]),
          const SizedBox(height: TsuyaSpace.s24),
          if (phone)
            submit
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Button(label: 'Cancel', kind: ButtonKind.ghost, onPressed: () {}),
                const SizedBox(width: TsuyaSpace.s12),
                submit,
              ],
            ),
        ],
      );
    },
  );
}
