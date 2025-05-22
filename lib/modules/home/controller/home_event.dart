part of 'home_controller.dart';

sealed class HomeScreenEvent {
  const HomeScreenEvent();
}

class RideCreated extends HomeScreenEvent {
  RideCreated({required this.rideData});
  RideData rideData;
}

class RemoveRide extends HomeScreenEvent {
  RemoveRide({required this.rideId});
  String rideId;
}

class LoadInitialRides extends HomeScreenEvent {}

class CreateRide extends HomeScreenEvent {
  CreateRide({required this.rideId});
  String rideId;
}

final class DeleteOldRideAndCreateNew extends HomeScreenEvent {
  DeleteOldRideAndCreateNew({required this.oldRideId});
  String oldRideId;
}

final class KeepOldRide extends HomeScreenEvent {
  KeepOldRide({required this.oldRide});
  RideData oldRide;
}

final class SetDestination extends HomeScreenEvent {
  SetDestination({required this.pickedData});
  PickedData pickedData;
}
