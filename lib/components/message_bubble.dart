import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messenger/components/encrypted_image.dart';
import 'package:messenger/components/encrypted_text.dart';

class MessageBubble extends StatelessWidget {
  MessageBubble(this.data, {Key? key}) : super(key: key);
  final FirebaseAuth auth = FirebaseAuth.instance;
  final Map<String, dynamic>? data;

  @override
  Widget build(BuildContext context) {
    if (data?["time"] == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final author = data?["author"];
    final isAuthor = auth.currentUser?.uid == author;
    final text = data?["text"];
    final imageUrl = data?["image"];
    final timestamp = (data?["time"] as Timestamp).toDate();
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
          child: Column(
            children: [
              if (text != null)
                Align(alignment: Alignment.topLeft, child: EncryptedText(text)),
              if (imageUrl != null)
                Align(
                    alignment: Alignment.center,
                    child: EncryptedImage(imageUrl)),
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
}
