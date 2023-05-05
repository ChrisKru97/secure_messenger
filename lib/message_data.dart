import 'package:cloud_firestore/cloud_firestore.dart';

class MessageData {
  final String id;
  final String? text;
  final String? image;
  final Timestamp time;
  final String author;

  const MessageData(
      {this.text,
      this.image,
      required this.time,
      required this.author,
      required this.id});

  MessageData.fromSnapshot(Map<String, dynamic> snapshot, this.id)
      : text = snapshot['text'],
        image = snapshot['image'],
        time = snapshot['time'],
        author = snapshot['author'];
}
