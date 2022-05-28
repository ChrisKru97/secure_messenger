import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:messenger/consts.dart';

class EncryptedText extends StatefulWidget {
  const EncryptedText(this.text, {Key? key}) : super(key: key);
  final String text;

  @override
  State<EncryptedText> createState() => _EncryptedTextState();
}

class _EncryptedTextState extends State<EncryptedText> {
  String? decryptedText;

  void fetchData() async {
    final pin = getPin();
    if (pin == null) return;
    compute(decrypt, Base64WithPin(widget.text, pin)).then((String value) {
      if (mounted) {
        setState(() {
          decryptedText = value;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();

    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    if (decryptedText == null) return const CircularProgressIndicator();
    return Text(decryptedText!, style: const TextStyle(fontSize: 20));
  }
}
