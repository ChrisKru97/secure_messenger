import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'key.dart';

String? globalPin;
final iv = IV.fromLength(16);

class Base64WithPin {
  Base64WithPin(this.value, this.pin);

  String value;
  String pin;
}

class BytesWithPin {
  BytesWithPin(this.value, this.pin);

  Uint8List value;
  String pin;
}

String? getPin() => globalPin;

void setPin(String pin) {
  globalPin = pin;
}

Encrypter getEncrypter(String pin) {
  final keyPart = base64Decode(base64keyPart);
  for (var i = 0; i < pin.length; i++) {
    keyPart[i] += int.parse(pin[i]);
  }
  final key = Key(keyPart);
  return Encrypter(AES(key));
}

String encrypt(Base64WithPin base64withPin) {
  final encrypter = getEncrypter(base64withPin.pin);
  return encrypter.encrypt(base64withPin.value, iv: iv).base64;
}

String decrypt(Base64WithPin base64withPin) {
  try {
    final encrypter = getEncrypter(base64withPin.pin);
    return encrypter.decrypt64(base64withPin.value, iv: iv);
  } catch (e) {
    return "Nelze dešifrovat";
  }
}

Uint8List decryptToBytes(Base64WithPin base64withPin) {
  try {
    final bytes = base64Decode(base64withPin.value);
    final encrypter = getEncrypter(base64withPin.pin);
    return Uint8List.fromList(encrypter.decryptBytes(Encrypted(bytes), iv: iv));
  } catch (e) {
    return Uint8List(0);
  }
}

Uint8List encryptBytes(BytesWithPin bytesWithPin) {
  final encrypter = getEncrypter(bytesWithPin.pin);
  return encrypter.encryptBytes(bytesWithPin.value, iv: iv).bytes;
}

Uint8List decryptBytes(BytesWithPin bytesWithPin) {
  try {
    final encrypter = getEncrypter(bytesWithPin.pin);
    return Uint8List.fromList(
        encrypter.decryptBytes(Encrypted(bytesWithPin.value), iv: iv));
  } catch (e) {
    return Uint8List(0);
  }
}
