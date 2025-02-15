part of 'vehicle_configuration_controller.dart';

sealed class VehicleConfigurationEvent {
  const VehicleConfigurationEvent();
}

final class SeatsCounterIncreased extends VehicleConfigurationEvent {
  const SeatsCounterIncreased();
}

final class SeatsCounterDecreased extends VehicleConfigurationEvent {
  const SeatsCounterDecreased();
}

final class SetVehicleColor extends VehicleConfigurationEvent {
  SetVehicleColor(this.vehicleColor, this.colorName);

  final Color vehicleColor;
  final String colorName;
}

final class VehicleDataReady extends VehicleConfigurationEvent {
  VehicleDataReady(this.vehiclePlate, this.driver);
  final String vehiclePlate;
  final UsperUser? driver;
}

final class RetrieveVehiclesList extends VehicleConfigurationEvent {
  RetrieveVehiclesList(this.driverEmail);
  final String driverEmail;
}

final class VehicleChosed extends VehicleConfigurationEvent {
  VehicleChosed(this.vehicle);
  final Vehicle vehicle;
}

final class VehicleTypeSwitched extends VehicleConfigurationEvent {
  VehicleTypeSwitched(this.isCar);
  final bool isCar;
}

final class VehicleMakerSelected extends VehicleConfigurationEvent {
  VehicleMakerSelected(this.vehicleMaker);
  final String vehicleMaker;
}

final class VehicleModelSelected extends VehicleConfigurationEvent {
  VehicleModelSelected(this.vehicleModel);
  final String vehicleModel;
}
