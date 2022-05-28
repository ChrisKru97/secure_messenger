import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messenger/components/message_bubble.dart';

const pageSize = 10;

class MessageList extends StatefulWidget {
  const MessageList({Key? key}) : super(key: key);

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final Query<Map<String, dynamic>> orderedCollection = FirebaseFirestore
      .instance
      .collection("messages")
      .orderBy("time", descending: true);
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> messages = [];

  void addDocs(QuerySnapshot<Map<String, dynamic>> docs) {
    messages.addAll(docs.docs);
    setState(() {});
  }

  Future<void> readMore() async {
    final moreDocs = await orderedCollection
        .startAfterDocument(messages.last)
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
        if (event.size == 0) return;
        final newDoc = event.docs.first;
        if (newDoc.data()["time"] != null) {
          messages.insert(0, newDoc);
          setState(() {});
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: readMore,
      child: ListView.builder(
          reverse: true,
          padding: const EdgeInsets.all(16),
          itemCount: messages.length,
          findChildIndexCallback: (Key key) {
            if (key is ValueKey) {
              return messages.indexWhere((element) => element.id == key.value);
            }
            return 0;
          },
          itemBuilder: (BuildContext context, int index) {
            final key = Key(messages[index].id);
            if (index != 0) {
              return Container(
                  key: key,
                  padding: const EdgeInsets.only(bottom: 16),
                  child: MessageBubble(messages[index].data()));
            }
            return MessageBubble(messages[index].data(), key: key);
          }),
    );
  }
}
