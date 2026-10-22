// FCM registration tokens: send-push targets them via the FCM v1 API.
// firebase_messaging 17 deprecates these in favour of register()/onRegistered,
// which yield Installation IDs for a different send API, so switching needs a
// matching send-push change and on-device testing.
// ignore_for_file: deprecated_member_use

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
    _listenAuthChanges();
    _listenForegroundMessages();

    _initialized = true;
  }

  Future<void> _initializeLocalNotifications() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(settings: settings);
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
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'booking_push_channel',
            'Booking Push',
            channelDescription: 'Push notifications for booking updates',
            importance: Importance.high,
            priority: Priority.max,
            icon: '@mipmap/ic_launcher',
            visibility: NotificationVisibility.private,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    });
  }

  /// Removes this device's token while the session is still valid,
  /// so a signed-out device stops receiving booking pushes.
  Future<void> unregisterCurrentDevice() async {
    if (!_initialized || !_supportsFcmOnCurrentPlatform) return;
    if (_client.auth.currentUser == null) return;
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) return;
      await _client
          .rpc('unregister_device_token', params: {'p_token': token});
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to unregister FCM token: $e');
      }
    }
  }

  void _listenAuthChanges() {
    _client.auth.onAuthStateChange.listen((authState) async {
      if (authState.event == AuthChangeEvent.signedIn) {
        await _syncFcmToken();
      }
    });
  }

  Future<void> _upsertDeviceToken(String token) async {
    // Tokens are owned by the signed-in user; the RPC sets user_id server-side.
    if (_client.auth.currentUser == null) return;
    try {
      await _client.rpc('register_device_token', params: {
        'p_token': token,
        'p_platform': kIsWeb ? 'web' : Platform.operatingSystem,
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to register FCM token: $e');
      }
    }
  }

  bool get _supportsFcmOnCurrentPlatform {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }
}
