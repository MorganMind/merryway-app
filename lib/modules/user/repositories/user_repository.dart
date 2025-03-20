import 'dart:async';
// import 'dart:convert';
import 'package:app/modules/core/services/api/i_api_service.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/modules/user/models/user_data.dart';
import 'package:app/modules/core/di/service_locator.dart';
import 'package:app/modules/user/models/user_data_update.dart';

class UserRepository {
  // final SupabaseClient _supabase = sl<SupabaseClient>();
  final IApiService _apiService = sl<IApiService>();

  StreamController<UserData> _controller = StreamController<UserData>.broadcast();
  UserData _cachedUserData = UserData.empty;
  // RealtimeChannel? _userChannel;

  // Expose stream of user data updates
  Stream<UserData> get currentUser => _controller.stream;

  // Synchronous getter for cached user data
  UserData? get userData => _cachedUserData;

  // Initialize the stream for a specific user
  Future<void> initializeUserStream(String userId) async {
    if (_controller.isClosed) {
      _controller = StreamController<UserData>.broadcast();
    }

    // Cancel any existing subscription
    // await _userChannel?.unsubscribe();
    
    try {
      // Get initial user data
      final data = await getCurrentUserData();

      _cachedUserData = data;
      _controller.add(data);

      // Subscribe to realtime updates using .on() method
      // _userChannel = _supabase
      //     .channel('public:user_data')
      //     .onPostgresChanges(
      //       event: PostgresChangeEvent.update,
      //       schema: 'public',
      //       table: 'user_data',
      //       filter: PostgresChangeFilter(
      //         type: PostgresChangeFilterType.eq, 
      //         column: 'id', 
      //         value: userId
      //       ),
      //       callback:(payload) {
      //         try {
      //           print('NEW USER DATA: Payload: ${payload.newRecord}');
      //           final newData = UserData.fromJson(payload.newRecord);
      //           _cachedUserData = newData;
      //           if (!_controller.isClosed) {
      //             _controller.add(newData);
      //           }
      //         } catch (e) {
      //           print('UserRepository: Error handling realtime event: $e');
      //         }
      //       },
      //     )
      //     .subscribe(
      //       (status, [ref]) {
      //         print('UserRepository: Channel status: $status ${ref?.toString()}');
      //       }
      //       // onError: (error) {
      //       //   print('UserRepository: Channel error: $error');
      //       // },
      //     );

    } catch (e) {
      print('UserRepository: Error initializing user stream: $e');
      if (!_controller.isClosed) {
        _controller.addError(e);
      }
    }
  }

  // Clean up resources
  Future<void> dispose() async {
    _cachedUserData = UserData.empty;
    // await _userChannel?.unsubscribe();
    await _controller.close();
  }

  // Add this method to the existing UserRepository class
  Future<UserData> updateUserData(UserDataUpdate update) async {
    final updatedData = await _apiService.request(
      endpoint: '/user/data/update',
      method: 'PATCH',
      body: update.toJson(),
      fromJson: (json) => UserData.fromJson(json),
    );
    
    return updatedData;
  }

  // Add this method to get current user data without setting up stream
  Future<UserData> getCurrentUserData() async {
    try {
      final data = await _apiService.request(
        endpoint: '/user/data',
        method: 'GET',
        fromJson: (json) => UserData.fromJson(json),
      );

      return data;
    } catch (e) {
      print('UserRepository: Error getting current user data: $e');
      return UserData.empty;
    }
  }
}