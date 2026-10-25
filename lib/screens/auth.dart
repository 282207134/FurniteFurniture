import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/validation.dart';
import '../state/shop_state.dart';
import '../widgets/form_fields.dart';
import '../widgets/shop_widgets.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.signUp = false});
  final bool signUp;
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool signUp = widget.signUp;
  final formKey = GlobalKey<FormState>();
  final password = TextEditingController();
  String email = '';
  bool hidden = true;
  @override
  void dispose() {
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Back',
                onPressed: () => back(context),
                icon: const Icon(Icons.west),
              ),
              const Spacer(),
              for (final (i, label) in ['Sign in', 'Sign up'].indexed)
                TextButton(
                  onPressed: () => setState(() {
                    signUp = i == 1;
                    formKey.currentState?.reset();
                  }),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      color: signUp == (i == 1)
                          ? FurniteTheme.ink
                          : const Color(0xFFBDBDBC),
                      fontWeight: FontWeight.w700,
                      decoration: signUp == (i == 1)
                          ? TextDecoration.underline
                          : null,
                      decorationColor: FurniteTheme.yellow,
                      decorationThickness: 3,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 54),
          Text(
            signUp ? 'Create Account' : 'Welcome Home',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            signUp ? 'Start shopping with us' : 'Sign in to continue',
            style: const TextStyle(color: Color(0xFF737D94)),
          ),
          const SizedBox(height: 68),
          Form(
            key: formKey,
            child: Column(
              children: [
                ShopField(
                  'Email address',
                  keyboard: TextInputType.emailAddress,
                  validator: Validate.email,
                  onSaved: (value) => email = value!,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: password,
                  obscureText: hidden,
                  validator: Validate.password,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      tooltip: hidden ? 'Show password' : 'Hide password',
                      onPressed: () => setState(() => hidden = !hidden),
                      icon: Icon(
                        hidden
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                if (signUp) ...[
                  const SizedBox(height: 24),
                  ShopField(
                    'Confirm password',
                    obscure: true,
                    validator: (v) =>
                        v == password.text && (v?.isNotEmpty ?? false)
                        ? null
                        : 'Passwords do not match',
                  ),
                ],
              ],
            ),
          ),
          if (!signUp)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => go(context, '/recovery'),
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(color: FurniteTheme.ink),
                ),
              ),
            ),
          const SizedBox(height: 56),
          PrimaryButton(
            signUp ? 'Sign up' : 'Sign in',
            icon: Icons.east,
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                ShopScope.of(context).signIn(email);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/profile',
                  (_) => false,
                );
              }
            },
          ),
          const SizedBox(height: 18),
          const Text(
            'Demo account · use any valid email and a password of 6+ characters. Credentials are not sent or stored.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11),
          ),
        ],
      ),
    ),
  );
}

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key});
  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  int step = 0;
  String email = '';
  final formKey = GlobalKey<FormState>();
  final password = TextEditingController();
  @override
  void dispose() {
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    title: '',
    cart: false,
    child: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          ['Recovery', 'Enter Code', 'New Password'][step],
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 12),
        Text(
          [
            'Enter email to receive recovery code',
            'Enter the six-digit code',
            'Choose a new password',
          ][step],
        ),
        const SizedBox(height: 48),
        Form(
          key: formKey,
          child: Column(
            key: ValueKey(step),
            children: [
              if (step == 0)
                ShopField(
                  'Email address',
                  keyboard: TextInputType.emailAddress,
                  validator: Validate.email,
                  onSaved: (value) => email = value!,
                ),
              if (step == 1)
                ShopField(
                  'Recovery code',
                  keyboard: TextInputType.number,
                  maxLength: 6,
                  validator: (value) =>
                      value == '246810' ? null : 'Use the demo code 246810',
                ),
              if (step == 2) ...[
                ShopField(
                  'New password',
                  controller: password,
                  obscure: true,
                  validator: Validate.password,
                ),
                ShopField(
                  'Confirm password',
                  obscure: true,
                  validator: (value) =>
                      value == password.text ? null : 'Passwords do not match',
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          step == 1
              ? 'Demo code: 246810\nRecovery for $email'
              : 'This is a demo recovery flow. No email is sent and no account password is changed.',
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 40),
        PrimaryButton(
          ['Get the code', 'Verify code', 'Reset Password'][step],
          onPressed: () {
            if (!formKey.currentState!.validate()) {
              return;
            }
            formKey.currentState!.save();
            if (step < 2) {
              setState(() => step++);
            } else {
              Navigator.pushReplacementNamed(context, '/signin');
              toast(context, 'Demo recovery complete. You can now sign in.');
            }
          },
        ),
        if (step == 1)
          TextButton(
            onPressed: () => toast(context, 'Demo recovery code: 246810'),
            child: const Text('Resend code'),
          ),
      ],
    ),
  );
}
