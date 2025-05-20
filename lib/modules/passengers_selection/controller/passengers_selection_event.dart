part of 'passengers_selection_controller.dart';

sealed class PassengersSelectionEvent {
  const PassengersSelectionEvent();
}

class SetRideData extends PassengersSelectionEvent {
  SetRideData({required this.ride});
  RideData ride;
}

class RequestAccepted extends PassengersSelectionEvent {
  RequestAccepted({required this.passenger});
  UsperUser passenger;
}

class RequestCancelled extends PassengersSelectionEvent {
  RequestCancelled({required this.passengerEmail});
  String passengerEmail;
}

class RequestCreated extends PassengersSelectionEvent {
  RequestCreated({required this.passenger});
  UsperUser passenger;
}

class RequestRefused extends PassengersSelectionEvent {
  RequestRefused({required this.passengerEmail});
  String passengerEmail;
}

class CancelRide extends PassengersSelectionEvent {}

class StartRide extends PassengersSelectionEvent {}
