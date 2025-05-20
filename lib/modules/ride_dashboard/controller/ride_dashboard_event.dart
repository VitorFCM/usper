part of 'ride_dashboard_controller.dart';

sealed class RideDashboardEvent {
  const RideDashboardEvent();
}

class RideStarted extends RideDashboardEvent {
  RideStarted({required this.ride});
  RideData ride;
}

class FinishRide extends RideDashboardEvent {}
