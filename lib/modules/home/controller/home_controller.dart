import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usper/constants/ride_data_event_type.dart';
import 'package:usper/core/classes/class_ride_data.dart';
import 'package:usper/services/data_repository/repository_interface.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeController extends Bloc<HomeScreenEvent, HomeScreenState> {
  RepositoryInterface repositoryService;

  HomeController({required this.repositoryService})
      : super(InitialHomeScreenState()) {
    on<RideCreated>(_provideNewRide);
    on<RemoveRide>(_updateRidesCollection);
    on<LoadInitialRides>(_fetchAllAvaiableRides);
    on<CreateRide>(_checkIfThereIsARide);
    on<DeleteOldRideAndCreateNew>(_deleteOldRideAndCreateNew);
    on<KeepOldRide>(
      (event, emit) => emit(KeepOldRideState(oldRide: event.oldRide)),
    );

    repositoryService.avaiableRidesStream().listen((rideDataEvent) {
      switch (rideDataEvent.key) {
        case RideDataEventType.created:
          add(RideCreated(rideData: rideDataEvent.value));
        case RideDataEventType.started:
        case RideDataEventType.deleted:
          add(RemoveRide(rideId: rideDataEvent.value.driver.email));
      }
    });

    add(LoadInitialRides());
  }

  void _provideNewRide(RideCreated event, Emitter<HomeScreenState> emit) {
    emit(InsertRideRecordState(rideData: event.rideData));
  }

  void _updateRidesCollection(RemoveRide event, Emitter<HomeScreenState> emit) {
    emit(RemoveRideRecordState(rideId: event.rideId));
  }

  void _fetchAllAvaiableRides(
      LoadInitialRides event, Emitter<HomeScreenState> emit) async {
    emit(InitialRidesLoaded(
        rides: await repositoryService.fetchAllAvaiableRides()));
  }

  void _checkIfThereIsARide(
      CreateRide event, Emitter<HomeScreenState> emit) async {
    RideData? ride = await repositoryService.getRide(event.rideId);

    if (ride != null) {
      emit(UserAlreadyCreatedARide(ride: ride));
    } else {
      emit(FollowToRideCreation());
    }
  }

  void _deleteOldRideAndCreateNew(
      DeleteOldRideAndCreateNew event, Emitter<HomeScreenState> emit) async {
    try {
      await repositoryService.deleteRide(event.oldRideId);
      emit(FollowToRideCreation());
    } catch (e) {
      emit(HomeStateError(errorMessage: e.toString()));
    }
  }
}
