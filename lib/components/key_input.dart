import 'package:flutter/material.dart';
import 'package:secure_messenger/consts.dart';
import 'custom_icon_button.dart';

class KeyInput extends StatefulWidget {
  const KeyInput(this.setUnlocked, {Key? key}) : super(key: key);
  final void Function() setUnlocked;

  @override
  State<KeyInput> createState() => _KeyInputState();
}

class _KeyInputState extends State<KeyInput> with WidgetsBindingObserver {
  final TextEditingController pinEditingController = TextEditingController();
  final TextEditingController keyEditingController = TextEditingController();
  final FocusNode pinFocusNode = FocusNode();
  final FocusNode keyFocusNode = FocusNode();
  String? pin;
  String? key;

  void focus() {
    Future.delayed(const Duration(milliseconds: 250), () {
      final hasKey = getKey()?.isNotEmpty == true;
      if (hasKey) {
        pinFocusNode.requestFocus();
      } else {
        keyFocusNode.requestFocus();
      }
    });
  }

  @override
  void didChangeMetrics() {
    final value = WidgetsBinding.instance.window.viewInsets.bottom;
    if (value == 0) {
      if (key?.isNotEmpty == true) setKey(key!);
      if (pin?.isNotEmpty == true) {
        setPin(pin!);
        widget.setUnlocked();
      }
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

  void onSubmitText(String nextPin, String nextKey) {
    if (nextPin.isNotEmpty) {
      pinFocusNode.unfocus();
      keyFocusNode.unfocus();
      keyEditingController.clear();
      pinEditingController.clear();
      setState(() {
        pin = nextPin;
        key = nextKey;
      });
    }
  }

  void onSubmit() {
    onSubmitText(pinEditingController.text, keyEditingController.text);
  }

  @override
  Widget build(BuildContext context) {
    final hasKey = getKey()?.isNotEmpty == true;
    return Scaffold(
        body: SafeArea(
            child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!hasKey)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: TextField(
                                onSubmitted: (_) => pinFocusNode.requestFocus(),
                                decoration:
                                    const InputDecoration(hintText: 'Key'),
                                controller: keyEditingController,
                                focusNode: keyFocusNode,
                              ),
                            ),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: TextField(
                                    onSubmitted: (_) => onSubmit(),
                                    focusNode: pinFocusNode,
                                    keyboardType: TextInputType.number,
                                    controller: pinEditingController,
                                    decoration:
                                        const InputDecoration(hintText: 'Pin'),
                                  ),
                                ),
                              ),
                              CustomIconButton(onSubmit, Icons.check)
                            ],
                          ),
                        ])))));
  }
}
