import 'package:app/modules/core/di/service_locator.dart';
import 'package:app/modules/core/services/api/i_api_service.dart';
import 'package:app/modules/invites/models/invite.dart';

class InvitesRepository {
  final IApiService _apiService = sl<IApiService>();

  Future<Invite> createInvite(String email, {String? name}) async {
    try {
      final response = await _apiService.request(
        endpoint: '/organizations/invites/create',
        method: 'POST',
        body: {'email': email, 'name': name},
        fromJson: (json) => Invite.fromJson(json),
      );

      return response;
    } catch (e) {
      throw 'Failed to create invite: $e';
    }
  }

  Future<List<Invite>> getOrganizationInvites() async {
    try {
      final response = await _apiService.request(
        endpoint: '/organizations/invites',
        method: 'GET',
        fromJson: (json) => (json['invites'] as List)
            .map((item) => Invite.fromJson(item))
            .toList(),
      );

      return response;
    } catch (e) {
      throw 'Failed to fetch invites: $e';
    }
  }

  Future<Invite> acceptInvite(String inviteId) async {
    try {
      final response = await _apiService.request(
        endpoint: '/invites/$inviteId/accept',
        method: 'POST',
        fromJson: (json) => Invite.fromJson(json),
      );

      return response;
    } catch (e) {
      throw 'Failed to accept invite: $e';
    }
  }

  Future<Invite> declineInvite(String inviteId) async {
    try {
      final response = await _apiService.request(
        endpoint: '/invites/$inviteId/decline',
        method: 'POST',
        fromJson: (json) => Invite.fromJson(json),
      );

      return response;
    } catch (e) {
      throw 'Failed to decline invite: $e';
    }
  }

  Future<void> deleteInvite(String inviteId) async {
    try {
      await _apiService.request(
        endpoint: '/invites/$inviteId',
        method: 'DELETE',
        fromJson: (json) => json['success'],
      );
    } catch (e) {
      throw 'Failed to delete invite: $e';
    }
  }

  Future<Invite> getInvite(String inviteId) async {
    try {
      final response = await _apiService.request(
        endpoint: 'public/invites/$inviteId/details',
        method: 'GET',
        fromJson: (json) => Invite.fromJson(json),
        isPublic: true,
      );

      return response;
    } catch (e) {
      throw 'Failed to fetch invite: $e';
    }
  }
} 