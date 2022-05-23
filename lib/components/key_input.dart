import 'package:flutter/material.dart';
import 'package:messenger/components/custom_icon_button.dart';

class KeyInput extends StatefulWidget {
  KeyInput(this.setKey, {Key? key}) : super(key: key);
  final void Function(String) setKey;

  @override
  State<KeyInput> createState() => _KeyInputState();
}

class _KeyInputState extends State<KeyInput> with WidgetsBindingObserver {
  final TextEditingController textEditingController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  void focus() {
    Future.delayed(const Duration(milliseconds: 250), () {
      focusNode.requestFocus();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      focus();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void onSubmitText(String text) {
    if (text.isNotEmpty) {
      widget.setKey(text);
    }
  }

  void onSubmit() {
    onSubmitText(textEditingController.text);
  }

  @override
  Widget build(BuildContext context) {
    focus();
    return Scaffold(
        body: SafeArea(
            child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: TextField(
                            onSubmitted: onSubmitText,
                            focusNode: focusNode,
                            keyboardType: TextInputType.number,
                            controller: textEditingController,
                          ),
                        ),
                      ),
                      CustomIconButton(onSubmit, Icons.check)
                    ],
                  ),
                ))));
  }
}
