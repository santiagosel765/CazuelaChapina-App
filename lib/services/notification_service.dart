import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'auth_service.dart';

/// Handles push notification logic for the application.
class NotificationService {
  NotificationService._();

  static const String _baseUrl = 'http://10.0.2.2:5151';
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _fln =
      FlutterLocalNotificationsPlugin();

  /// Initializes Firebase, notification permissions and listeners.
  static Future<void> initialize() async {
    await Firebase.initializeApp();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(android: androidInit);
    await _fln.initialize(initializationSettings);

    await _messaging.requestPermission();
    await _messaging.setAutoInitEnabled(true);

    FirebaseMessaging.onMessage.listen(_onMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Cache current token for later registration
    await _cacheToken();
  }

  /// Registers the device FCM token in the backend.
  static Future<void> registerDeviceToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final registered = prefs.getString('registered_fcm_token');
    if (registered == token) return;

    final authService = AuthService();
    final userToken = await authService.getToken();
    if (userToken == null) return;

    await http.post(
      Uri.parse('$_baseUrl/api/Notifications/register'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $userToken',
      },
      body: jsonEncode({'token': token}),
    );

    await prefs.setString('registered_fcm_token', token);
  }

  /// Retrieves the stored FCM token if available.
  static Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }

  /// Requests a new token and stores it locally.
  static Future<void> _cacheToken() async {
    final token = await _messaging.getToken();
    if (token == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }

  static Future<void> _onMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'General',
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _fln.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
    );
  }

  static void _onMessageOpenedApp(RemoteMessage message) {
    // For now just log the event. Real navigation can be added here.
    // ignore: avoid_print
    print('Notification opened: ${message.messageId}');
  }
}

/// Handles messages when the app is in background or terminated.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
