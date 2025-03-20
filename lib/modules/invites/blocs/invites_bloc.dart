import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/modules/core/di/service_locator.dart';
import 'package:app/modules/invites/repositories/invites_repository.dart';
import 'invites_event.dart';
import 'invites_state.dart';

class InvitesBloc extends Bloc<InvitesEvent, InvitesState> {
  final InvitesRepository _invitesRepository = sl<InvitesRepository>();

  InvitesBloc() : super(const InvitesState()) {
    on<LoadOrganizationInvites>(_onLoadOrganizationInvites);
    on<CreateInvite>(_onCreateInvite);
    on<AcceptInvite>(_onAcceptInvite);
    on<DeclineInvite>(_onDeclineInvite);
    on<DeleteInvite>(_onDeleteInvite);
    on<LoadInvite>(_onLoadInvite);
  }

  Future<void> _onLoadOrganizationInvites(
    LoadOrganizationInvites event,
    Emitter<InvitesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final invites = await _invitesRepository.getOrganizationInvites();
      emit(state.copyWith(
        invites: invites,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> _onCreateInvite(
    CreateInvite event,
    Emitter<InvitesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final invite = await _invitesRepository.createInvite(
        event.email,
        name: event.name,
      );

      final updatedInvites = [...state.invites, invite];
      
      emit(state.copyWith(
        invites: updatedInvites,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> _onAcceptInvite(
    AcceptInvite event,
    Emitter<InvitesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final updatedInvite = await _invitesRepository.acceptInvite(event.inviteId);
      
      final updatedInvites = state.invites.map((invite) {
        return invite.id == updatedInvite.id ? updatedInvite : invite;
      }).toList();

      emit(state.copyWith(
        invites: updatedInvites,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> _onDeclineInvite(
    DeclineInvite event,
    Emitter<InvitesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final updatedInvite = await _invitesRepository.declineInvite(event.inviteId);
      
      final updatedInvites = state.invites.map((invite) {
        return invite.id == updatedInvite.id ? updatedInvite : invite;
      }).toList();

      emit(state.copyWith(
        invites: updatedInvites,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> _onDeleteInvite(
    DeleteInvite event,
    Emitter<InvitesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      await _invitesRepository.deleteInvite(event.inviteId);
      
      final updatedInvites = state.invites.where((invite) => 
        invite.id != event.inviteId
      ).toList();

      emit(state.copyWith(
        invites: updatedInvites,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> _onLoadInvite(
    LoadInvite event,
    Emitter<InvitesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final invite = await _invitesRepository.getInvite(event.inviteId);
      emit(state.copyWith(
        selectedInvite: invite,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }
} 