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
  RemoveRideRecordState({required this.rideData});
  RideData rideData;
}

class InitialRidesLoaded extends HomeScreenState {
  InitialRidesLoaded({required this.rides});
  Map<String, RideData> rides;
}
