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
