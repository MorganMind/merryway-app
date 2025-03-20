import 'dart:async';

import 'package:app/modules/core/ui/widgets/fullscreen_loader.dart';
import 'package:app/modules/core/utils/invite_code_utils.dart';
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
import 'package:app/modules/core/di/service_locator.dart';
import 'package:app/modules/user/repositories/user_settings_repository.dart';
import 'package:app/modules/onboarding/blocs/onboarding_bloc.dart';
import 'package:app/modules/onboarding/blocs/onboarding_event.dart';
import 'package:app/modules/onboarding/blocs/onboarding_state.dart';
import 'package:flutter/foundation.dart';

class JoinPage extends StatefulWidget {
  final String? joinCode;
  final String? code;

  const JoinPage({
    super.key,
    this.joinCode,
    this.code,
  });

  @override
  State<JoinPage> createState() => _JoinPageState();
}

class _JoinPageState extends State<JoinPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isValidatingCode = true;
  //Organization? _organization;
  String? _error;

  @override
  void initState() {
    super.initState();
    _validateJoinCode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _validateJoinCode() async {
    if (widget.joinCode == null) {
      setState(() {
        _isValidatingCode = false;
        _error = 'Invalid join code';
      });
      return;
    }

    final decoded = InviteCodeUtils.decodeInviteCode(widget.joinCode!);
    if (decoded == null) {
      setState(() {
        _isValidatingCode = false;
        _error = 'Invalid join code';
      });
      return;
    }

    final (orgId, userId) = decoded;
    try {
      // final organization = await sl<OrganizationRepository>().getOrganizationForInvite(orgId, userId);
      // if (organization.userId != userId) {
      //   throw Exception('Invalid organization');
      // }

      setState(() {
        // _organization = organization;
        _isValidatingCode = false;
      });
    } catch (e) {
      setState(() {
        _isValidatingCode = false;
        _error = 'Invalid join code';
      });
    }
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

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

  void _acceptInvite() async {
    setState(() {
      _isLoading = true;
    });

    final onboardingBloc = context.read<OnboardingBloc>();

    // onboardingBloc.add(
    //   CompleteJoinOrganizationOnboarding(
    //     payload: JoinOrganizationOnboardingPayload(
    //       organizationId: "",
    //     ),
    //   ),
    // );

    // Listen for the result
    await for (final state in onboardingBloc.stream) {
      if (state is OnboardingComplete) {
        // Create a completer to wait for settings to actually update
        final settingsCompleter = Completer<void>();
        
        // Listen for the next settings update
        final subscription = sl<UserSettingsRepository>()
            .settings
            .listen((settings) {
          if (settings.userId != null) {
            settingsCompleter.complete();
          }
        });

        // Reload settings after onboarding completes
        await sl<UserSettingsRepository>().reinitializeSettingsStream();
        
        // Wait for settings to actually update
        await settingsCompleter.future;
        subscription.cancel();
        
        // Now that settings are confirmed updated, navigate
        if (!mounted) return;
        context.go('/');
        break;
      }

      if (state is OnboardingError) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Error'),
            description: Text(state.message),
          ),
        );
        break;
      }
    }
  }

  void _joinOrganization() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // await sl<OrganizationRepository>().joinOrganization(_organization!.id);

      // Create a completer to wait for settings to actually update
      final settingsCompleter = Completer<void>();
      
      // Listen for the next settings update
      final subscription = sl<UserSettingsRepository>()
          .settings
          .listen((settings) {
        if (settings.userId != null) {
          settingsCompleter.complete();
        }
      });

      // Reload settings after joining completes
      await sl<UserSettingsRepository>().reinitializeSettingsStream();
      
      // Wait for settings to actually update
      await settingsCompleter.future;
      subscription.cancel();
      
      // Now that settings are confirmed updated, navigate
      if (!mounted) return;
      context.go('/');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: const Text('Error'),
          description: Text(e.toString()),
        ),
      );
    }
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
                      Expanded(
                        child: isDesktop 
                          ? Center(
                              child: _buildContent(isDesktop),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(top: 120),
                              child: _buildContent(isDesktop),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (code != null && _isValidatingCode)
              const FullscreenLoader(),
          ],
        );
      },
    );
  }

  Widget _buildContent(bool isDesktop) {
    // Show loader while validating code
    if (_isValidatingCode) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Show error if validation failed
    if (_error != null) {
      return BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  if (state is Authenticated) ...[
                    const SizedBox(height: 32),
                    ShadButton(
                      onPressed: () => context.go('/'),
                      child: const Text('Continue'),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );
    }

    // Only show login/authenticated view if we have organization data
    // if (_organization == null) {
    //   return const Center(
    //     child: CircularProgressIndicator(),
    //   );
    // }

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          // Handle authenticated state
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
      builder: (context, state) {
        return state is Authenticated 
            ? _buildAuthenticatedView(isDesktop, state)
            : _buildLoginForm(isDesktop);
      },
    );
  }

  Widget _buildAuthenticatedView(bool isDesktop, AuthState state) {
    final colors = ShadTheme.of(context);
    final settings = sl<UserSettingsRepository>().currentSettings;
    
    return FutureBuilder<List>(
      future: Future.value([]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // final isAlreadyMember = snapshot.data?.any((org) => org.id == _organization!.id) ?? false;
        
        return Container(
          width: isDesktop ? 400 : double.infinity,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.group_add_outlined, 
                size: 48
              ),
              const SizedBox(height: 24),
              AutoSizeText(
                'Join Pointerbase',
                style: colors.textTheme.h2,
                maxLines: 1,
              ),
              const SizedBox(height: 8),
              Text(
                'You have been invited to join Pointerbase',
                style: colors.textTheme.muted,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (state is Authenticated && state.userData.onboardingCompleted)
                ShadButton(
                  onPressed: _isLoading ? null : () {
                    context.go('/');
                  },
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
                  child: Text(_isLoading ? 'Please wait...' : 'Continue'),
                )
              else
                Column(
                  children: [
                    ShadButton(
                      onPressed: _isLoading ? null : () {
                        if (state is Authenticated) {
                          if (state.userData.onboardingCompleted) {
                            _joinOrganization();
                          } else {
                            _acceptInvite();
                          }
                        }
                      },
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
                      child: Text(_isLoading ? 'Please wait...' : 'Accept Invitation'),
                    ),
                    if (state is Authenticated && 
                        state.userData.onboardingCompleted) ...[
                      const SizedBox(height: 16),
                      ShadButton.outline(
                        onPressed: _isLoading ? null : () {
                          context.go('/');
                        },
                        width: double.infinity,
                        child: const Text('Decline'),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoginForm(bool isDesktop) {
    final colors = ShadTheme.of(context);
   
    return Container(
      width: isDesktop ? 400 : double.infinity,
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Center(
              child: AutoSizeText(
                'Join Pointerbase',
                style: colors.textTheme.h2,
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You are invited to join Pointerbase',
              style: colors.textTheme.muted,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Google sign in button
            ShadButton.outline(
              onPressed: () {
                context.read<AuthBloc>().add(
                  AuthSignUpWithGoogle(redirectUrl: 'join/${widget.joinCode}/auth')
                );
              },
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const ShadImage('assets/img/google.svg', width: 16, height: 16),
                  const SizedBox(width: 8),
                  const Text('Join with Google'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Or divider
            Row(
              children: [
                Expanded(child: Divider(color: colors.colorScheme.border)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Or continue with email', style: colors.textTheme.muted),
                ),
                Expanded(child: Divider(color: colors.colorScheme.border)),
              ],
            ),
            const SizedBox(height: 24),

            // Email input
            ShadInputFormField(
              controller: _emailController,
              label: const Text('Email'),
              onSubmitted: (_) => _handleSubmit(),
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
                  const Text('Password'),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      context.push('/forgot-password');
                    },
                    child: const Text('Forgot your password?', 
                      style: TextStyle(decoration: TextDecoration.underline)
                    ),
                  ),
                ]
              ),
              obscureText: true,
              onSubmitted: (_) => _handleSubmit(),
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
            const SizedBox(height: 24),

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
              child: Text(_isLoading ? 'Please wait...' : 'Join Morgan'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
} 