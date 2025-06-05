import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/oaep.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:usper/services/cryptography/cryptography_interface.dart';

class EncryptService implements CryptographyInterface {
  RSAPublicKey? _publicKey;
  RSAPrivateKey? _privateKey;
  encrypt.Key? _chatKey; // AES 256

  @override
  Map<String, String> getPublicKey() {
    if (_publicKey == null) {
      final pair = _generateRSAKeyPair();
      _publicKey = pair.publicKey;
      _privateKey = pair.privateKey;
    }

    return {
      'modulus': _publicKey!.modulus.toString(),
      'exponent': _publicKey!.exponent.toString(),
    };
  }

  @override
  void generateChatKey() {
    _chatKey = encrypt.Key.fromSecureRandom(32); // 32 bytes = AES 256
  }

  @override
  String encryptChatKeyForPassenger(Map<String, String> passengerPublicKey) {
    if (_chatKey == null) throw Exception("Chat key not initialized.");

    final oaep = OAEPEncoding(RSAEngine())
      ..init(
          true,
          PublicKeyParameter<RSAPublicKey>(RSAPublicKey(
            BigInt.parse(passengerPublicKey['modulus']!),
            BigInt.parse(passengerPublicKey['exponent']!),
          )));

    return base64Encode(oaep.process(_chatKey!.bytes));
  }

  @override
  void decryptChatKeyFromDriver(String encryptedChatKey) {
    if (_privateKey == null) throw Exception("Private key not initialized.");

    final oaep = OAEPEncoding(RSAEngine())
      ..init(false, PrivateKeyParameter<RSAPrivateKey>(_privateKey!));

    final decrypted = oaep.process(base64Decode(encryptedChatKey));
    _chatKey = encrypt.Key(Uint8List.fromList(decrypted));
  }

  @override
  String encryptMessage(String message) {
    if (_chatKey == null) throw Exception("Chat key not initialized.");

    final iv = encrypt.IV.fromSecureRandom(16);

    final aes = encrypt.Encrypter(encrypt.AES(_chatKey!));
    final encrypted = aes.encrypt(message, iv: iv).base64;

    final result = jsonEncode({
      'iv': iv.base64,
      'message': encrypted,
    });

    return result;
  }

  @override
  String decryptMessage(String encryptedJson) {
    if (_chatKey == null) throw Exception("Chat key not initialized.");
    final parsed = jsonDecode(encryptedJson);
    final iv = encrypt.IV.fromBase64(parsed['iv']);
    final encryptedMessage = parsed['message'];

    final encrypter = encrypt.Encrypter(encrypt.AES(_chatKey!));
    return encrypter.decrypt64(encryptedMessage, iv: iv);
  }

  AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> _generateRSAKeyPair() {
    final generator = RSAKeyGenerator()
      ..init(ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 12),
        _secureRandom(),
      ));
    final pair = generator.generateKeyPair();
    return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(
      pair.publicKey as RSAPublicKey,
      pair.privateKey as RSAPrivateKey,
    );
  }

  SecureRandom _secureRandom() {
    final random = FortunaRandom();
    final seed = List<int>.generate(32, (_) => Random.secure().nextInt(256));
    random.seed(KeyParameter(Uint8List.fromList(seed)));
    return random;
  }
}
