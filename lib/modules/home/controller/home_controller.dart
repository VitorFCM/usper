import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usper/constants/database_event_type.dart';
import 'package:usper/core/classes/class_ride_data.dart';
import 'package:usper/services/data_repository/repository_interface.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeController extends Bloc<HomeScreenEvent, HomeScreenState> {
  RepositoryInterface repositoryService;

  HomeController({required this.repositoryService})
      : super(InitialHomeScreenState()) {
    on<RideCreated>(_provideNewRide);
    on<RideUpdatedOrDeleted>(_updateRidesCollection);
    on<LoadInitialRides>(_fetchAllAvaiableRides);

    repositoryService.rideDataStream().listen((rideDataEvent) {
      switch (rideDataEvent.key) {
        case DatabaseEventType.insert:
          add(RideCreated(rideData: rideDataEvent.value));
        case DatabaseEventType.update:
        case DatabaseEventType.delete:
          add(RideUpdatedOrDeleted(rideData: rideDataEvent.value));
      }
    });

    add(LoadInitialRides());
  }

  void _provideNewRide(RideCreated event, Emitter<HomeScreenState> emit) {
    emit(InsertRideRecordState(rideData: event.rideData));
  }

  void _updateRidesCollection(
      RideUpdatedOrDeleted event, Emitter<HomeScreenState> emit) {
    emit(RemoveRideRecordState(rideData: event.rideData));
  }

  void _fetchAllAvaiableRides(
      LoadInitialRides event, Emitter<HomeScreenState> emit) async {
    emit(InitialRidesLoaded(
        rides: await repositoryService.fetchAllAvaiableRides()));
  }
}
