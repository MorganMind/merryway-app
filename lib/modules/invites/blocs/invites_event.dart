import 'package:equatable/equatable.dart';

abstract class InvitesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadOrganizationInvites extends InvitesEvent {

  LoadOrganizationInvites();

  @override
  List<Object?> get props => [];
}

class CreateInvite extends InvitesEvent {
  final String email;
  final String? name;

  CreateInvite({
    required this.email,
    this.name,
  });

  @override
  List<Object?> get props => [email, name];
}

class AcceptInvite extends InvitesEvent {
  final String inviteId;

  AcceptInvite(this.inviteId);

  @override
  List<Object?> get props => [inviteId];
}

class DeclineInvite extends InvitesEvent {
  final String inviteId;

  DeclineInvite(this.inviteId);

  @override
  List<Object?> get props => [inviteId];
}

class DeleteInvite extends InvitesEvent {
  final String inviteId;

  DeleteInvite(this.inviteId);

  @override
  List<Object?> get props => [inviteId];
}

class LoadInvite extends InvitesEvent {
  final String inviteId;

  LoadInvite(this.inviteId);

  @override
  List<Object?> get props => [inviteId];
} 