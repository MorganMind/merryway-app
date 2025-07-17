import 'dart:async';
import 'dart:convert';
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
import 'package:shared_preferences/shared_preferences.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final s.SupabaseClient _supabase = sl<s.SupabaseClient>();
  final UserRepository _userRepository = sl<UserRepository>();
  final AuthStateListener _authStateListener = sl<AuthStateListener>();
  final UserSettingsRepository _settingsRepository = sl<UserSettingsRepository>();
  final SharedPreferences _prefs = sl<SharedPreferences>();
  StreamSubscription? _userSubscription;
  StreamSubscription<s.AuthState>? _authStateSubscription;

  AuthBloc() : super(AuthInitial()) {
    on<AuthInitialize>(_onInitialize);
    on<AuthSignIn>(_onSignIn);
    on<AuthSignOut>(_onSignOut);
    on<AuthSignUp>(_onSignUp);
    on<AuthSignUpWithGoogle>(_onSignUpWithGoogle);
    on<AuthStateChanged>(_onAuthStateChanged);
  
    _authStateSubscription = _authStateListener.authStateChanges.listen((data) {
      add(AuthStateChanged(data));
    });

    add(AuthInitialize());
  }

  // Future<void> _setupUserSubscription(String userId, Emitter<AuthState> emit) async {
  //   await _userSubscription?.cancel();
    
  //   // Initialize user stream
  //   await _userRepository.initializeUserStream(userId);
    
  //   // Create and await the subscription
  //   await emit.forEach(
  //     _userRepository.currentUser,
  //     onData: (UserData userData) => Authenticated(userId, userData),
  //     onError: (error, stackTrace) {
  //       print('AuthBloc: Error in user stream: $error');
  //       return AuthError(error.toString());
  //     },
  //   );
  // }

  Future<void> _setupUserSubscription(String userId, Emitter<AuthState> emit) async {
    await _userSubscription?.cancel();
    
    // Initialize user stream
    await _userRepository.initializeUserStream(userId);
    
    // Create and await the subscription
    await emit.forEach(
      _userRepository.currentUser,
      onData: (UserData userData) {
        // Cache the updated user data
        _prefs.setString('user_data_$userId', jsonEncode(userData.toJson()));
        return Authenticated(userId, userData, isDataFresh: true);
      },
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

    switch (authEvent) {
      case s.AuthChangeEvent.initialSession:
        // Don't handle here - handled by AuthInitialize
        break;
      case s.AuthChangeEvent.signedIn:
        if (session != null) {
          try {
            // Load user data
            final userData = await _userRepository.getCurrentUserData();
            
            // Cache user data
            if (userData != UserData.empty) {
              await _prefs.setString('user_data_${session.user.id}', jsonEncode(userData.toJson()));
            }
            
            // Initialize settings
            await _settingsRepository.initializeSettingsStream();
            
            // Initialize user stream
            await _setupUserSubscription(session.user.id, emit);
            
            emit(Authenticated(session.user.id, userData, isDataFresh: true));
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

  Future<UserData> _loadCachedUserData(String userId) async {
    try {
      final cachedData = _prefs.getString('user_data_$userId');
      
      if (cachedData != null) {
        return UserData.fromJson(jsonDecode(cachedData));
      }
    } catch (e) {
      print('Error loading cached user data: $e');
    }
    
    return UserData.empty;
  }

  Future<void> _refreshUserDataInBackground(String userId) async {
    try {
      final freshData = await _userRepository.getCurrentUserData();
      
      if (freshData != UserData.empty) {
        // Cache the fresh data
        await _prefs.setString('user_data_$userId', jsonEncode(freshData.toJson()));
        
        // Update the current state if it's still authenticated
        final currentState = state;
        if (currentState is Authenticated && currentState.userId == userId) {
          emit(Authenticated(userId, freshData, isDataFresh: true));
        }
      }
    } catch (e) {
      print('Error refreshing user data: $e');
    }
  }

  Future<void> _onInitialize(AuthInitialize event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    final session = _supabase.auth.currentSession;
    
    if (session != null && !session.isExpired) {
      try {
        // Try to get cached data first
        final cachedUserData = await _loadCachedUserData(session.user.id);
        
        if (cachedUserData != UserData.empty) {
          // Emit immediately with cached data
          emit(Authenticated(session.user.id, cachedUserData, isDataFresh: false));
          
          // Refresh in background
          _refreshUserDataInBackground(session.user.id);
        } else {
          // No cached data, load fresh
          final freshData = await _userRepository.getCurrentUserData();
          if (freshData != UserData.empty) {
            emit(Authenticated(session.user.id, freshData, isDataFresh: true));
          } else {
            emit(Unauthenticated());
          }
        }
        
        // Initialize other services
        await _settingsRepository.initializeSettingsStream();
        await _setupUserSubscription(session.user.id, emit);
      } catch (e) {
        emit(Unauthenticated());
      }
    } else {
      emit(Unauthenticated());
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

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    _authStateSubscription?.cancel();
    return super.close();
  }
}