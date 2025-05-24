part of 'waiting_room_controller.dart';

sealed class WaitingRoomState {
  const WaitingRoomState();
}

class InitialWaitingRoomState extends WaitingRoomState {}

class RideRequestCreated extends WaitingRoomState {}

class AllAcceptedRequests extends WaitingRoomState {
  AllAcceptedRequests({required this.acceptedRequests});
  Map<String, UsperUser> acceptedRequests;
}

class NewRequestAcceptedState extends WaitingRoomState {
  NewRequestAcceptedState({required this.passenger});
  UsperUser passenger;
}

class RequestCancelledState extends WaitingRoomState {
  RequestCancelledState({required this.passengerEmail});
  String passengerEmail;
}

class Loading extends WaitingRoomState {}

class PassengerAlreadyHaveARequest extends WaitingRoomState {
  PassengerAlreadyHaveARequest({required this.ride});
  RideData ride;
}

class ErrorMessage extends WaitingRoomState {
  ErrorMessage({required this.message});
  String message;
}

class RideStartedState extends WaitingRoomState {
  RideStartedState();
}
