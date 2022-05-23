import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messenger/components/message_bubble.dart';

class MessageList extends StatelessWidget {
  MessageList({Key? key}) : super(key: key);
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // TODO pagination

  @override
  Widget build(BuildContext context) {
    final messageSnapshots = db
        .collection("messages")
        .orderBy("time", descending: true)
        .limit(6)
        .snapshots();
    return StreamBuilder(
        stream: messageSnapshots,
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                final bubble = MessageBubble(snapshot.data?.docs[index].data());
                if (index != 0) {
                  return Container(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: bubble);
                }
                return bubble;
              });
        });
  }
}
