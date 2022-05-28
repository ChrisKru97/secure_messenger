import 'dart:typed_data';
import 'package:flutter/material.dart';

class FullImage extends StatelessWidget {
  const FullImage(this.imageData, this.imageUrl, {Key? key}) : super(key: key);
  final Uint8List imageData;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Center(
                child: Hero(
                    tag: imageUrl,
                    child: Image.memory(
                      imageData,
                    )))));
  }
}
