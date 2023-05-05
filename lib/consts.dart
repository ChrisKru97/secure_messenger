import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? globalPin;
String? globalKey;
final iv = IV.fromLength(16);

const collectionName = "messages_v2";

class Base64WithPin {
  Base64WithPin(this.value, this.pin, this.key);

  String value;
  String pin;
  String key;
}

class BytesWithPin {
  BytesWithPin(this.value, this.pin, this.key);

  Uint8List value;
  String pin;
  String key;
}

const keyStorageKey = "@key";

readKeyFromStorage() async {
  final sharedPrefs = await SharedPreferences.getInstance();
  globalKey = sharedPrefs.getString(keyStorageKey);
}

void setKey(String key) async {
  globalKey = key;
  final sharedPrefs = await SharedPreferences.getInstance();
  sharedPrefs.setString(keyStorageKey, key);
}

void setPin(String pin) async {
  globalPin = pin;
}

String? getPin() => globalPin;
String? getKey() => globalKey;

Encrypter getEncrypter(String pin, String base64key) {
  final keyPart = base64Decode(base64key);
  for (var i = 0; i < pin.length; i++) {
    keyPart[i] = (keyPart[i] + int.parse(pin[i])) % 255;
  }
  final key = Key(keyPart);
  return Encrypter(AES(key));
}

String encrypt(Base64WithPin base64withPin) {
  final encrypter = getEncrypter(base64withPin.pin, base64withPin.key);
  return encrypter.encrypt(base64withPin.value, iv: iv).base64;
}

String decrypt(Base64WithPin base64withPin) {
  try {
    final encrypter = getEncrypter(base64withPin.pin, base64withPin.key);
    return encrypter.decrypt64(base64withPin.value, iv: iv);
  } catch (e) {
    return "Nelze dešifrovat";
  }
}

Uint8List encryptBytes(BytesWithPin bytesWithPin) {
  final encrypter = getEncrypter(bytesWithPin.pin, bytesWithPin.key);
  return encrypter.encryptBytes(bytesWithPin.value, iv: iv).bytes;
}

Uint8List decryptBytes(BytesWithPin bytesWithPin) {
  try {
    final encrypter = getEncrypter(bytesWithPin.pin, bytesWithPin.key);
    return Uint8List.fromList(
        encrypter.decryptBytes(Encrypted(bytesWithPin.value), iv: iv));
  } catch (e) {
    return Uint8List(0);
  }
}
