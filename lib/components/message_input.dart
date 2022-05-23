import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messenger/components/custom_icon_button.dart';
import 'package:messenger/components/photo_button.dart';
import 'package:messenger/consts.dart';

class MessageInput extends StatefulWidget {
  const MessageInput({Key? key}) : super(key: key);

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final TextEditingController textEditingController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  bool photoIsVisible = true;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
    focusNode.removeListener(onFocusChange);
    focusNode.dispose();
  }

  void onFocusChange() {
    setState(() {
      photoIsVisible = !focusNode.hasFocus;
    });
  }

  void onSend() async {
    if (textEditingController.value.text.isEmpty) return;
    final encrypted = encrypt(textEditingController.value.text.trim());
    await db.collection("messages").add({
      'time': FieldValue.serverTimestamp(),
      'text': encrypted,
      'author': auth.currentUser?.uid,
    });
    textEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -1),
          ),
        ]),
        child: Row(
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: TextField(
                style:const TextStyle(fontSize: 18),
                focusNode: focusNode,
                controller: textEditingController,
                minLines: 1,
                maxLines: 5,
              ),
            )),
            if (photoIsVisible)
              Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: PhotoButton()),
            CustomIconButton(() {
              FocusScope.of(context).unfocus();
              onSend();
            }, Icons.send)
          ],
        ));
  }
}
