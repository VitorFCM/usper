part of 'ride_creation_controller.dart';

sealed class RideCreationEvent {
  const RideCreationEvent();
}

final class SeatsCounterIncreased extends RideCreationEvent {
  const SeatsCounterIncreased();
}

final class SeatsCounterDecreased extends RideCreationEvent {
  const SeatsCounterDecreased();
}

final class RideCreationFinished extends RideCreationEvent {
  const RideCreationFinished(this.originName, this.destName);

  final String? originName;
  final String? destName;
}

final class SetDepartureTime extends RideCreationEvent {
  const SetDepartureTime(this.departTime);

  final DateTime departTime;
}

abstract class SetLocationData extends RideCreationEvent {
  SetLocationData(this.locationData);

  PickedData locationData;
}

final class SetOriginData extends SetLocationData {
  SetOriginData(super.locationData);
}

final class SetDestinationData extends SetLocationData {
  SetDestinationData(super.locationData);
}

final class SetVehicleColor extends RideCreationEvent {
  SetVehicleColor(this.vehicleColor, this.colorName);

  final Color vehicleColor;
  final String colorName;
}

final class VehicleDataReady extends RideCreationEvent {
  VehicleDataReady(this.vehiclePlate, this.driver);
  final String vehiclePlate;
  final UsperUser? driver;
}

final class RetrieveVehiclesList extends RideCreationEvent {
  RetrieveVehiclesList(this.driverEmail);
  final String driverEmail;
}

final class VehicleChosed extends RideCreationEvent {
  VehicleChosed(this.vehicle);
  final Vehicle vehicle;
}

final class VehicleTypeSwitched extends RideCreationEvent {
  VehicleTypeSwitched(this.isCar);
  final bool isCar;
}

final class VehicleMakerSelected extends RideCreationEvent {
  VehicleMakerSelected(this.vehicleMaker);
  final String vehicleMaker;
}

final class VehicleModelSelected extends RideCreationEvent {
  VehicleModelSelected(this.vehicleModel);
  final String vehicleModel;
}
