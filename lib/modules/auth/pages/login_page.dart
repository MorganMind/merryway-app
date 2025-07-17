import 'package:app/modules/core/ui/widgets/fullscreen_loader.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:app/modules/auth/blocs/auth_bloc.dart';
import 'package:app/modules/auth/blocs/auth_event.dart';
import 'package:app/modules/auth/blocs/auth_state.dart';
import 'package:app/modules/core/blocs/layout_bloc.dart';
import 'package:app/modules/core/blocs/layout_state.dart';

class LoginPage extends StatefulWidget {
  final String? code;
  const LoginPage({super.key, this.code});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    context.read<AuthBloc>().add(
      AuthSignIn(
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
                                Image.asset('assets/img/logo_full_white.png', height: 30),
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
      },
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
              context.go('/');
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
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mobile/tablet logo
                if (!isDesktop)
                  Column( 
                    children: [
                      Image.asset(
                        'assets/img/logo_full_black.png',
                        height: 45,
                      ),
                      const SizedBox(height: 70),
                    ],
                  ),
                AutoSizeText(
                  'Login to your account',
                  style: ShadTheme.of(context).textTheme.h2,
                  maxLines: 1,
                  maxFontSize: 24,
                  minFontSize: 16 ,
                ),
                const SizedBox(height: 8),
                AutoSizeText(
                  'Enter your email below to login to your account',
                  style: ShadTheme.of(context).textTheme.muted,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  maxFontSize: 14,
                  minFontSize: 12,
                ),
                const SizedBox(height: 24),
                
                // Google login button
                ShadButton.outline(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                      AuthSignUpWithGoogle(redirectUrl: 'login/auth')
                    );
                  },
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const ShadImage('assets/img/google.svg', width: 16, height: 16),
                      const SizedBox(width: 8),
                      const Text('Login with Google'),
                    ],
                  ),
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
                          'Or continue with email', 
                          style: ShadTheme.of(context).textTheme.muted
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                ),

                // Email input
                ShadInputFormField(
                  controller: _emailController,
                  label: const Text('Email'),
                  placeholder: const Text('name@exampe.com'),
                  onSubmitted: (_) {
                    if (_formKey.currentState!.validate()) {
                      context.read<AuthBloc>().add(
                        AuthSignIn(
                          _emailController.text,
                          _passwordController.text,
                        ),
                      );
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password input
                ShadInputFormField(
                  controller: _passwordController,
                  label: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Password'),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          context.push('/forgot-password');
                        },
                        child: const Text('Forgot your password?', style: TextStyle(decoration: TextDecoration.underline)),
                      ),
                    ]
                  ),
                  obscureText: true,
                  onSubmitted: (_) {
                    if (_formKey.currentState!.validate()) {
                      context.read<AuthBloc>().add(
                        AuthSignIn(
                          _emailController.text,
                          _passwordController.text,
                        ),
                      );
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
              
                const SizedBox(height: 4),

                // Login button
                ShadButton(
                  onPressed: _isLoading ? null : _handleSubmit,
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
                  child: Text(_isLoading ? 'Please wait...' : 'Login'),
                ),
                const SizedBox(height: 16),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () => context.go('/signup'),
                      child: const Text('Sign up', style: TextStyle(decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}