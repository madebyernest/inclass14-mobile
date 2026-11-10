import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'fcm_service.dart';

@pragma('vm:entry-point')
Future<void> _bgHandler(RemoteMessage m) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Background handler: ${m.messageId}'); 
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_bgHandler);
  runApp(const MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final svc = FCMService();

  @override
  void initState() {
    super.initState();
    svc.initialize();
  }

  @override
  void dispose() {
    svc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: svc,
        builder: (_, __) => Scaffold(
          appBar: AppBar(title: const Text('FCM Demo')),
          body: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Image.asset(svc.image, height: 160),
              Text(svc.title, style: Theme.of(context).textTheme.headlineSmall),
              Text('Handler: ${svc.lastHandler}'),
              Text('Count: ${svc.count}  ID: ${svc.messageId}'),
              if (svc.diagnostic.isNotEmpty)
                Text(svc.diagnostic, style: const TextStyle(color: Colors.red)),
            ]),
          ),
        ),
      );
}