import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../core/utils/device_info_helper.dart';
import '../../auth/data/models/device_register_request_model.dart';
import '../../auth/domain/repositories/auth_repository.dart';

class NotificationService {
  final FirebaseMessaging _fcm;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final AuthRepository _authRepository;

  NotificationService({
    required AuthRepository authRepository,
    required FlutterLocalNotificationsPlugin localNotifications,
    FirebaseMessaging? fcm,
  })  : _authRepository = authRepository,
        _localNotifications = localNotifications,
        _fcm = fcm ?? FirebaseMessaging.instance;

  Future<void> initialize() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Notification permission granted');

      await _initializeLocalNotifications();
      await _getFcmTokenAndRegister();
      _setupMessageHandlers();
      _listenForTokenRefresh();
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('Notification permission granted (provisional)');
    } else {
      debugPrint('Notification permission denied');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> _getFcmTokenAndRegister() async {
    int retryCount = 0;
    String? token;

    while (retryCount < 3 && token == null) {
      token = await _fcm.getToken();
      retryCount++;

      if (token == null) {
        debugPrint(
          'FCM token is null, retrying in 2 seconds (attempt $retryCount/3)',
        );
        await Future.delayed(const Duration(seconds: 2));
      } else {
        debugPrint('FCM token retrieved: ${_previewToken(token)}');
      }
    }

    if (token != null && token.isNotEmpty) {
      await _registerDeviceWithBackend(token);
    } else {
      debugPrint('Failed to get FCM token after 3 attempts');
    }
  }

  Future<void> _registerDeviceWithBackend(String fcmToken) async {
    try {
      final deviceType = DeviceInfoHelper.getDeviceType();
      final deviceName = await DeviceInfoHelper.getDeviceName();

      final request = DeviceRegisterRequestModel(
        fcmToken: fcmToken,
        deviceType: deviceType,
        deviceName: deviceName,
      );

      final result = await _authRepository.registerDevice(request);
      result.fold(
        (failure) {
          debugPrint('Device registration failed: ${failure.message}');
        },
        (response) {
          debugPrint('Device registered');
          debugPrint('Device ID: ${response.id}');
          debugPrint('Device type: ${response.deviceType}');
          debugPrint('Device name: ${response.deviceName ?? "N/A"}');
          debugPrint('Active: ${response.isActive}');
        },
      );
    } catch (e) {
      debugPrint('Device registration error: $e');
    }
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);

    _fcm.getInitialMessage().then((message) {
      if (message != null) {
        _handleBackgroundMessageTap(message);
      }
    });
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Foreground message received');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');

    final notification = message.notification;
    if (notification != null) {
      await _showLocalNotification(
        title: notification.title ?? 'New Notification',
        body: notification.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  void _handleBackgroundMessageTap(RemoteMessage message) {
    debugPrint('Notification opened from background');
    debugPrint('Data: ${message.data}');
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Local notification tapped');
    debugPrint('Payload: ${response.payload}');
  }

  void _listenForTokenRefresh() {
    _fcm.onTokenRefresh.listen((newToken) {
      debugPrint('FCM token refreshed: ${_previewToken(newToken)}');
      _registerDeviceWithBackend(newToken);
    });
  }

  String _previewToken(String token) {
    const previewLength = 20;
    if (token.length <= previewLength) {
      return token;
    }
    return token.substring(0, previewLength);
  }
}
