import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'full_image.dart';

class EncryptedImage extends StatelessWidget {
  const EncryptedImage(this.imageData, this.url, {Key? key}) : super(key: key);
  final String url;
  final Uint8List imageData;

  @override
  Widget build(BuildContext context) {
    if (imageData.isEmpty) {
      return const Text("Nelze dešifrovat", style: TextStyle(fontSize: 20));
    }
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      FullImage(imageData, url)));
        },
        child: Hero(
            tag: url,
            child: Image.memory(imageData,
                cacheHeight: (MediaQuery.of(context).size.height * 0.2).toInt(),
                height: MediaQuery.of(context).size.height * 0.2)));
  }
}
