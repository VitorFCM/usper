import 'dart:collection';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usper/constants/ride_data_event_type.dart';
import 'package:usper/constants/ride_requests_event_type.dart';
import 'package:usper/core/classes/class_chat_message.dart';
import 'package:usper/core/classes/class_ride_data.dart';
import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/services/cryptography/cryptography_exceptions.dart';
import 'package:usper/services/cryptography/cryptography_interface.dart';
import 'package:usper/services/data_repository/repository_interface.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatController extends Bloc<ChatEvent, ChatState> {
  ChatController(
      {required this.cryptographyService,
      required this.repositoryService,
      required this.user})
      : super(InitialChatState()) {
    on<SetRideForChat>(_setupChat);
    on<PassengerLeft>(_passengerLeft);
    on<NewMessage>(_parseNewMessage);
    on<SendMessage>(_sendMessage);
  }

  RepositoryInterface repositoryService;
  CryptographyInterface cryptographyService;
  UsperUser user;
  RideData? ride;
  Map<String, UsperUser> users = {};
  Queue<ChatMessage> receivedMessagesBuffer = Queue<ChatMessage>();
  Queue<ChatMessage> sendMessagesBuffer = Queue<ChatMessage>();
  List<ChatMessage> messages = [];

  void _setupChat(SetRideForChat event, Emitter<ChatState> emit) async {
    ride = event.ride;
    List<MapEntry<UsperUser, Map<String, String>>> usersAndKeys =
        await repositoryService.fetchAcceptedRideRequests(ride!.driver.email);
    _startListeningRideEvents();

    if (ride!.driver.email == user.email) {
      cryptographyService.generateChatKey();
      users[user.email] = user;

      for (var entry in usersAndKeys) {
        UsperUser passenger = entry.key;
        Map<String, String> passengerPublicKey = entry.value;

        users[passenger.email] = passenger;

        repositoryService.updateRideRequestChatKey(
            ride!.driver.email,
            passenger.email,
            cryptographyService.encryptChatKeyForPassenger(passengerPublicKey));
      }
    } else {
      users[ride!.driver.email] = ride!.driver;
      for (var entry in usersAndKeys) {
        UsperUser passenger = entry.key;
        users[passenger.email] = passenger;
      }

      String? chatKey =
          await repositoryService.fetchChatKey(ride!.driver.email, user.email);

      if (chatKey != null) {
        cryptographyService.decryptChatKeyFromDriver(chatKey);
      }
    }
  }

  void _passengerLeft(PassengerLeft event, Emitter<ChatState> emit) {
    UsperUser? passenger = users.remove(event.passengerEmail);

    if (passenger != null) {
      emit(PassengerLeftState(passenger: passenger));
    }

    //if user equal to driver, re generate the chat key and update database
  }

  void _parseNewMessage(NewMessage event, Emitter<ChatState> emit) {
    ChatMessage chatMessage = event.chatMessage;
    try {
      chatMessage.updateMessageContent(
          cryptographyService.decryptMessage(chatMessage.messageContent));
      messages.add(chatMessage);
      emit(NewMessageState(
          user: users[chatMessage.userId]!, chatMessage: chatMessage));
    } on ChatKeyNotInitialized {
      receivedMessagesBuffer.add(chatMessage);
    }
  }

  void _sendMessage(SendMessage event, Emitter<ChatState> emit) {
    try {
      repositoryService.insertMessage(ChatMessage(
          messageContent: cryptographyService.encryptMessage(event.message),
          userId: user.email,
          rideId: ride!.driver.email));
    } on ChatKeyNotInitialized {
      sendMessagesBuffer.add(ChatMessage(
          messageContent: event.message,
          userId: user.email,
          rideId: ride!.driver.email));
    }
  }

  void _startListeningRideEvents() async {
    final rideEventsStream =
        await repositoryService.startChatStream(ride!.driver.email);

    rideEventsStream.listen((message) => add(NewMessage(chatMessage: message)));

    final rideRequestsStream =
        await repositoryService.startRideRequestsStream(ride!.driver.email);

    rideRequestsStream.listen((rideDataEvent) {
      switch (rideDataEvent.key) {
        case RideRequestsEventType.accepted:
          break;

        case RideRequestsEventType.cancelled:
          if (rideDataEvent.value as String != user.email) {
            add(PassengerLeft(passengerEmail: rideDataEvent.value as String));
          }
          break;

        case RideRequestsEventType.refused:
          break;

        case RideRequestsEventType.requested:
          break;

        case RideRequestsEventType.chatKeyProvided:
          String passengerEmail = (rideDataEvent.value as MapEntry).key;
          String chatKey = (rideDataEvent.value as MapEntry).value;

          if (passengerEmail == user.email) {
            cryptographyService.decryptChatKeyFromDriver(chatKey);
          }
          break;
      }
    });
  }

  void _stopListeningRideEvents() {
    repositoryService.stopRideEventsStream();
    repositoryService.stopRideRequestsStream();
  }
}
