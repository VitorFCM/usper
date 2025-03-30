import 'package:bloc/bloc.dart';
import 'package:usper/constants/ride_requests_event_type.dart';
import 'package:usper/core/classes/class_ride_data.dart';
import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/services/data_repository/repository_interface.dart';

part 'passengers_selection_event.dart';
part 'passengers_selection_state.dart';

class PassengersSelectionController
    extends Bloc<PassengersSelectionEvent, PassengersSelectionState> {
  PassengersSelectionController({required this.repositoryService})
      : super(InitialPassengersSelectionState()) {
    on<SetRideData>((event, emit) {
      ride = event.ride;
      _startListeningRideRequests(ride.driver.email);
    });
    on<RequestAccepted>(_acceptPassenger);
    on<RequestCancelled>((event, emit) =>
        emit(RequestCancelledState(passengerEmail: event.passengerEmail)));
    on<RequestCreated>(
        (event, emit) => emit(RequestCreatedState(passenger: event.passenger)));
    on<RequestRefused>(_refusePassenger);
  }

  RepositoryInterface repositoryService;
  late RideData ride;
  Map<String, UsperUser> acceptedRideRequests = {};

  void _startListeningRideRequests(String rideId) {
    repositoryService.startRideRequestsStream(rideId).listen((rideDataEvent) {
      switch (rideDataEvent.key) {
        case RideRequestsEventType.accepted:
          add(RequestAccepted(passenger: rideDataEvent.value as UsperUser));
        case RideRequestsEventType.cancelled:
          add(RequestCancelled(passengerEmail: rideDataEvent.value as String));
        case RideRequestsEventType.requested:
          add(RequestCreated(passenger: rideDataEvent.value as UsperUser));
        case RideRequestsEventType.refused:
          add(RequestRefused(passengerEmail: rideDataEvent.value as String));
      }
    });
  }

  void _acceptPassenger(
      RequestAccepted event, Emitter<PassengersSelectionState> emit) {
    repositoryService.acceptRideRequest(
        ride.driver.email, event.passenger.email);
    emit(RequestAcceptedState(passenger: event.passenger));
  }

  void _refusePassenger(
      RequestRefused event, Emitter<PassengersSelectionState> emit) {
    repositoryService.refuseRideRequest(
        ride.driver.email, event.passengerEmail);
    emit(RequestRefusedState(passengerEmail: event.passengerEmail));
  }

  void _stopListeningRideRequests() {
    repositoryService.stopRideRequestsStream();
  }
}
