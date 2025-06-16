part of 'chat_controller.dart';

sealed class ChatEvent {
  ChatEvent();
}

class SetRideForChat extends ChatEvent {
  SetRideForChat({required this.ride});
  RideData ride;
}

class PassengerLeft extends ChatEvent {
  PassengerLeft({required this.passengerEmail});
  String passengerEmail;
}

class NewMessage extends ChatEvent {
  NewMessage({required this.chatMessage});
  ChatMessage chatMessage;
}

class SendMessage extends ChatEvent {
  SendMessage({required this.message});
  String message;
}
