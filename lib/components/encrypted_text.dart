import 'package:flutter/material.dart';

class EncryptedText extends StatelessWidget {
  const EncryptedText(this.text, {Key? key}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 20));
  }
}
