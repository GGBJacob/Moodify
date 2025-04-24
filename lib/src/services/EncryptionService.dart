import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  List<int> parsePostgresBytea(String byteaString) {
    if (byteaString.startsWith(r'\x')) {
      final hex = byteaString.substring(2); // usuń "\x"
      return hexToBytes(hex);
    } else {
      throw ArgumentError('Invalid bytea format!');
    }
  }

  List<int> hexToBytes(String hex) {
    final result = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      result.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return result;
  }

  String encryptNote(String note, String userKey) {
    if (note.isEmpty) {
      return note;
    }
    var keyBytes = parsePostgresBytea(userKey);
    final key = Key(Uint8List.fromList(keyBytes));
    final iv = IV.fromSecureRandom(16);

    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

    final encrypted = encrypter.encrypt(note, iv: iv);

    final combined = iv.bytes + encrypted.bytes;

    return base64.encode(combined);
  }

  String decryptNote(String encryptedData, String userKey) {
    if (encryptedData.isEmpty) {
      return encryptedData;
    }
    final combined = base64.decode(encryptedData);
    var keyBytes = parsePostgresBytea(userKey);
    final key = Key(Uint8List.fromList(keyBytes));

    final iv = IV(combined.sublist(0, 16));
    final encryptedBytes = combined.sublist(16);

    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final decrypted = encrypter.decrypt(Encrypted(encryptedBytes), iv: iv);

    return decrypted;
  }
}