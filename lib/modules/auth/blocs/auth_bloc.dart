import 'dart:async';
import 'package:app/modules/auth/services/auth_state_listener.dart';
import 'package:app/modules/core/di/service_locator.dart';
import 'package:app/modules/user/models/user_data.dart';
import 'package:app/modules/user/repositories/user_settings_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as s;
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:app/modules/user/repositories/user_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final s.SupabaseClient _supabase = sl<s.SupabaseClient>();
  final UserRepository _userRepository = sl<UserRepository>();
  final AuthStateListener _authStateListener = sl<AuthStateListener>();
  final UserSettingsRepository _settingsRepository = sl<UserSettingsRepository>();
  StreamSubscription? _userSubscription;
  StreamSubscription<s.AuthState>? _authStateSubscription;


  AuthBloc() : super(AuthInitial()) {
    on<AuthSignIn>(_onSignIn);
    on<AuthSignOut>(_onSignOut);
    on<AuthSignUp>(_onSignUp);
    on<AuthSignUpWithGoogle>(_onSignUpWithGoogle);
    on<AuthStateChanged>(_onAuthStateChanged);
    on<CheckInitialSession>(_onCheckInitialSession);

    // Check for existing session immediately
    _checkInitialSession();

    _authStateSubscription = _authStateListener.authStateChanges.listen((data) {
      add(AuthStateChanged(data));
    });
  }

  Future<void> _checkInitialSession() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      if (session.isExpired) {
        // This will automatically refresh the token if needed
        await _supabase.auth.refreshSession(); 
      }
      add(CheckInitialSession(session.user.id)); 
    }
  }

  Future<void> _setupUserSubscription(String userId, Emitter<AuthState> emit) async {
    await _userSubscription?.cancel();
    
    // Initialize user stream
    await _userRepository.initializeUserStream(userId);
    
    // Create and await the subscription
    await emit.forEach(
      _userRepository.currentUser,
      onData: (UserData userData) => Authenticated(userId, userData),
      onError: (error, stackTrace) {
        print('AuthBloc: Error in user stream: $error');
        return AuthError(error.toString());
      },
    );
  }

  Future<void> _onAuthStateChanged(
    AuthStateChanged event,
    Emitter<AuthState> emit,
  ) async {
    final s.AuthChangeEvent authEvent = event.authState.event;
    final s.Session? session = event.authState.session;

    //print('Auth State Change: $authEvent');

    switch (authEvent) {
      case s.AuthChangeEvent.initialSession:
      case s.AuthChangeEvent.signedIn:
        //print('Auth Bloc Auth State Change: $session');
        if (session != null) {
          try {
            await _setupUserSubscription(session.user.id, emit);
          } catch (e) {
            print('Error initializing user data: $e');
            emit(AuthError(e.toString()));
          }
        }
        break;

      case s.AuthChangeEvent.signedOut:
        await _userSubscription?.cancel();
        emit(Unauthenticated());
        break;

      default:
        break;
    }
  }

  Future<void> _onSignIn(AuthSignIn event, Emitter<AuthState> emit) async {
    print('AuthBloc: Signing in');
    emit(AuthLoading());
    
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: event.email,
        password: event.password,
      );
      
      if (response.user != null) {
        print('AuthBloc: Sign in successful: ${response.user!.id}');
        // Initialize settings after successful sign in
        await _settingsRepository.initializeSettingsStream();
        // Note: The actual session will be handled by the supabase auth event changes
      } else {
        print('AuthBloc: Sign in failed - no user returned');
        emit(Unauthenticated());
      }
    } catch (e) {
      print('AuthBloc: Sign in error: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOut(AuthSignOut event, Emitter<AuthState> emit) async {
    print('AuthBloc: Signing out');
    emit(AuthLoading());
    
    try {
      await _supabase.auth.signOut();
      await _userRepository.dispose();
      await _userSubscription?.cancel();
      emit(Unauthenticated());
    } catch (e) {
      print('AuthBloc: Sign out error: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUp(AuthSignUp event, Emitter<AuthState> emit) async {
    print('AuthBloc: Signing up');
    emit(AuthLoading());
    
    try {
      final response = await _supabase.auth.signUp(
        email: event.email,
        password: event.password,
      );
      
      if (response.user != null) {
        print('AuthBloc: Sign up successful: ${response.user!.id}');
        // Initialize settings after successful sign up
        await _settingsRepository.initializeSettingsStream();
        // Note: The actual session will be handled by the supabase auth event changes
      } else {
        print('AuthBloc: Sign up failed - no user returned');
        emit(Unauthenticated());
      }
    } catch (e) {
      print('AuthBloc: Sign up error: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUpWithGoogle(
    AuthSignUpWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      print('AuthBloc: Signing up with Google ${ Uri.base.origin}/${event.redirectUrl}');
      await _supabase.auth.signInWithOAuth(
        s.OAuthProvider.google,
        redirectTo: kIsWeb
            ? '${Uri.base.origin}/${event.redirectUrl}'
            : null,
      );
      // Note: The actual session will be handled by the supabase auth event changes
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onCheckInitialSession(
    CheckInitialSession event,
    Emitter<AuthState> emit,
  ) async {
    final userData = await _userRepository.getCurrentUserData();
    
    if (userData != UserData.empty) {
      // Initialize settings before emitting Authenticated state
      await _settingsRepository.initializeSettingsStream();
      emit(Authenticated(event.userId, userData));
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    _authStateSubscription?.cancel();
    return super.close();
  }
}