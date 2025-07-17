// import 'package:app/modules/core/di/service_locator.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:app/modules/core/services/api/i_api_service.dart';
// import 'onboarding_event.dart';
// import 'onboarding_state.dart';


// class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
//   final IApiService _apiService;

//   OnboardingBloc() : _apiService = sl<IApiService>(),
//        super(OnboardingInitial()) {
//     on<CompleteOnboarding>(_onCompleteOnboarding);
//   }

//   Future<void> _onCompleteOnboarding(
//     CompleteOnboarding event,
//     Emitter<OnboardingState> emit,
//   ) async {
//     emit(OnboardingLoading());
//     print(event.payload.toJson());
//     try {
//       await _apiService.request(
//         endpoint: '/user/complete-onboarding',
//         method: 'POST',
//         body: event.payload.toJson(),
//         fromJson: (json) => json['success'],
//       );
//       emit(OnboardingComplete());
//     } catch (e) {
//       emit(OnboardingError(e.toString()));
//     }
//   }
// } 