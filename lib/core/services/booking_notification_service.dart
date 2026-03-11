import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingNotificationService {
  BookingNotificationService(this._client);

  final SupabaseClient _client;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'booking_push_channel',
    'Booking Push',
    description: 'Push notifications for booking updates',
    importance: Importance.high,
  );

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    if (!_supportsFcmOnCurrentPlatform) {
      _initialized = true;
      return;
    }

    await _initializeLocalNotifications();
    await _requestPermissions();
    await _syncFcmToken();
    _listenTokenRefresh();
    _listenForegroundMessages();

    _initialized = true;
  }

  Future<void> _initializeLocalNotifications() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(settings);
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  Future<void> _requestPermissions() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }
 
  Future<void> _syncFcmToken() async {
    final token = await _messaging.getToken();
    if (token == null || token.isEmpty) return;
    await _upsertDeviceToken(token);
  }

  void _listenTokenRefresh() {
    _messaging.onTokenRefresh.listen((token) async {
      if (token.isEmpty) return;
      await _upsertDeviceToken(token);
    });
  }

  void _listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final title =
          message.notification?.title ?? message.data['title']?.toString();
      final body =
          message.notification?.body ?? message.data['body']?.toString();
      if (title == null || body == null) return;

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'booking_push_channel',
            'Booking Push',
            channelDescription: 'Push notifications for booking updates',
            importance: Importance.high,
            priority: Priority.max,
            icon: '@mipmap/ic_launcher',
            visibility: NotificationVisibility.public,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    });
  }

  Future<void> _upsertDeviceToken(String token) async {
    final userId = _client.auth.currentUser?.id;
    final payload = {
      'token': token,
      'platform': Platform.operatingSystem,
      'user_id': userId,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    try {
      await _client.from('device_tokens').upsert(payload, onConflict: 'token');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to upsert FCM token: $e');
      }
    }
  }

  bool get _supportsFcmOnCurrentPlatform {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }
}
