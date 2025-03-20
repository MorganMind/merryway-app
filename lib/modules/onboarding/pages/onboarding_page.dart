import 'package:app/modules/core/blocs/layout_bloc.dart';
import 'package:app/modules/core/blocs/layout_state.dart';
import 'package:app/modules/core/di/service_locator.dart';
import 'package:app/modules/onboarding/blocs/onboarding_bloc.dart';
import 'package:app/modules/onboarding/blocs/onboarding_event.dart';
import 'package:app/modules/onboarding/blocs/onboarding_state.dart';
import 'package:app/modules/user/repositories/user_settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:app/modules/onboarding/models/onboarding_payload.dart';
import 'dart:async';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LayoutBloc, LayoutState>(
      builder: (context, layoutState) {
        final isDesktop = layoutState.layoutType == LayoutType.desktop;
        
        return Scaffold(
          body: Row(
            children: [
              // Left column - Form
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isDesktop)
                        FittedBox(
                          fit: BoxFit.cover,
                          child: Image.asset('assets/img/pb_logo_full_black.png', height: 30),
                        ),
                      Expanded(
                        child: isDesktop 
                          ? Center(
                              child: _buildFormContent(isDesktop),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(top: 100),
                              child: _buildFormContent(isDesktop),
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              // Right column - Background image (desktop only)
              if (isDesktop)
                Expanded(
                  child: SizedBox(
                    height: double.infinity,
                    child: Image.asset(
                      'assets/img/onboarding_bg.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormContent(bool isDesktop) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
            
              // Organization name input
              // CreateOrganizationForm(
              //   isLoading: _isLoading,
              //   onSubmit: (organizationName) {
              //     _submitForm(organizationName);
              //   },
              // ),
            ],
          ),
        ),
      )
    );
  }

  void _submitForm(String organizationName) async {

    setState(() {
      _isLoading = true;
    });

    final onboardingBloc = context.read<OnboardingBloc>();

    onboardingBloc.add(
      CompleteOnboarding(
        payload: OnboardingPayload(
          organizationName: organizationName,
        ),
      ),
    );

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
        ShadToast.destructive(
          title: const Text('Error'),
          description: Text(state.message),
        );
        break;
      }
    }
  }
} 