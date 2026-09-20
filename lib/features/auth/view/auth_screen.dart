import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

enum AuthScreenMode { signIn, signUp }

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    this.initialMode = AuthScreenMode.signIn,
    this.checkoutFlow = false,
  });

  final AuthScreenMode initialMode;
  final bool checkoutFlow;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  late AuthScreenMode _mode;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authCubit = context.read<AuthCubit>();
    authCubit.clearError();

    final success = _mode == AuthScreenMode.signIn
        ? await authCubit.signIn(
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
          )
        : await authCubit.signUp(
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
            fullName: _nameController.text.trim().isEmpty
                ? null
                : _nameController.text.trim(),
          );

    if (!mounted || !success) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AppAuthState>(
      builder: (context, authState) {
        final isSignUp = _mode == AuthScreenMode.signUp;

        return Scaffold(
      appBar: AppBar(
        title: Text(widget.checkoutFlow ? 'Sign in to checkout' : 'Account'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        isSignUp ? Icons.person_add_outlined : Icons.login,
                        size: 48,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isSignUp ? 'Create account' : 'Welcome back',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.checkoutFlow
                            ? 'Sign in or create an account to submit your order.'
                            : 'Use phone number and password to access your account.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (!authState.isSupabaseReady)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Supabase is not configured. Run the app with '
                            'SUPABASE_URL and SUPABASE_ANON_KEY dart-defines.',
                          ),
                        ),
                      if (isSignUp) ...[
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Full name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone number',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Phone number is required';
                          }
                          if (value.trim().length < 6) {
                            return 'Enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          if (isSignUp && value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      if (authState.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          authState.errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: authState.isLoading || !authState.isSupabaseReady
                            ? null
                            : _submit,
                        child: authState.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(isSignUp ? 'Create account' : 'Sign in'),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: authState.isLoading
                            ? null
                            : () {
                                context.read<AuthCubit>().clearError();
                                setState(() {
                                  _mode = isSignUp
                                      ? AuthScreenMode.signIn
                                      : AuthScreenMode.signUp;
                                });
                              },
                        child: Text(
                          isSignUp
                              ? 'Already have an account? Sign in'
                              : 'Need an account? Sign up',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
      },
    );
  }
}
