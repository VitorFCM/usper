import 'package:bloc/bloc.dart';
import 'package:usper/constants/ride_data_event_type.dart';
import 'package:usper/constants/ride_requests_event_type.dart';
import 'package:usper/core/classes/class_ride_data.dart';
import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/modules/home/controller/home_controller.dart';
import 'package:usper/services/data_repository/repository_exceptions.dart';
import 'package:usper/services/data_repository/repository_interface.dart';

part 'waiting_room_event.dart';
part 'waiting_room_state.dart';

class WaitingRoomController extends Bloc<WaitingRoomEvent, WaitingRoomState> {
  WaitingRoomController(
      {required this.repositoryService,
      required this.user,
      required this.homeController})
      : super(InitialWaitingRoomState()) {
    on<CreateRideRequest>(_createRideRequest);
    on<NewRequestAccepted>((event, emit) =>
        emit(NewRequestAcceptedState(passenger: event.passenger)));
    on<RequestCancelled>((event, emit) =>
        emit(RequestCancelledState(passengerEmail: event.passengerEmail)));
    on<CancelRideRequest>(_cancelRideRequest);
    on<RequestRefused>(_refuseRideRequest);
    on<ClearState>((event, emit) => emit(InitialWaitingRoomState()));
    on<DeleteOldRequestAndCreateNew>(_deleteOldRequestAndCreateNew);
    on<KeepOldRequest>(_keepOldRequest);
    //on<RideStarted>(),
    on<RideCanceled>(_rideCanceled);
  }

  RepositoryInterface repositoryService;
  UsperUser user;
  late RideData ride;
  Map<String, UsperUser> acceptedRideRequests = {};
  HomeController homeController;

  void _createRideRequest(
      CreateRideRequest event, Emitter<WaitingRoomState> emit) async {
    emit(Loading());

    try {
      await repositoryService.insertRideRequest(event.ride, user);
      ride = event.ride;
      emit(RideRequestCreated());
      await _fetchAcceptedRideRequests(emit);
      _startListeningRideEvents();
    } on PassengerAlreadyRequestedARideException catch (e) {
      emit(PassengerAlreadyHaveARequest(
          ride: await repositoryService.getRide(e.rideId)));
    } on RideWasAlreadyDeleted {
      emit(ErrorMessage(
          message: "Parece que o motorista desistiu de oferecer a carona"));
    }
  }

  void _deleteOldRequestAndCreateNew(DeleteOldRequestAndCreateNew event,
      Emitter<WaitingRoomState> emit) async {
    emit(Loading());

    try {
      await repositoryService.deleteRideRequest(
          event.oldRide.driver.email, user.email);
      await repositoryService.insertRideRequest(event.newRide, user);
      ride = event.newRide;
      emit(RideRequestCreated());
      await _fetchAcceptedRideRequests(emit);
      _startListeningRideEvents();
    } on PassengerAlreadyRequestedARideException catch (e) {
      emit(PassengerAlreadyHaveARequest(
          ride: await repositoryService.getRide(e.rideId)));
    }
  }

  void _keepOldRequest(
      KeepOldRequest event, Emitter<WaitingRoomState> emit) async {
    ride = event.oldRide;
    emit(RideRequestCreated());
    await _fetchAcceptedRideRequests(emit);
    _startListeningRideEvents();
  }

  Future<void> _fetchAcceptedRideRequests(
      Emitter<WaitingRoomState> emit) async {
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
    _stopListeningRideEvents();
    await repositoryService.deleteRideRequest(ride.driver.email, user.email);
  }

  void _refuseRideRequest(
      RequestRefused event, Emitter<WaitingRoomState> emit) {
    _stopListeningRideEvents();
    homeController.add(RemoveRide(rideId: ride.driver.email));
    emit(ErrorMessage(
        message: "Infelizmente não foi possível te colocar nessa carona"));
  }

  void _rideCanceled(RideCanceled event, Emitter<WaitingRoomState> emit) {
    _stopListeningRideEvents();
    homeController.add(RemoveRide(rideId: ride.driver.email));
    emit(ErrorMessage(
        message: "Parece que o motorista desistiu de oferecer a carona"));
  }

  void _startListeningRideEvents() {
    repositoryService
        .startRideEventsStream(ride.driver.email)
        .listen((rideDataEvent) {
      switch (rideDataEvent) {
        case RideDataEventType.created:
          break;
        case RideDataEventType.started:
          add(RideStarted());
        case RideDataEventType.deleted:
          add(RideCanceled());
      }
    });

    repositoryService
        .startRideRequestsStream(ride.driver.email)
        .listen((rideDataEvent) {
      switch (rideDataEvent.key) {
        case RideRequestsEventType.accepted:
          add(NewRequestAccepted(passenger: rideDataEvent.value as UsperUser));
        case RideRequestsEventType.cancelled:
          if (rideDataEvent.value as String != user.email) {
            add(RequestCancelled(
                passengerEmail: rideDataEvent.value as String));
          }
        case RideRequestsEventType.refused:
          if (rideDataEvent.value as String == user.email) {
            add(RequestRefused());
          }
        case RideRequestsEventType.requested:
        // Nothing to do
      }
    });
  }

  void _stopListeningRideEvents() {
    repositoryService.stopRideEventsStream();
    repositoryService.stopRideRequestsStream();
  }
}
