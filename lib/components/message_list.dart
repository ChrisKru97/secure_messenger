import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:secure_messenger/consts.dart';
import 'package:secure_messenger/message_data.dart';
import 'message_bubble.dart';
import 'dart:math';

const pageSize = 8;

class MessageList extends StatefulWidget {
  const MessageList({Key? key}) : super(key: key);

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final Query<Map<String, dynamic>> orderedCollection = FirebaseFirestore
      .instance
      .collection(collectionName)
      .orderBy("time", descending: true);
  final List<MessageData> messages = [];
  bool loading = true;
  DocumentSnapshot? lastDoc;

  void addDocs(QuerySnapshot<Map<String, dynamic>> snapshot) {
    messages
        .addAll(snapshot.docs.map((d) => MessageData.fromSnapshot(d.data())));
    lastDoc = snapshot.docs.last;
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> readMore() async {
    if (lastDoc == null) return;
    final moreDocs = await orderedCollection
        .startAfterDocument(lastDoc!)
        .limit(pageSize)
        .get();
    addDocs(moreDocs);
  }

  @override
  void initState() {
    super.initState();
    orderedCollection
        .limit(pageSize)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> docs) {
      addDocs(docs);
      orderedCollection
          .endBeforeDocument(docs.docs.first)
          .snapshots()
          .listen((event) {
        if (event.docs.isNotEmpty) {
          messages.insertAll(
              0, event.docs.map((d) => MessageData.fromSnapshot(d.data())));
          if (mounted) setState(() {});
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(
      onRefresh: readMore,
      child: ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(
                height: 16,
              ),
          reverse: true,
          padding: const EdgeInsets.all(16)
              .copyWith(top: max(MediaQuery.of(context).padding.top, 16)),
          itemCount: messages.length,
          itemBuilder: (BuildContext context, int index) =>
              MessageBubble(messages[index])),
    );
  }
}
