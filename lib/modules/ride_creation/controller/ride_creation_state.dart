part of 'ride_creation_controller.dart';

sealed class RideCreationState {
  const RideCreationState();
}

final class SeatsCounterNewValue extends RideCreationState {
  const SeatsCounterNewValue(this.seats);

  final int seats;
}

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

final class VehicleColorSetted extends RideCreationState {
  VehicleColorSetted(this.vehicleColor, this.colorName);

  final Color vehicleColor;
  final String colorName;
}

final class VehiclesListRetrieved extends RideCreationState {
  VehiclesListRetrieved(this.vehiclesList);

  final List<Vehicle> vehiclesList;
}

final class RideVehicleDefined extends RideCreationState {
  RideVehicleDefined(this.vehicle);

  final Vehicle vehicle;
}

final class VehicleMakersRetrieved extends RideCreationState {
  VehicleMakersRetrieved(this.isCar, this.vehicleMakers);
  final bool isCar;
  final List<String> vehicleMakers;
}

final class VehicleModelsRetrieved extends RideCreationState {
  VehicleModelsRetrieved(this.vehicleModels);
  final List<String> vehicleModels;
}

final class VehicleModelDefined extends RideCreationState {}
