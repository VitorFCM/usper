part of 'home_controller.dart';

sealed class HomeScreenEvent {
  const HomeScreenEvent();
}

class RideCreated extends HomeScreenEvent {
  RideCreated({required this.rideData});
  RideData rideData;
}

class RideUpdatedOrDeleted extends HomeScreenEvent {
  RideUpdatedOrDeleted({required this.rideData});
  RideData rideData;
}

class LoadInitialRides extends HomeScreenEvent {}
