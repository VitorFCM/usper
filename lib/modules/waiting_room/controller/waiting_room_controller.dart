import 'package:bloc/bloc.dart';
import 'package:usper/constants/ride_data_event_type.dart';
import 'package:usper/constants/ride_requests_event_type.dart';
import 'package:usper/core/classes/class_ride_data.dart';
import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/modules/home/controller/home_controller.dart';
import 'package:usper/modules/ride_dashboard/controller/ride_dashboard_controller.dart';
import 'package:usper/services/cryptography/cryptography_interface.dart';
import 'package:usper/services/data_repository/repository_exceptions.dart';
import 'package:usper/services/data_repository/repository_interface.dart';

part 'waiting_room_event.dart';
part 'waiting_room_state.dart';

class WaitingRoomController extends Bloc<WaitingRoomEvent, WaitingRoomState> {
  WaitingRoomController(
      {required this.repositoryService,
      required this.cryptographyService,
      required this.user,
      required this.homeController,
      required this.rideDashboardController})
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
    on<RideStarted>(_rideStarted);
    on<RideCanceled>(_rideCanceled);
    on<PassengerAlreadyWaiting>(_setRideForPassengerAlreadyWaiting);
  }

  RepositoryInterface repositoryService;
  CryptographyInterface cryptographyService;
  UsperUser user;
  late RideData ride;
  Map<String, UsperUser> acceptedRideRequests = {};
  HomeController homeController;
  RideDashboardController rideDashboardController;

  void _createRideRequest(
      CreateRideRequest event, Emitter<WaitingRoomState> emit) async {
    emit(Loading());

    try {
      await repositoryService.insertRideRequest(
          event.ride, user, cryptographyService.getPublicKey());
      ride = event.ride;
      emit(RideRequestCreatedState(ride: ride));
      await _fetchAcceptedRideRequests(emit);
      _startListeningRideEvents();
    } on PassengerAlreadyRequestedARideException catch (e) {
      RideData? rideAlreadyRequested =
          await repositoryService.getRide(e.rideId);
      if (rideAlreadyRequested != null) {
        emit(PassengerAlreadyHaveARequest(ride: rideAlreadyRequested));
      } else {}
    } on RideWasAlreadyDeleted {
      emit(ErrorMessage(
          message: "Parece que o motorista desistiu de oferecer a carona"));
    }
  }

  void _deleteOldRequestAndCreateNew(DeleteOldRequestAndCreateNew event,
      Emitter<WaitingRoomState> emit) async {
    emit(Loading());

    cryptographyService.deletePublicKey();

    try {
      await repositoryService.deleteRideRequest(
          event.oldRide.driver.email, user.email);
      await repositoryService.insertRideRequest(
          event.newRide, user, cryptographyService.getPublicKey());
      ride = event.newRide;
      emit(RideRequestCreatedState(ride: ride));
      await _fetchAcceptedRideRequests(emit);
      _startListeningRideEvents();
    } on PassengerAlreadyRequestedARideException catch (e) {
      RideData? r = await repositoryService.getRide(e.rideId);
      emit(PassengerAlreadyHaveARequest(ride: r!));
    }
  }

  void _keepOldRequest(
      KeepOldRequest event, Emitter<WaitingRoomState> emit) async {
    ride = event.oldRide;
    if (ride.started ?? false) {
      rideDashboardController.add(SetRide(ride: ride, user: user));
      emit(RideStartedState());
    } else {
      emit(RideRequestCreatedState(ride: ride));
      await _fetchAcceptedRideRequests(emit);
      _startListeningRideEvents();
    }
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
    emit(RideCanceledState());
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

  void _rideStarted(RideStarted event, Emitter<WaitingRoomState> emit) {
    emit(Loading());
    _stopListeningRideEvents();
    rideDashboardController.add(SetRide(ride: ride, user: user));
    emit(RideStartedState());
  }

  void _setRideForPassengerAlreadyWaiting(
      PassengerAlreadyWaiting event, Emitter<WaitingRoomState> emit) async {
    ride = event.ride;
    await _fetchAcceptedRideRequests(emit);
    _startListeningRideEvents();
  }

  void _startListeningRideEvents() async {
    final rideEventsStream =
        await repositoryService.startRideEventsStream(ride.driver.email);

    rideEventsStream.listen((rideDataEvent) {
      switch (rideDataEvent) {
        case RideDataEventType.created:
          break;
        case RideDataEventType.started:
          add(RideStarted());
        case RideDataEventType.deleted:
          add(RideCanceled());
      }
    });

    final rideRequestsStream =
        await repositoryService.startRideRequestsStream(ride.driver.email);

    rideRequestsStream.listen((rideDataEvent) {
      switch (rideDataEvent.key) {
        case RideRequestsEventType.accepted:
          add(NewRequestAccepted(passenger: rideDataEvent.value as UsperUser));
          break;

        case RideRequestsEventType.cancelled:
          if (rideDataEvent.value as String != user.email) {
            add(RequestCancelled(
                passengerEmail: rideDataEvent.value as String));
          }
          break;

        case RideRequestsEventType.refused:
          if (rideDataEvent.value as String == user.email) {
            add(RequestRefused());
          }
          break;

        case RideRequestsEventType.requested:
          break;
        case RideRequestsEventType.chatKeyProvided:
          break;
      }
    });
  }

  void _stopListeningRideEvents() {
    repositoryService.stopRideEventsStream();
    repositoryService.stopRideRequestsStream();
  }
}
