import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:messenger/color_ext.dart';
import 'package:messenger/components/message_input.dart';
import 'package:messenger/components/message_list.dart';
import 'package:messenger/consts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/key_input.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.options,
  );

  await FirebaseAuth.instance.signInAnonymously();

  await _setUpRemoteConfig();

  runApp(const MyApp());
}

Future<FirebaseRemoteConfig> _setUpRemoteConfig() async {
  final remoteConfig = FirebaseRemoteConfig.instance;

  await remoteConfig.setConfigSettings(
    RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: Duration.zero,
    ),
  );

  await remoteConfig.setDefaults(
    {
      'scaffold_color': Colors.white.toHex(),
      'text_field_color': Colors.grey[300]?.toHex(),
      'primary_color': Colors.green[700]?.toHex(),
    },
  );

  return remoteConfig;
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final remoteConfig = FirebaseRemoteConfig.instance;

  @override
  void initState() {
    remoteConfig.addListener(() {
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldColor = remoteConfig.getString('scaffold_color');
    final textFieldColor = remoteConfig.getString('text_field_color');
    final primaryColor = remoteConfig.getString('primary_color');

    return MaterialApp(
      title: 'Christian + Karin',
      theme: ThemeData(
        primaryColor: ColorHex.fromHex(primaryColor),
        scaffoldBackgroundColor: ColorHex.fromHex(scaffoldColor),
        backgroundColor: ColorHex.fromHex(scaffoldColor),
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          fillColor: ColorHex.fromHex(textFieldColor),
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
      return KeyInput((String key) {
        setKey(key);
        setState(() {
          unlocked = true;
        });
      });
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          body: SafeArea(
        child: Column(
          children: [Expanded(child: MessageList()), MessageInput()],
        ),
      )),
    );
  }
}
