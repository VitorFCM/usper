import 'package:bloc/bloc.dart';
import 'package:usper/constants/ride_requests_event_type.dart';
import 'package:usper/core/classes/class_ride_data.dart';
import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/modules/ride_dashboard/controller/ride_dashboard_controller.dart';
import 'package:usper/services/data_repository/repository_interface.dart';

part 'passengers_selection_event.dart';
part 'passengers_selection_state.dart';

class PassengersSelectionController
    extends Bloc<PassengersSelectionEvent, PassengersSelectionState> {
  Map<String, UsperUser> approved = {};
  Map<String, UsperUser> requests = {};

  PassengersSelectionController(
      {required this.repositoryService, required this.rideDashboardController})
      : super(InitialPassengersSelectionState()) {
    on<SetRideData>(_setRideData);
    on<RequestAccepted>(_acceptPassenger);
    on<RequestCancelled>((event, emit) =>
        emit(RequestCancelledState(passengerEmail: event.passengerEmail)));
    on<RequestCreated>(
        (event, emit) => emit(RequestCreatedState(passenger: event.passenger)));
    on<RequestRefused>(_refusePassenger);
    on<CancelRide>(_cancelRide);
    on<StartRide>(_startRide);
  }

  RepositoryInterface repositoryService;
  RideDashboardController rideDashboardController;
  late RideData ride;

  void _setRideData(
      SetRideData event, Emitter<PassengersSelectionState> emit) async {
    ride = event.ride;
    _startListeningRideRequests(ride.driver.email);

    List<MapEntry<bool?, UsperUser>> rideRequests =
        await repositoryService.fetchAllRideRequests(ride.driver.email);

    for (var entry in rideRequests) {
      if (entry.key == null) {
        requests[entry.value.email] = entry.value;
      } else if (entry.key!) {
        approved[entry.value.email] = entry.value;
      }
    }
    emit(PassengersRetrievedState(approved: approved, requests: requests));
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

  void _cancelRide(
      CancelRide event, Emitter<PassengersSelectionState> emit) async {
    _stopListeningRideRequests();
    await repositoryService.deleteRide(ride.driver.email);
    approved.clear();
    requests.clear();
    emit(RideCanceledState());
  }

  void _startListeningRideRequests(String rideId) {
    repositoryService.startRideRequestsStream(rideId).listen((rideDataEvent) {
      switch (rideDataEvent.key) {
        case RideRequestsEventType.accepted:
          UsperUser passenger = rideDataEvent.value as UsperUser;
          requests.remove(passenger.email);
          approved[passenger.email] = passenger;
          break;
        case RideRequestsEventType.cancelled:
          String passengerEmail = rideDataEvent.value as String;
          requests.remove(passengerEmail);
          approved.remove(passengerEmail);
          add(RequestCancelled(passengerEmail: passengerEmail));
        case RideRequestsEventType.requested:
          UsperUser passenger = rideDataEvent.value as UsperUser;
          requests[passenger.email] = passenger;
          approved.remove(passenger.email);
          add(RequestCreated(passenger: rideDataEvent.value as UsperUser));
        case RideRequestsEventType.refused:
          String passengerEmail = rideDataEvent.value as String;
          requests.remove(passengerEmail);
          approved.remove(passengerEmail);
          break;
      }
    });
  }

  void _startRide(StartRide event, Emitter<PassengersSelectionState> emit) {
    emit(Loading());
    _stopListeningRideRequests();
    rideDashboardController.add(SetRide(ride: ride, user: ride.driver));
    emit(RideStartedState());
  }

  void _stopListeningRideRequests() {
    repositoryService.stopRideRequestsStream();
  }
}
