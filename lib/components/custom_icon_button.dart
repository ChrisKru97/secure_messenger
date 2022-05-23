import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton(this.onPressed, this.icon, {Key? key})
      : super(key: key);
  final void Function()? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.blueAccent[100],
            borderRadius: const BorderRadius.all(Radius.circular(50))),
        child: IconButton(
          splashRadius: 1,
            onPressed: onPressed,
            icon: Icon(icon),
            color: Colors.white));
  }
}
