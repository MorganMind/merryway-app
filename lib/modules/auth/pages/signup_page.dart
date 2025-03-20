import 'package:app/modules/core/blocs/layout_bloc.dart';
import 'package:app/modules/core/blocs/layout_state.dart';
import 'package:app/modules/core/ui/widgets/fullscreen_loader.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:app/modules/auth/blocs/auth_bloc.dart';
import 'package:app/modules/auth/blocs/auth_event.dart';
import 'package:app/modules/auth/blocs/auth_state.dart';

class SignUpPage extends StatefulWidget {
  final String? code;
  const SignUpPage({super.key, this.code});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _initialFormKey = GlobalKey<FormState>();
  final _credentialsFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _showCredentialsForm = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!value.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Widget _buildInitialForm() {
    return Form(
      key: _initialFormKey,
      child: Column(
        children: [
          ShadInputFormField(
            controller: _emailController,
            placeholder: const Text('name@example.com'),
            validator: _validateEmail,
            onSubmitted: (_) => _handleInitialSubmit(),
          ),
          const SizedBox(height: 4),

          ShadButton(
            onPressed: _handleInitialSubmit,
            width: double.infinity,
            child: const Text('Sign up with Email'),
          ),
          
          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR CONTINUE WITH',
                    style: ShadTheme.of(context).textTheme.muted,
                  ),
                ),
                Expanded(child: Divider()),
              ],
            ),
          ),

          // Google sign up button
          ShadButton.outline(
            onPressed: () {
              context.read<AuthBloc>().add(AuthSignUpWithGoogle());
            },
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const ShadImage('assets/img/google.svg', width: 16, height: 16),
                const SizedBox(width: 8),
                const Text('Continue with Google'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialsForm() {
    return Form(
      key: _credentialsFormKey,
      child: Column(
        children: [
          ShadInputFormField(
            controller: _emailController,
            label: const Text('Email'),
            validator: _validateEmail,
          ),
          const SizedBox(height: 16),

          ShadInputFormField(
            controller: _passwordController,
            label: const Text('Password'),
            obscureText: true,
            validator: _validatePassword,
          ),
          const SizedBox(height: 16),

          ShadInputFormField(
            controller: _confirmPasswordController,
            label: const Text('Confirm Password'),
            obscureText: true,
            validator: _validateConfirmPassword,
            onSubmitted: (_) => _handleCredentialsSubmit(),
          ),
          const SizedBox(height: 24),

          ShadButton(
            onPressed: _isLoading ? null : _handleCredentialsSubmit,
            width: double.infinity,
            icon: _isLoading 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : null,
            child: Text(_isLoading ? 'Please wait...' : 'Sign up with Email'),
          ),
        ],
      ),  
    );
  }

  Widget _buildFormContent(bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              context.go('/'); // TODO: Navigate to onboarding?
            }
            if (state is AuthError) {
              setState(() {
                _isLoading = false;
              });
              ShadToaster.of(context).show(
                ShadToast.destructive(
                  title: const Text('Error'),
                  description: Text(state.message),
                ),
              );
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mobile/tablet logo
              if (!isDesktop)
                Column(
                  children: [
                    Image.asset(
                      'assets/img/pb_logo_full_black.png',
                      height: 45,
                    ),
                    const SizedBox(height: 70),
                  ]
                ),
              AutoSizeText(
                'Create an account',
                style: ShadTheme.of(context).textTheme.h2,
                maxLines: 1,
                maxFontSize: 24,
                minFontSize: 16,
              ),
              const SizedBox(height: 8),
              AutoSizeText(
                'Enter your email below to create your account',
                style: ShadTheme.of(context).textTheme.muted,
                textAlign: TextAlign.center,
                maxLines: 1,
                maxFontSize: 14,
                minFontSize: 12,
              ),
              const SizedBox(height: 24),

              // Show either initial form or credentials form
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _showCredentialsForm
                    ? _buildCredentialsForm()
                    : _buildInitialForm(),
              ),

              // Terms text (always visible)
              if (!_showCredentialsForm) ...[
                const SizedBox(height: 24),
                Text(
                  'By clicking continue, you agree to our',
                  style: ShadTheme.of(context).textTheme.muted,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('Terms of Service', style: TextStyle(decoration: TextDecoration.underline)),
                    ),
                    Text(
                      'and',
                      style: ShadTheme.of(context).textTheme.muted,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Privacy Policy', style: TextStyle(decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  void _handleInitialSubmit() {
    if (_initialFormKey.currentState!.validate()) {
      setState(() {
        _showCredentialsForm = true;
      });
    }
  }

  void _handleCredentialsSubmit() {
    if (!_credentialsFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    context.read<AuthBloc>().add(
      AuthSignUp(
        _emailController.text,
        _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LayoutBloc, LayoutState>(
      builder: (context, layoutState) {
        final isDesktop = layoutState.layoutType == LayoutType.desktop;
        final code = widget.code;
        
        return Stack(
          children: [
            Scaffold(
              body: Stack(
                children: [
                  Row(
                    children: [
                      // Left column - only visible on desktop
                      if (isDesktop)
                        Expanded(
                          child: Container(
                            color: Colors.black,
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset('assets/img/pb_logo_full_white.png', height: 30),
                                const Spacer(),
                                Text(
                                  '"Live as if you were to die tomorrow. Learn as if you were to live forever."',
                                  style: ShadTheme.of(context).textTheme.h3.copyWith(color: Colors.white),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '— Mahatma Gandhi',
                                  style: ShadTheme.of(context).textTheme.muted.copyWith(color: Colors.white),
                                ),
                                const Spacer(),
                              ],
                            ),
                          ),
                        ),

                      // Right column - auth form
                      Expanded(
                        child: isDesktop 
                          ? Center(
                              child: _buildFormContent(isDesktop),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(top: 120),
                              child: _buildFormContent(isDesktop),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Show FullscreenLoader if code parameter exists
            if (code != null)
              const FullscreenLoader(),
          ],
        );
      }
    );
  }
}