import 'package:flutter/material.dart';

import '../app_state.dart';
import '../utils/constants.dart';
import 'dashboard_screen.dart';

enum AuthMode { login, signUp }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.initialMode});

  final AuthMode initialMode;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  late AuthMode _mode;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _isLoginMode => _mode == AuthMode.login;

  @override
  Widget build(BuildContext context) {
    final title = _isLoginMode ? 'Login' : 'Sign Up';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      children: <Widget>[
                        Icon(
                          _isLoginMode ? Icons.login_rounded : Icons.person_add_alt_1_rounded,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isLoginMode ? 'Welcome back' : 'Create your account',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isLoginMode
                              ? 'Sign in to continue tracking your daily habits.'
                              : 'Set up a local account to start your habit journey.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const <String>[AutofillHints.email],
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            final email = value?.trim() ?? '';
                            if (email.isEmpty) {
                              return 'Enter your email address.';
                            }
                            if (!email.contains('@') || !email.contains('.')) {
                              return 'Enter a valid email address.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          autofillHints: const <String>[AutofillHints.password],
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline_rounded),
                          ),
                          validator: (value) {
                            final password = value ?? '';
                            if (password.isEmpty) {
                              return 'Enter a password.';
                            }
                            if (password.length < 6) {
                              return 'Password must be at least 6 characters.';
                            }
                            return null;
                          },
                        ),
                        if (!_isLoginMode) ...<Widget>[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Confirm password',
                              prefixIcon: Icon(Icons.verified_user_outlined),
                            ),
                            validator: (value) {
                              if ((_confirmPasswordController.text).isEmpty) {
                                return 'Confirm your password.';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match.';
                              }
                              return null;
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          )
                        : Text(_isLoginMode ? 'Login' : 'Sign Up'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            setState(() {
                              _mode = _isLoginMode ? AuthMode.signUp : AuthMode.login;
                              _confirmPasswordController.clear();
                            });
                          },
                    child: Text(_isLoginMode ? 'Need an account? Sign Up' : 'Already have an account? Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final appState = AppStateScope.of(context);
    final error = await (_isLoginMode
        ? appState.login(_emailController.text, _passwordController.text)
        : appState.signUp(_emailController.text, _passwordController.text));

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const DashboardScreen()),
      (route) => false,
    );
  }
}