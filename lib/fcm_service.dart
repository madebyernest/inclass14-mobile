import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService extends ChangeNotifier {
  static const _assets = {
    'default': 'assets/default.png',
    'promo': 'assets/promo.png',
  };

  String title = 'Waiting for message';
  String image = _assets['default']!;
  String lastHandler = 'none';
  String messageId = '-';
  String diagnostic = '';
  int count = 0;
  StreamSubscription? _fg, _open;

  Future<void> initialize() async {
    final fm = FirebaseMessaging.instance;
    final settings = await fm.requestPermission();
    debugPrint('Permission: ${settings.authorizationStatus}');
    debugPrint('Token: ${await fm.getToken()}');

    _fg = FirebaseMessaging.onMessage.listen((m) => _handle(m, 'onMessage'));
    _open = FirebaseMessaging.onMessageOpenedApp
        .listen((m) => _handle(m, 'onMessageOpenedApp'));

    final initial = await fm.getInitialMessage();
    if (initial != null) _handle(initial, 'getInitialMessage');
  }

  void _handle(RemoteMessage m, String handler) {
    lastHandler = handler;
    messageId = m.messageId ?? '-';
    count++;
    final asset = m.data['asset'];
    if (m.data['action'] == 'update_ui' && _assets.containsKey(asset)) {
      title = m.notification?.title ?? title;
      image = _assets[asset]!;
      diagnostic = '';
    } else {
      diagnostic = 'Rejected payload: ${m.data}';
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _fg?.cancel();
    _open?.cancel();
    super.dispose();
  }
}