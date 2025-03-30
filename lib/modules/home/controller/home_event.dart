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
