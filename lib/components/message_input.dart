import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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
  bool sendInProgress = false;

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
    final pin = getPin();
    if (pin == null ||
        textEditingController.value.text.isEmpty ||
        sendInProgress) return;
    final textValue = textEditingController.value.text.trim();
    textEditingController.clear();
    setState(() {
      sendInProgress = true;
    });
    final encrypted = await compute(encrypt, Base64WithPin(textValue, pin));
    await db.collection("messages").add({
      'time': FieldValue.serverTimestamp(),
      'text': encrypted,
      'author': auth.currentUser?.uid,
    });
    setState(() {
      sendInProgress = false;
    });
    focusNode.requestFocus();
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
                style: const TextStyle(fontSize: 18),
                enabled: !sendInProgress,
                focusNode: focusNode,
                controller: textEditingController,
                minLines: 1,
                maxLines: 5,
              ),
            )),
            if (photoIsVisible)
              const Padding(
                  padding: EdgeInsets.only(right: 16), child: PhotoButton()),
            if (sendInProgress)
              const CircularProgressIndicator()
            else
              CustomIconButton(() {
                FocusScope.of(context).unfocus();
                onSend();
              }, Icons.send)
          ],
        ));
  }
}
