import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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

const tokenSetKey = '@tokenSet';

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
    final prefs = await SharedPreferences.getInstance();
    final hasSetToken = prefs.getBool(tokenSetKey);
    if (hasSetToken != true) {
      final token = await messaging.getToken();
      await db
          .collection("users")
          .doc(auth.currentUser?.uid)
          .set({"id": auth.currentUser?.uid, "token": token});
      prefs.setBool(tokenSetKey, true);
    }
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
