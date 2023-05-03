import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_remote_config/firebase_remote_config.dart';
// import 'package:flutter/material.dart';
// import 'package:messenger/color_ext.dart';
// import 'package:messenger/components/message_input.dart';
// import 'package:messenger/components/message_list.dart';
// import 'package:messenger/consts.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'components/key_input.dart';
// import 'firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.options,
//   );

//   await FirebaseAuth.instance.signInAnonymously();

//   await _setUpRemoteConfig();

//   runApp(const MyApp());
// }

// Future<FirebaseRemoteConfig> _setUpRemoteConfig() async {
//   final remoteConfig = FirebaseRemoteConfig.instance;

//   await remoteConfig.setConfigSettings(
//     RemoteConfigSettings(
//       fetchTimeout: const Duration(seconds: 10),
//       minimumFetchInterval: Duration.zero,
//     ),
//   );

//   await remoteConfig.setDefaults(
//     {
//       'scaffold_color': Colors.white.toHex(),
//       'text_field_color': Colors.grey[300]?.toHex(),
//       'primary_color': Colors.green[700]?.toHex(),
//     },
//   );

//   return remoteConfig;
// }

// class MyApp extends StatefulWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   final remoteConfig = FirebaseRemoteConfig.instance;

//   @override
//   void initState() {
//     remoteConfig.addListener(() {
//       setState(() {});
//     });

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final scaffoldColor = remoteConfig.getString('scaffold_color');
//     final textFieldColor = remoteConfig.getString('text_field_color');
//     final primaryColor = remoteConfig.getString('primary_color');

//     return MaterialApp(
//       title: 'Christian + Karin',
//       theme: ThemeData(
//         primaryColor: ColorHex.fromHex(primaryColor),
//         scaffoldBackgroundColor: ColorHex.fromHex(scaffoldColor),
//         backgroundColor: ColorHex.fromHex(scaffoldColor),
//         inputDecorationTheme: InputDecorationTheme(
//           isDense: true,
//           fillColor: ColorHex.fromHex(textFieldColor),
//           filled: true,
//           border: OutlineInputBorder(
//             borderSide: BorderSide.none,
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//       ),
//       home: const MyHomePage(),
//     );
//   }
// }

// const tokenSetKey = '@tokenSet';

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key}) : super(key: key);

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
//   bool unlocked = false;
//   final FirebaseFirestore db = FirebaseFirestore.instance;
//   final FirebaseAuth auth = FirebaseAuth.instance;
//   final FirebaseMessaging messaging = FirebaseMessaging.instance;

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state != AppLifecycleState.resumed && unlocked) {
//       setState(() {
//         unlocked = false;
//       });
//     }
//   }

//   void setToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     final hasSetToken = prefs.getBool(tokenSetKey);
//     if (hasSetToken != true) {
//       final token = await messaging.getToken();
//       await db
//           .collection("users")
//           .doc(auth.currentUser?.uid)
//           .set({"id": auth.currentUser?.uid, "token": token});
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     setToken();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!unlocked) {
//       return KeyInput((String key) {
//         setPin(key);
//         setState(() {
//           unlocked = true;
//         });
//       });
//     }

//     return GestureDetector(
//       onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
//       child: Scaffold(
//           body: SafeArea(
//         child: Column(
//           children: const [Expanded(child: MessageList()), MessageInput()],
//         ),
//       )),
//     );
//   }
// }
