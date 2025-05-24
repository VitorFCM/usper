import 'dart:collection';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:usper/constants/ride_data_event_type.dart';
import 'package:usper/core/classes/class_ride_data.dart';
import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/services/data_repository/repository_interface.dart';
import 'package:usper/utils/displayable_address.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeController extends Bloc<HomeScreenEvent, HomeScreenState> {
  RepositoryInterface repositoryService;
  PickedData? destinationData;
  Map<String, RideData> _rides = {};
  UsperUser user;

  HomeController({required this.repositoryService, required this.user})
      : super(InitialHomeScreenState()) {
    on<RideCreated>(_provideNewRide);
    on<RemoveRide>(_updateRidesCollection);
    on<LoadInitialRides>(_fetchAllAvaiableRides);
    on<CreateRide>(_checkIfThereIsARide);
    on<DeleteOldRideAndCreateNew>(_deleteOldRideAndCreateNew);
    on<KeepOldRide>(
      (event, emit) => emit(KeepOldRideState(oldRide: event.oldRide)),
    );
    on<SetDestination>(_setDestination);

    repositoryService.avaiableRidesStream().listen((rideDataEvent) {
      switch (rideDataEvent.key) {
        case RideDataEventType.created:
          if (rideDataEvent.value.driver.email != user.email) {
            add(RideCreated(rideData: rideDataEvent.value));
          }
        case RideDataEventType.started:
        case RideDataEventType.deleted:
          add(RemoveRide(rideId: rideDataEvent.value.driver.email));
      }
    });

    add(LoadInitialRides());
  }

  void _provideNewRide(RideCreated event, Emitter<HomeScreenState> emit) {
    emit(InsertRideRecordState(rideData: event.rideData));
    _rides[event.rideData.driver.email] = event.rideData;
  }

  void _updateRidesCollection(RemoveRide event, Emitter<HomeScreenState> emit) {
    emit(RemoveRideRecordState(rideId: event.rideId));
    _rides.remove(event.rideId);
  }

  void _fetchAllAvaiableRides(
      LoadInitialRides event, Emitter<HomeScreenState> emit) async {
    _rides = await repositoryService.fetchAllAvaiableRides();
    _rides.remove(user.email);
    emit(InitialRidesLoaded(rides: _rides));
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

  void _setDestination(SetDestination event, Emitter<HomeScreenState> emit) {
    destinationData = event.pickedData;
    emit(DestinationSetState(
        address: displayableAddress(destinationData!.addressData),
        ordenatedRides: _sortLocationsByDistance(destinationData!.latLong)));
  }

  Map<String, RideData> _sortLocationsByDistance(LatLong destination) {
    final sortedEntries = _rides.entries.toList();

    sortedEntries.sort((a, b) {
      final distanceA = Geolocator.distanceBetween(
        destination.latitude,
        destination.longitude,
        a.value.destCoord.latitude,
        a.value.destCoord.longitude,
      );

      final distanceB = Geolocator.distanceBetween(
        destination.latitude,
        destination.longitude,
        b.value.destCoord.latitude,
        b.value.destCoord.longitude,
      );

      return distanceA.compareTo(distanceB);
    });

    return LinkedHashMap.fromEntries(sortedEntries);
  }
}
