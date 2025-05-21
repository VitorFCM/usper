part of 'ride_creation_controller.dart';

sealed class RideCreationState {
  const RideCreationState();
}

final class InitialRideCreationState extends RideCreationState {}

final class RideCreationStateError extends RideCreationState {
  const RideCreationStateError(this.errorMessage);

  final String errorMessage;
}

final class DepartureTimeSetState extends RideCreationState {
  const DepartureTimeSetState(this.departTime);

  final DateTime departTime;
}

abstract class LocationSetState extends RideCreationState {
  LocationSetState(
    this.address,
    this.location, {
    this.route,
  });

  final String address;
  final LatLng location;
  final List<LatLng>? route;
}

final class OriginLocationSetState extends LocationSetState {
  OriginLocationSetState(
    super.address,
    super.location, {
    super.route,
  });
}

final class DestLocationSetState extends LocationSetState {
  DestLocationSetState(
    super.address,
    super.location, {
    super.route,
  });
}

final class RideVehicleDefined extends RideCreationState {
  RideVehicleDefined(this.vehicle);

  final Vehicle vehicle;
}

final class RideCreated extends RideCreationState {
  RideCreated({required this.ride});
  RideData ride;
}

final class RideDataCleared extends RideCreationState {}

final class DriverAlreadyHaveARide extends RideCreationState {
  DriverAlreadyHaveARide({required this.oldRide});
  RideData oldRide;
}
