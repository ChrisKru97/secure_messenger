import 'package:flutter/material.dart';
import 'package:messenger/components/custom_icon_button.dart';

class KeyInput extends StatefulWidget {
  const KeyInput(this.setKey, {Key? key}) : super(key: key);
  final void Function(String) setKey;

  @override
  State<KeyInput> createState() => _KeyInputState();
}

class _KeyInputState extends State<KeyInput> with WidgetsBindingObserver {
  final TextEditingController textEditingController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  String? keyToSubmit;

  void focus() {
    Future.delayed(const Duration(milliseconds: 250), () {
      focusNode.requestFocus();
    });
  }

  @override
  void didChangeMetrics() {
    final value = WidgetsBinding.instance.window.viewInsets.bottom;
    if (value == 0 && keyToSubmit?.isNotEmpty == true) {
      widget.setKey(keyToSubmit!);
    }
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
    focus();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void onSubmitText(String text) {
    if (text.isNotEmpty) {
      focusNode.unfocus();
      textEditingController.clear();
      setState(() {
        keyToSubmit = text;
      });
    }
  }

  void onSubmit() {
    onSubmitText(textEditingController.text);
  }

  @override
  Widget build(BuildContext context) {
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
