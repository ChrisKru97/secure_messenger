import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'custom_icon_button.dart';
import '../consts.dart';

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
  bool captured = false;
  XFile? pictureData;

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

  void savePicture() async {
    final pin = getPin();
    final key = getKey();
    final author = auth.currentUser?.uid;
    if (pin == null || key == null || pictureData == null || author == null) {
      return;
    }
    setState(() {
      uploading = true;
    });
    final bytes = await pictureData!.readAsBytes();
    final encrypted =
        await compute(encryptBytes, BytesWithPin(bytes, pin, key));
    final task = storage.ref().child(pictureData!.name).putData(encrypted);
    // final prefs = await SharedPreferences.getInstance();
    // prefs.setString(pictureData!.name, base64Encode(encrypted));
    task.whenComplete(() async {
      await db.collection(collectionName).add({
        'time': FieldValue.serverTimestamp(),
        'image': pictureData!.name,
        'author': author,
      });
      setState(() {
        uploading = false;
        uploaded = true;
      });
    });
  }

  void capturePicture() async {
    pictureData = await controller.takePicture();
    setState(() {
      captured = true;
    });
  }

  void recapture() async {
    pictureData = null;
    setState(() {
      captured = false;
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
            Expanded(
                flex: 5,
                child: captured
                    ? Image.file(File(pictureData!.path))
                    : CameraPreview(controller)),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (captured)
                    CustomIconButton(recapture, Icons.replay)
                  else
                    CustomIconButton(switchCamera, Icons.switch_camera),
                  if (captured)
                    CustomIconButton(savePicture, Icons.send)
                  else
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
