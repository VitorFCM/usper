part of 'passengers_selection_controller.dart';

sealed class PassengersSelectionState {
  const PassengersSelectionState();
}

class InitialPassengersSelectionState extends PassengersSelectionState {}

class RequestAcceptedState extends PassengersSelectionState {
  RequestAcceptedState({required this.passenger});
  UsperUser passenger;
}

class RequestCancelledState extends PassengersSelectionState {
  RequestCancelledState({required this.passengerEmail});
  String passengerEmail;
}

class RequestCreatedState extends PassengersSelectionState {
  RequestCreatedState({required this.passenger});
  UsperUser passenger;
}

class RequestRefusedState extends PassengersSelectionState {
  RequestRefusedState({required this.passengerEmail});
  String passengerEmail;
}

class RideCanceledState extends PassengersSelectionState {}

class PassengersRetrievedState extends PassengersSelectionState {
  PassengersRetrievedState({required this.approved, required this.requests});
  Map<String, UsperUser> approved;
  Map<String, UsperUser> requests;
}

class Loading extends PassengersSelectionState {}

class RideStartedState extends PassengersSelectionState {}
