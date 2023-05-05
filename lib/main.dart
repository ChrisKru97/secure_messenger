import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'components/message_input.dart';
import 'components/message_list.dart';
import 'consts.dart';
import 'components/key_input.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAuth.instance.signInAnonymously();
  await readKeyFromStorage();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Christian + Karin',
      theme: ThemeData(
        primaryColor: Colors.green[700],
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          fillColor: Colors.grey[300],
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  bool unlocked = false;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && unlocked) {
      setState(() {
        unlocked = false;
      });
    }
  }

  void setToken() async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return;
    bool userExists = false;
    try {
      userExists = (await db.collection('users').doc(uid).get()).exists;
    } catch (_) {}
    if (userExists) return;
    final hasPermission =
        (await messaging.requestPermission()).authorizationStatus ==
            AuthorizationStatus.authorized;
    if (!hasPermission) return;
    final token = await messaging.getToken();
    await db.collection('users').doc(uid).set({
      'id': uid,
      'token': token,
      'dev': !kReleaseMode,
      'system':
          '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setToken();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!unlocked) {
      return KeyInput(() => setState(() {
            unlocked = true;
          }));
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          body: Column(
        children: const [Expanded(child: MessageList()), MessageInput()],
      )),
    );
  }
}
