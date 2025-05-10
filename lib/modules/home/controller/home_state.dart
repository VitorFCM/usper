part of 'home_controller.dart';

sealed class HomeScreenState {
  const HomeScreenState();
}

class InitialHomeScreenState extends HomeScreenState {}

class InsertRideRecordState extends HomeScreenState {
  InsertRideRecordState({required this.rideData});
  RideData rideData;
}

class RemoveRideRecordState extends HomeScreenState {
  RemoveRideRecordState({required this.rideId});
  String rideId;
}

class InitialRidesLoaded extends HomeScreenState {
  InitialRidesLoaded({required this.rides});
  Map<String, RideData> rides;
}

class UserAlreadyCreatedARide extends HomeScreenState {
  UserAlreadyCreatedARide({required this.ride});
  RideData ride;
}

class FollowToRideCreation extends HomeScreenState {}

class HomeStateError extends HomeScreenState {
  HomeStateError({required this.errorMessage});
  String errorMessage;
}

class KeepOldRideState extends HomeScreenState {
  KeepOldRideState({required this.oldRide});
  RideData oldRide;
}
