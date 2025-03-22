import 'package:bloc/bloc.dart';
import 'package:usper/constants/ride_requests_event_type.dart';
import 'package:usper/core/classes/class_ride_data.dart';
import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/services/data_repository/repository_interface.dart';

part 'waiting_room_event.dart';
part 'waiting_room_state.dart';

class WaitingRoomController extends Bloc<WaitingRoomEvent, WaitingRoomState> {
  WaitingRoomController({required this.repositoryService, required this.user})
      : super(InitialWaitingRoomState()) {
    on<CreateRideRequest>(_createRideRequest);
    on<FetchAcceptedRideRequests>(_fetchAcceptedRideRequests);
    on<NewRequestAccepted>((event, emit) =>
        emit(NewRequestAcceptedState(passenger: event.passenger)));
    on<RequestCancelled>((event, emit) =>
        emit(RequestCancelledState(passengerEmail: event.passengerEmail)));
    on<CancelRideRequest>(_cancelRideRequest);
  }

  RepositoryInterface repositoryService;
  UsperUser user;
  late RideData ride;
  Map<String, UsperUser> acceptedRideRequests = {};

  void _createRideRequest(
      CreateRideRequest event, Emitter<WaitingRoomState> emit) async {
    ride = event.ride;
    await repositoryService.insertRideRequest(ride, user);
    _startListeningRideRequests();
  }

  void _startListeningRideRequests() {
    repositoryService.rideRequestsStream().listen((rideDataEvent) {
      switch (rideDataEvent.key) {
        case RideRequestsEventType.accepted:
          add(NewRequestAccepted(passenger: rideDataEvent.value as UsperUser));
        case RideRequestsEventType.cancelled:
          add(RequestCancelled(passengerEmail: rideDataEvent.value as String));
        case RideRequestsEventType.requested:
        case RideRequestsEventType.refused:
      }
    });
  }

  void _stopListeningRideRequests() {
    repositoryService.stopRideRequestsStream();
  }

  void _fetchAcceptedRideRequests(
      FetchAcceptedRideRequests event, Emitter<WaitingRoomState> emit) async {
    List<MapEntry<bool?, UsperUser>> rideRequests =
        await repositoryService.fetchAllRideRequests(ride.driver.email);

    acceptedRideRequests = {
      for (var entry in rideRequests)
        if (entry.key ?? false) entry.value.email: entry.value
    };

    emit(AllAcceptedRequests(acceptedRequests: acceptedRideRequests));
  }

  void _cancelRideRequest(
      CancelRideRequest event, Emitter<WaitingRoomState> emit) async {
    _stopListeningRideRequests();
    await repositoryService.deleteRideRequest(ride.driver.email, user.email);
  }
}
