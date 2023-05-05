import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:secure_messenger/consts.dart';
import 'package:secure_messenger/message_data.dart';
import 'encrypted_image.dart';
import 'encrypted_text.dart';

class MessageBubble extends StatefulWidget {
  const MessageBubble(this.data, {Key? key}) : super(key: key);
  final MessageData data;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with AutomaticKeepAliveClientMixin {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  Uint8List? imageData;
  String? text;

  void fetchAndDecrypt() async {
    final pin = getPin();
    final key = getKey();
    if (pin == null || key == null) return;
    if (widget.data.text != null) {
      compute(decrypt, Base64WithPin(widget.data.text!, pin, key))
          .then((String value) {
        if (mounted) {
          setState(() {
            text = value;
          });
        }
      });
    }
    if (widget.data.image != null) {
      final encryptedBytes =
          await storage.ref().child(widget.data.image!).getData();
      if (encryptedBytes != null) {
        compute(decryptBytes, BytesWithPin(encryptedBytes, pin, key))
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

    fetchAndDecrypt();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final author = widget.data.author;
    final isAuthor = auth.currentUser?.uid == author;
    final timestamp = widget.data.time.toDate();
    final time =
        "${timestamp.hour.toString().padLeft(2, "0")}:${timestamp.minute.toString().padLeft(2, "0")}";
    return Padding(
      padding:
          EdgeInsets.only(left: isAuthor ? 0 : 50, right: isAuthor ? 50 : 0),
      child: Container(
          decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: const BorderRadius.all(Radius.circular(8))),
          padding: const EdgeInsets.all(12),
          child: (imageData == null && text == null)
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    if (text != null)
                      Align(
                          alignment: Alignment.topLeft,
                          child: EncryptedText(text!)),
                    if (imageData != null && widget.data.image != null)
                      Align(
                          alignment: Alignment.center,
                          child:
                              EncryptedImage(imageData!, widget.data.image!)),
                    Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(time,
                              style: const TextStyle(
                                  fontSize: 14, fontStyle: FontStyle.italic)),
                        )),
                  ],
                )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
