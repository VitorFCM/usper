abstract interface class CryptographyInterface {
  Map<String, String> getPublicKey();
  void generateChatKey();
  String encryptChatKeyForPassenger(Map<String, String> passengerPublicKey);
  void decryptChatKeyFromDriver(String encryptedChatKey);
  String encryptMessage(String message);
  String decryptMessage(String encryptedJson);
}
