part of 'ride_creation_controller.dart';

sealed class RideCreationEvent {
  const RideCreationEvent();
}

final class RideCreationFinished extends RideCreationEvent {
  RideCreationFinished(this.driver);
  final UsperUser? driver;
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

final class VehicleRideChosed extends RideCreationEvent {
  VehicleRideChosed(this.vehicle);
  final Vehicle vehicle;
}

final class RideCanceled extends RideCreationEvent {}

final class DeleteOldRideAndCreateNew extends RideCreationEvent {
  DeleteOldRideAndCreateNew({required this.oldRide});
  RideData oldRide;
}

final class KeepOldRide extends RideCreationEvent {
  KeepOldRide({required this.oldRide});
  RideData oldRide;
}
