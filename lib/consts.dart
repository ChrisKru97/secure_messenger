import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/cupertino.dart' show debugPrint;
import 'key.dart';

Key? key;
IV? iv;
Encrypter? encrypter;

void setKey(String pin) {
  final keyPart = base64Decode(base64keyPart);
  var i = 0;
  for (var element in pin.split("")) {
    final value = int.parse(element);
    keyPart[i] += value;
    i++;
  }
  key = Key(keyPart);
  iv = IV.fromLength(16);
  encrypter = Encrypter(AES(key!));
}

String encrypt(String value) {
  return encrypter!.encrypt(value, iv: iv).base64;
}

String decrypt(String value) {
  try {
    return encrypter!.decrypt64(value, iv: iv);
  } catch (e) {
    return "Nelze rozšifrovat";
  }
}

Uint8List encryptBytes(Uint8List value) {
  return encrypter!.encryptBytes(value, iv: iv).bytes;
}

Uint8List decryptBytes(Uint8List value) {
  try {
    return Uint8List.fromList(
        encrypter!.decryptBytes(Encrypted(value), iv: iv));
  } catch (e) {
    return Uint8List(0);
  }
}
