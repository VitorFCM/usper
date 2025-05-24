part of 'ride_dashboard_controller.dart';

sealed class RideDashboardEvent {
  const RideDashboardEvent();
}

class SetRide extends RideDashboardEvent {
  SetRide({required this.ride, required this.user});
  RideData ride;
  UsperUser user;
}

class FinishRide extends RideDashboardEvent {}

class PassengerGiveUp extends RideDashboardEvent {}
