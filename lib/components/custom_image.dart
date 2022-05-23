import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:messenger/components/full_image.dart';
import 'package:messenger/consts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomImage extends StatefulWidget {
  const CustomImage(this.url, {Key? key}) : super(key: key);
  final String url;

  @override
  State<CustomImage> createState() => _CustomImageState();
}

class _CustomImageState extends State<CustomImage> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  Uint8List? imageData;

  void fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final prefsData = prefs.getString(widget.url);
    if (prefsData != null) {
      setState(() {
        imageData = decryptBytes(base64Decode(prefsData));
      });
    } else {
      final data = await storage.ref().child(widget.url).getData();
      if (data == null) return;
      prefs.setString(widget.url, base64Encode(data));
      setState(() {
        imageData = decryptBytes(data);
      });
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
    if (imageData?.isEmpty == true) return const Text("Nelze rozšifrovat");
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    FullImage(imageData!, widget.url)));
      },
      child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.2),
          child: Hero(tag: widget.url, child: Image.memory(imageData!))),
    );
  }
}
