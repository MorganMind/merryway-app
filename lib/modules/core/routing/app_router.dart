// Phase 1: Auth → Onboarding → Home flow
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:merryway/modules/home/pages/home_page.dart';
import 'package:merryway/modules/onboarding/pages/onboarding_page.dart';
import 'package:merryway/modules/settings/pages/simple_settings_page.dart';
import 'package:merryway/modules/experiences/pages/moments_page.dart';
import 'package:merryway/modules/experiences/pages/moments_v2_page.dart';
import 'package:merryway/modules/family/models/family_models.dart';
import 'package:merryway/modules/family/models/pod_model.dart';
import 'package:merryway/modules/ideas/pages/my_ideas_page.dart';
import 'package:merryway/modules/ideas/pages/idea_detail_page.dart';
import 'package:merryway/modules/ideas/widgets/idea_composer.dart';
import 'package:merryway/modules/plans/screens/plans_list_screen.dart';
import 'package:merryway/modules/auth/pages/simple_login_page.dart';
import 'package:merryway/modules/auth/services/user_context_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/sparkle_loading.dart';
import '../../../test_token_widget.dart';

// Phase 1 Auth Pages
class OldLoginPage extends StatefulWidget {
  const OldLoginPage({super.key});

  @override
  State<OldLoginPage> createState() => _OldLoginPageState();
}

class _OldLoginPageState extends State<OldLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final supabase = Supabase.instance.client;
      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Welcome to Merryway',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                enabled: !_isLoading,
                onSubmitted: (_) => _handleLogin(),
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: SparkleLoading(size: 20),
                      )
                    : const Text('Sign In'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading ? null : () => context.go('/signup'),
                child: const Text('Don\'t have an account? Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final supabase = Supabase.instance.client;
      await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) {
        // Check if email confirmation is required
        final session = supabase.auth.currentSession;
        if (session != null) {
          context.go('/onboarding');
        } else {
          setState(() {
            _error = 'Please check your email to confirm your account';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Create Account',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                enabled: !_isLoading,
                onSubmitted: (_) => _handleSignUp(),
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSignUp,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: SparkleLoading(size: 20),
                      )
                    : const Text('Sign Up'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading ? null : () => context.go('/login'),
                child: const Text('Already have an account? Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppRouter {
  static GoRouter setupRouter(BuildContext context) {
    final supabase = Supabase.instance.client;
    
    return GoRouter(
      debugLogDiagnostics: true,
      initialLocation: '/',
      refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),
      redirect: (context, state) {
        final session = supabase.auth.currentSession;
        final isAuthenticated = session != null;
        final isOnLoginPage = state.uri.path == '/login';
        final isOnOnboarding = state.uri.path == '/onboarding';
        final isOnHome = state.uri.path == '/home';
        final isOnTestToken = state.uri.path == '/test-token';

        // Allow test-token route without authentication
        if (isOnTestToken) {
          return null;
        }

        // Not authenticated → redirect to login
        if (!isAuthenticated && !isOnLoginPage) {
          return '/login';
        }

        // Authenticated but on login page → go to home
        if (isAuthenticated && isOnLoginPage) {
          return '/home';
        }

        // Authenticated on root → go to home
        if (isAuthenticated && state.uri.path == '/') {
          return '/home';
        }

        return null; // No redirect needed
      },
      routes: [
        // Auth pages
        GoRoute(
          path: '/login',
          builder: (context, state) => const SimpleLoginPage(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignUpPage(),
        ),
        
        // Onboarding (after auth)
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingPage(),
        ),
        
        // Home (after onboarding)
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),
        
        // Settings
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SimpleSettingsPage(),
        ),
        
        // Moments (auto-resolves householdId and loads members)
        GoRoute(
          path: '/moments',
          builder: (context, state) {
            return _MomentsRouteWrapper();
          },
        ),
        
        // Plans (auto-resolves householdId from user session)
        GoRoute(
          path: '/plans',
          builder: (context, state) {
            return _PlansRouteWrapper();
          },
        ),
        
        // Ideas - My Ideas Page
        GoRoute(
          path: '/ideas/my',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final householdId = extra?['householdId'] as String? ?? '';
            final currentMemberId = extra?['currentMemberId'] as String? ?? '';
            final isParent = extra?['isParent'] as bool? ?? false;
            final allMembers = extra?['allMembers'] as List<FamilyMember>? ?? [];
            final allPods = extra?['allPods'] as List<Pod>? ?? [];
            
            return MyIdeasPage(
              householdId: householdId,
              currentMemberId: currentMemberId,
              isParent: isParent,
              allMembers: allMembers,
              allPods: allPods,
            );
          },
        ),
        
        // Ideas - New Idea Composer
        GoRoute(
          path: '/ideas/new',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final householdId = extra?['householdId'] as String? ?? '';
            final currentMemberId = extra?['currentMemberId'] as String? ?? '';
            final allMembers = extra?['allMembers'] as List<FamilyMember>? ?? [];
            final allPods = extra?['allPods'] as List<Pod>? ?? [];
            
            return IdeaComposer(
              householdId: householdId,
              currentMemberId: currentMemberId,
              allMembers: allMembers,
              allPods: allPods,
            );
          },
        ),
        
        // Ideas - Idea Detail Page
        GoRoute(
          path: '/ideas/:id',
          builder: (context, state) {
            final ideaId = state.pathParameters['id'] ?? '';
            final extra = state.extra as Map<String, dynamic>?;
            final householdId = extra?['householdId'] as String? ?? '';
            final currentMemberId = extra?['currentMemberId'] as String? ?? '';
            final isParent = extra?['isParent'] as bool? ?? false;
            final allMembers = extra?['allMembers'] as List<FamilyMember>? ?? [];
            final allPods = extra?['allPods'] as List<Pod>? ?? [];
            
            return IdeaDetailPage(
              ideaId: ideaId,
              householdId: householdId,
              currentMemberId: currentMemberId,
              isParent: isParent,
              allMembers: allMembers,
              allPods: allPods,
            );
          },
        ),
        
        // Test route for token testing
        GoRoute(
          path: '/test-token',
          builder: (context, state) => const TestTokenWidget(),
        ),
        
        // Root
        GoRoute(
          path: '/',
          redirect: (context, state) => '/login',
        ),
      ],
    );
  }
}

// Helper to make auth state changes work with GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Wrapper that auto-resolves household ID from user session
class _PlansRouteWrapper extends StatefulWidget {
  @override
  State<_PlansRouteWrapper> createState() => _PlansRouteWrapperState();
}

class _PlansRouteWrapperState extends State<_PlansRouteWrapper> {
  String? _householdId;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _resolveHouseholdId();
  }

  Future<void> _resolveHouseholdId() async {
    try {
      // Get user's household from their session
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      if (user == null) {
        setState(() {
          _error = 'User not authenticated';
          _isLoading = false;
        });
        return;
      }

      // Query households table to find user's household (get most recent)
      final response = await supabase
          .from('households')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        final householdId = response.first['id'] as String?;
        if (householdId != null && householdId.isNotEmpty) {
          setState(() {
            _householdId = householdId;
            _isLoading = false;
          });
          return;
        }
      }

      // If no household found, show error
      setState(() {
        _error = 'No household found for user';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load household: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: SparkleLoading(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      );
    }

    if (_householdId == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.home_outlined, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'No household found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Please create or join a household first'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      );
    }

    return PlansListScreen(householdId: _householdId!);
  }
}

/// Wrapper that auto-resolves household ID and loads family members for moments
class _MomentsRouteWrapper extends StatefulWidget {
  @override
  State<_MomentsRouteWrapper> createState() => _MomentsRouteWrapperState();
}

class _MomentsRouteWrapperState extends State<_MomentsRouteWrapper> {
  String? _householdId;
  List<FamilyMember> _allMembers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _resolveHouseholdAndMembers();
  }

  Future<void> _resolveHouseholdAndMembers() async {
    try {
      // Get user's household from their session
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      if (user == null) {
        setState(() {
          _error = 'User not authenticated';
          _isLoading = false;
        });
        return;
      }

      // Query households table to find user's household (get most recent)
      final response = await supabase
          .from('households')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        final householdId = response.first['id'] as String?;
        if (householdId != null && householdId.isNotEmpty) {
          // Load family members for this household
          final membersData = await supabase
              .from('family_members')
              .select()
              .eq('household_id', householdId);
          final members = (membersData as List<dynamic>)
              .map((json) => FamilyMember.fromJson(json))
              .toList();
          
          setState(() {
            _householdId = householdId;
            _allMembers = members;
            _isLoading = false;
          });
          return;
        }
      }

      // If no household found, show error
      setState(() {
        _error = 'No household found for user';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load household and members: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: SparkleLoading(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      );
    }

    if (_householdId == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.home_outlined, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'No household found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Please create or join a household first'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      );
    }

    return MomentsV2Page(
      householdId: _householdId!,
      allMembers: _allMembers,
    );
  }
}