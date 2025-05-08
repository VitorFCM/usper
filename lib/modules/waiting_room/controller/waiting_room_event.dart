part of 'waiting_room_controller.dart';

sealed class WaitingRoomEvent {
  const WaitingRoomEvent();
}

class CreateRideRequest extends WaitingRoomEvent {
  RideData ride;
  CreateRideRequest({required this.ride});
}

class NewRequestAccepted extends WaitingRoomEvent {
  NewRequestAccepted({required this.passenger});
  UsperUser passenger;
}

class RequestCancelled extends WaitingRoomEvent {
  RequestCancelled({required this.passengerEmail});
  String passengerEmail;
}

class CancelRideRequest extends WaitingRoomEvent {}

class RequestRefused extends WaitingRoomEvent {}

class ClearState extends WaitingRoomEvent {}

class DeleteOldRequestAndCreateNew extends WaitingRoomEvent {
  DeleteOldRequestAndCreateNew({required this.oldRide, required this.newRide});
  RideData oldRide;
  RideData newRide;
}

class KeepOldRequest extends WaitingRoomEvent {
  KeepOldRequest({required this.oldRide});
  RideData oldRide;
}

class RideStarted extends WaitingRoomEvent {}

class RideCanceled extends WaitingRoomEvent {}
