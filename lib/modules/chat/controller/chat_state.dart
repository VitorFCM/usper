part of 'chat_controller.dart';

sealed class ChatState {
  ChatState();
}

class InitialChatState extends ChatState {}

class PassengerLeftState extends ChatState {
  PassengerLeftState({required this.passenger});
  UsperUser passenger;
}

class NewMessageState extends ChatState {
  NewMessageState({required this.user, required this.chatMessage});
  UsperUser user;
  ChatMessage chatMessage;
}
