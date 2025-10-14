import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/family_models.dart';
import '../repositories/family_repository.dart';

// Events
abstract class FamilyEvent extends Equatable {
  const FamilyEvent();
  @override
  List<Object?> get props => [];
}

class CreateHouseholdEvent extends FamilyEvent {
  final String name;
  const CreateHouseholdEvent(this.name);

  @override
  List<Object?> get props => [name];
}

class FetchHouseholdEvent extends FamilyEvent {
  final String householdId;
  const FetchHouseholdEvent(this.householdId);

  @override
  List<Object?> get props => [householdId];
}

class AddMemberEvent extends FamilyEvent {
  final String householdId;
  final String name;
  final int age;
  final String role;
  final List<String> favoriteActivities;

  const AddMemberEvent({
    required this.householdId,
    required this.name,
    required this.age,
    required this.role,
    required this.favoriteActivities,
  });

  @override
  List<Object?> get props => [householdId, name, age, role, favoriteActivities];
}

class GetSuggestionsEvent extends FamilyEvent {
  final String householdId;
  final String weather;
  final String timeOfDay;
  final String dayOfWeek;
  final String? customPrompt;
  final List<String>? participants;

  const GetSuggestionsEvent({
    required this.householdId,
    required this.weather,
    required this.timeOfDay,
    required this.dayOfWeek,
    this.customPrompt,
    this.participants,
  });

  @override
  List<Object?> get props => [householdId, weather, timeOfDay, dayOfWeek, customPrompt, participants];
}

// States
abstract class FamilyState extends Equatable {
  const FamilyState();
  @override
  List<Object?> get props => [];
}

class FamilyInitial extends FamilyState {}

class FamilyLoading extends FamilyState {}

class HouseholdCreated extends FamilyState {
  final Household household;
  const HouseholdCreated(this.household);

  @override
  List<Object?> get props => [household];
}

class HouseholdLoaded extends FamilyState {
  final Household household;
  const HouseholdLoaded(this.household);

  @override
  List<Object?> get props => [household];
}

class MemberAdded extends FamilyState {
  final FamilyMember member;
  const MemberAdded(this.member);

  @override
  List<Object?> get props => [member];
}

class SuggestionsLoaded extends FamilyState {
  final SuggestionsResponse suggestions;
  const SuggestionsLoaded(this.suggestions);

  @override
  List<Object?> get props => [suggestions];
}

class FamilyError extends FamilyState {
  final String message;
  const FamilyError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class FamilyBloc extends Bloc<FamilyEvent, FamilyState> {
  final FamilyRepository repository;

  FamilyBloc(this.repository) : super(FamilyInitial()) {
    on<CreateHouseholdEvent>(_onCreateHousehold);
    on<FetchHouseholdEvent>(_onFetchHousehold);
    on<AddMemberEvent>(_onAddMember);
    on<GetSuggestionsEvent>(_onGetSuggestions);
  }

  Future<void> _onCreateHousehold(
    CreateHouseholdEvent event,
    Emitter<FamilyState> emit,
  ) async {
    emit(FamilyLoading());
    try {
      final household = await repository.createHousehold(event.name);
      emit(HouseholdCreated(household));
    } catch (e) {
      emit(FamilyError(e.toString()));
    }
  }

  Future<void> _onFetchHousehold(
    FetchHouseholdEvent event,
    Emitter<FamilyState> emit,
  ) async {
    emit(FamilyLoading());
    try {
      final household = await repository.getHousehold(event.householdId);
      if (household != null) {
        emit(HouseholdLoaded(household));
      } else {
        emit(const FamilyError('Household not found'));
      }
    } catch (e) {
      emit(FamilyError(e.toString()));
    }
  }

  Future<void> _onAddMember(
    AddMemberEvent event,
    Emitter<FamilyState> emit,
  ) async {
    emit(FamilyLoading());
    try {
      final member = await repository.addMember(
        event.householdId,
        event.name,
        event.age,
        event.role,
        event.favoriteActivities,
      );
      emit(MemberAdded(member));
    } catch (e) {
      emit(FamilyError(e.toString()));
    }
  }

  Future<void> _onGetSuggestions(
    GetSuggestionsEvent event,
    Emitter<FamilyState> emit,
  ) async {
    emit(FamilyLoading());
    try {
      final suggestions = await repository.getSuggestions(
        householdId: event.householdId,
        weather: event.weather,
        timeOfDay: event.timeOfDay,
        dayOfWeek: event.dayOfWeek,
        customPrompt: event.customPrompt,
        participants: event.participants,
      );
      emit(SuggestionsLoaded(suggestions));
    } catch (e) {
      emit(FamilyError(e.toString()));
    }
  }
}

