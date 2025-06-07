part of 'vehicle_configuration_controller.dart';

sealed class VehicleConfigurationState {
  VehicleConfigurationState();
}

final class SeatsCounterNewValue extends VehicleConfigurationState {
  SeatsCounterNewValue(this.seats);

  final int seats;
}

final class VehicleConfigurationStateError extends VehicleConfigurationState {
  VehicleConfigurationStateError(this.errorMessage);

  final String errorMessage;
}

final class VehicleColorSetted extends VehicleConfigurationState {
  VehicleColorSetted(this.vehicleColor, this.colorName);

  final Color vehicleColor;
  final String colorName;
}

final class VehiclesListRetrieved extends VehicleConfigurationState {
  VehiclesListRetrieved(this.vehiclesList);

  final List<Vehicle> vehiclesList;
}

final class VehicleDefined extends VehicleConfigurationState {}

final class VehicleMakersRetrieved extends VehicleConfigurationState {
  VehicleMakersRetrieved(this.isCar, this.vehicleMakers);
  final bool isCar;
  final List<String> vehicleMakers;
}

final class VehicleModelsRetrieved extends VehicleConfigurationState {
  VehicleModelsRetrieved(this.vehicleModels);
  final List<String> vehicleModels;
}

final class VehicleModelDefined extends VehicleConfigurationState {}
