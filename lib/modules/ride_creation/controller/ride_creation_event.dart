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
