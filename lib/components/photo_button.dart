import 'package:flutter/material.dart';
import 'package:messenger/components/custom_icon_button.dart';
import 'package:messenger/components/photo_screen.dart';

class PhotoButton extends StatefulWidget {
  const PhotoButton({Key? key}) : super(key: key);

  @override
  State<PhotoButton> createState() => _PhotoButtonState();
}

class _PhotoButtonState extends State<PhotoButton> {
  @override
  Widget build(BuildContext context) {
    return CustomIconButton(() {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const PhotoScreen()));
    }, Icons.camera_front);
  }
}
