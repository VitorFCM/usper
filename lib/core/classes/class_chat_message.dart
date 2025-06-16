class ChatMessage {
  ChatMessage({
    required this.messageContent,
    DateTime? timestamp,
    required this.userId,
    required this.rideId,
  }) : timestamp = timestamp ?? DateTime.now();

  String messageContent;
  DateTime timestamp;
  String userId;
  String rideId;

  void updateMessageContent(String newMessageContent) {
    messageContent = newMessageContent;
  }
}
