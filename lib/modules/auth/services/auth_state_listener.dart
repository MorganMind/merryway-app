import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/modules/core/di/service_locator.dart';

class AuthStateListener {
  final SupabaseClient _supabase = sl<SupabaseClient>();
  final _authStateController = StreamController<AuthState>.broadcast();

  Stream<AuthState> get authStateChanges => _authStateController.stream;

  void initialize() {
    _supabase.auth.onAuthStateChange.listen((data) {
      _authStateController.add(data);
    });
  }

  void dispose() {
    _authStateController.close();
  }
} 