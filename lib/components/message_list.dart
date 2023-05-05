import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:secure_messenger/consts.dart';
import 'package:secure_messenger/message_data.dart';
import 'message_bubble.dart';

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
      .orderBy('time', descending: true);
  final List<MessageData> messages = [];
  bool loading = true;
  DocumentSnapshot? lastDoc;

  void addDocs(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    messages.addAll(docs.map((d) => MessageData.fromSnapshot(d.data(), d.id)));
    lastDoc = docs.last;
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
    if (moreDocs.size > 0) addDocs(moreDocs.docs);
  }

  @override
  void initState() {
    super.initState();
    orderedCollection
        .limit(pageSize)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> snapshot) {
      if (snapshot.size > 0) addDocs(snapshot.docs);
      orderedCollection
          .endBeforeDocument(snapshot.docs.first)
          .snapshots()
          .listen((event) {
        final docsWithTime = event.docs.map((d) {
          final data = d.data();
          if (d['time'] == null) return null;
          return MessageData.fromSnapshot(data, d.id);
        }).whereType<MessageData>();
        if (docsWithTime.isNotEmpty) {
          messages.insertAll(0, docsWithTime);
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
              .copyWith(top: MediaQuery.of(context).padding.top + 16),
          itemCount: messages.length,
          itemBuilder: (BuildContext context, int index) => MessageBubble(
              messages[index],
              key: ValueKey(messages[index].time.millisecondsSinceEpoch))),
    );
  }
}
