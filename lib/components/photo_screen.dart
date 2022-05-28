import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:messenger/components/custom_icon_button.dart';
import 'package:messenger/consts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhotoScreen extends StatefulWidget {
  const PhotoScreen({Key? key}) : super(key: key);

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  late CameraController controller;
  late List<CameraDescription> cameras;
  bool initialized = false;
  int selectedCamera = 0;
  bool uploading = false;
  bool uploaded = false;

  void initializeCamera(int index) async {
    cameras = await availableCameras();
    controller = CameraController(cameras[index], ResolutionPreset.high);
    await controller.initialize();
    setState(() {
      initialized = true;
    });
  }

  @override
  void initState() {
    super.initState();
    initializeCamera(selectedCamera);
  }

  Future<void> switchCamera() async {
    selectedCamera = (selectedCamera + 1) % cameras.length;
    await controller.dispose();
    initializeCamera(selectedCamera);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void capturePicture() async {
    final pin = getPin();
    if (pin == null) return;
    final file = await controller.takePicture();
    setState(() {
      uploading = true;
    });
    final bytes = await file.readAsBytes();
    final encrypted = await compute(encryptBytes, BytesWithPin(bytes, pin));
    final task = storage.ref().child(file.name).putData(encrypted);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(file.name, base64Encode(encrypted));
    task.whenComplete(() async {
      await db.collection("messages").add({
        'time': FieldValue.serverTimestamp(),
        'image': file.name,
        'author': auth.currentUser?.uid,
      });
      setState(() {
        uploading = false;
        uploaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (uploaded) {
      Future.delayed(const Duration(milliseconds: 250), () {
        Navigator.pop(context);
      });
    }
    if (uploading ||
        uploaded ||
        !initialized ||
        !controller.value.isInitialized) {
      return Container(
          color: Colors.white,
          child: const Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(flex: 5, child: CameraPreview(controller)),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomIconButton(switchCamera, Icons.switch_camera),
                  CustomIconButton(capturePicture, Icons.camera),
                  CustomIconButton(() {
                    Navigator.pop(context);
                  }, Icons.arrow_back),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
