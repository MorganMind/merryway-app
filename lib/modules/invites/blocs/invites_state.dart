import 'package:equatable/equatable.dart';
import 'package:app/modules/invites/models/invite.dart';

class InvitesState extends Equatable {
  final List<Invite> invites;
  final Invite? selectedInvite;
  final bool isLoading;
  final String? error;

  const InvitesState({
    this.invites = const [],
    this.selectedInvite,
    this.isLoading = false,
    this.error,
  });

  InvitesState copyWith({
    List<Invite>? invites,
    Invite? selectedInvite,
    bool? isLoading,
    String? error,
  }) {
    return InvitesState(
      invites: invites ?? this.invites,
      selectedInvite: selectedInvite ?? this.selectedInvite,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [invites, selectedInvite, isLoading, error];
} 