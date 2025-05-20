part of 'ride_dashboard_controller.dart';

sealed class RideDashboardState {
  const RideDashboardState();
}

class RideDashboardInitialState extends RideDashboardState {
  const RideDashboardInitialState();
}

class LoadingState extends RideDashboardState {}

class RideFinishedState extends RideDashboardState {}
