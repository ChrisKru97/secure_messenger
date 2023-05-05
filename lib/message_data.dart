import 'package:cloud_firestore/cloud_firestore.dart';

class MessageData {
  final String? text;
  final String? image;
  final Timestamp time;
  final String author;

  const MessageData(
      {this.text, this.image, required this.time, required this.author});

  MessageData.fromSnapshot(Map<String, dynamic> snapshot)
      : text = snapshot['text'],
        image = snapshot['image'],
        time = snapshot['time'] ?? Timestamp.now(),
        author = snapshot['author'];
}
