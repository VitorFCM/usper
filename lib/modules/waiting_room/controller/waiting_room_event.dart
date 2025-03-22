part of 'waiting_room_controller.dart';

sealed class WaitingRoomEvent {
  const WaitingRoomEvent();
}

class CreateRideRequest extends WaitingRoomEvent {
  RideData ride;
  CreateRideRequest({required this.ride});
}

class FetchAcceptedRideRequests extends WaitingRoomEvent {}

class NewRequestAccepted extends WaitingRoomEvent {
  NewRequestAccepted({required this.passenger});
  UsperUser passenger;
}

class RequestCancelled extends WaitingRoomEvent {
  RequestCancelled({required this.passengerEmail});
  String passengerEmail;
}

class CancelRideRequest extends WaitingRoomEvent {}
