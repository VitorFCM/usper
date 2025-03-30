part of 'ride_creation_controller.dart';

sealed class RideCreationState {
  const RideCreationState();
}

final class InitialRideCreationState extends RideCreationState {}

final class RideCreationStateError extends RideCreationState {
  const RideCreationStateError(this.errorMessage);

  final String errorMessage;
}

final class DepartureTimeSetted extends RideCreationState {
  const DepartureTimeSetted(this.departTime);

  final DateTime departTime;
}

abstract class LocationSetted extends RideCreationState {
  LocationSetted(this.address, this.location);

  final String address;
  final LatLng location;
}

final class OriginLocationSetted extends LocationSetted {
  OriginLocationSetted(super.address, super.location);
}

final class DestLocationSetted extends LocationSetted {
  DestLocationSetted(super.address, super.location);
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
