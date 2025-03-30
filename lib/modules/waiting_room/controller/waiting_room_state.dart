part of 'waiting_room_controller.dart';

sealed class WaitingRoomState {
  const WaitingRoomState();
}

class InitialWaitingRoomState extends WaitingRoomState {}

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

class RequestRefusedState extends WaitingRoomState {}
