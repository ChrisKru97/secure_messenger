import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:messenger/components/full_image.dart';
import 'package:messenger/consts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EncryptedImage extends StatefulWidget {
  const EncryptedImage(this.url, {Key? key}) : super(key: key);
  final String url;

  @override
  State<EncryptedImage> createState() => _EncryptedImageState();
}

class _EncryptedImageState extends State<EncryptedImage> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  Uint8List? imageData;

  void fetchData() async {
    final pin = getPin();
    if (pin == null) return;
    final prefs = await SharedPreferences.getInstance();
    final prefsData = prefs.getString(widget.url);
    if (prefsData != null) {
      compute(decryptToBytes, Base64WithPin(prefsData, pin))
          .then((Uint8List value) {
        if (mounted) {
          setState(() {
            imageData = value;
          });
        }
      });
    } else {
      final encryptedBytes = await storage.ref().child(widget.url).getData();
      if (encryptedBytes != null) {
        prefs.setString(widget.url, base64Encode(encryptedBytes));
        compute(decryptBytes, BytesWithPin(encryptedBytes, pin))
            .then((Uint8List value) {
          if (mounted) {
            setState(() {
              imageData = value;
            });
          }
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    if (imageData == null) return const CircularProgressIndicator();
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      FullImage(imageData!, widget.url)));
        },
        child: Hero(
            tag: widget.url,
            child: Image.memory(imageData!,
                cacheHeight: (MediaQuery.of(context).size.height * 0.2).toInt(),
                height: MediaQuery.of(context).size.height * 0.2)));
  }
}
