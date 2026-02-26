# FCM Device Registration and Local Notifications Implementation Guide

## Overview
This guide provides step-by-step instructions to implement device FCM token registration with the backend and foreground notification handling using `flutter_local_notifications`. This enables the app to:
- Register device FCM tokens with the backend
- Handle foreground push notifications with local UI alerts
- Update device information on app launch

## Prerequisites
- Firebase Cloud Messaging already configured (see `firebase_cloud_messaging_implementation.md`)
- User authentication implemented
- `firebase_messaging` package installed
- Backend API endpoint `auth/register-device` available

## Dependencies

Add these packages to `pubspec.yaml`:

```yaml
dependencies:
  # Existing Firebase dependencies
  firebase_core: ^3.6.0
  firebase_messaging: ^15.1.3
  
  # New: Local notifications for foreground messages
  flutter_local_notifications: ^18.0.1
  
  # Existing dependencies
  dio: ^5.3.2
  get_it: ^7.6.4
  flutter_bloc: ^8.1.3
  device_info_plus: ^10.1.2  # To get device name
```

Run:
```bash
flutter pub get
```

### Package Purposes

| Package | Purpose |
|---------|---------|
| `flutter_local_notifications` | Display notifications when app is in foreground |
| `device_info_plus` | Get device model name (e.g., "iPhone 13", "Samsung S21") |

## Implementation Workflow

### Phase 1: Data Layer - API Models and DTOs

#### Step 1.1: Create Device Registration Request Model

Create file: `lib/features/auth/data/models/device_register_request_model.dart`

```dart
import 'package:equatable/equatable.dart';

class DeviceRegisterRequestModel extends Equatable {
  final String fcmToken;
  final String deviceType;
  final String? deviceName;

  const DeviceRegisterRequestModel({
    required this.fcmToken,
    required this.deviceType,
    this.deviceName,
  });

  Map<String, dynamic> toJson() {
    return {
      'fcm_token': fcmToken,
      'device_type': deviceType,
      if (deviceName != null) 'device_name': deviceName,
    };
  }

  @override
  List<Object?> get props => [fcmToken, deviceType, deviceName];
}
```

**Key Details:**
- `fcmToken`: Firebase Cloud Messaging token (required)
- `deviceType`: Platform identifier - "ios" or "android" (required)
- `deviceName`: Human-readable device name (optional)
- `toJson()`: Converts to API request payload

#### Step 1.2: Create Device Registration Response Model

Create file: `lib/features/auth/data/models/device_register_response_model.dart`

```dart
import 'package:equatable/equatable.dart';

class DeviceRegisterResponseModel extends Equatable {
  final int id;
  final int userId;
  final String fcmToken;
  final String deviceType;
  final String? deviceName;
  final bool isActive;
  final DateTime lastLogin;

  const DeviceRegisterResponseModel({
    required this.id,
    required this.userId,
    required this.fcmToken,
    required this.deviceType,
    this.deviceName,
    required this.isActive,
    required this.lastLogin,
  });

  factory DeviceRegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return DeviceRegisterResponseModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      fcmToken: json['fcm_token'] as String,
      deviceType: json['device_type'] as String,
      deviceName: json['device_name'] as String?,
      isActive: json['is_active'] as bool,
      lastLogin: DateTime.parse(json['last_login'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        fcmToken,
        deviceType,
        deviceName,
        isActive,
        lastLogin,
      ];
}
```

**Key Details:**
- Maps backend response to Dart model
- Handles nullable `deviceName`
- Parses ISO 8601 timestamp for `lastLogin`

### Phase 2: Data Layer - Remote Data Source

#### Step 2.1: Update Auth Remote Data Source Interface

Update file: `lib/features/auth/data/datasources/auth_remote_data_source.dart`

Add the abstract method to the interface:

```dart
abstract class AuthRemoteDataSource {
  Future<UserModel> register(String email, String password);
  Future<AuthResponseModel> login(String email, String password);
  Future<AuthResponseModel> refreshToken(String refreshToken);
  
  // New: Device registration
  Future<DeviceRegisterResponseModel> registerDevice(
    DeviceRegisterRequestModel request,
  );
}
```

#### Step 2.2: Implement Device Registration in Data Source

In the same file, add to `AuthRemoteDataSourceImpl`:

```dart
import '../models/device_register_request_model.dart';
import '../models/device_register_response_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  // ... existing code ...

  @override
  Future<DeviceRegisterResponseModel> registerDevice(
    DeviceRegisterRequestModel request,
  ) async {
    try {
      final response = await dio.post(
        '/auth/register-device',
        data: request.toJson(),
      );

      final payload = _extractPayload(
        response,
        fallbackMessage: 'Device registration failed',
      );

      return DeviceRegisterResponseModel.fromJson(payload);
    } on DioException catch (e) {
      throw _handleDioException(
        e,
        fallbackMessage: 'Device registration failed',
      );
    }
  }

  // ... existing helper methods (_extractPayload, _handleDioException) ...
}
```

**Implementation Notes:**
- Uses existing `_extractPayload` helper to unwrap API response
- Uses existing `_handleDioException` for error handling
- Endpoint: `POST /auth/register-device`
- Requires authentication (bearer token automatically added by Dio interceptor)

### Phase 3: Domain Layer - Repository

#### Step 3.1: Update Auth Repository Interface

Update file: `lib/features/auth/domain/repositories/auth_repository.dart`

Add the abstract method:

```dart
import '../../../data/models/device_register_request_model.dart';
import '../../../data/models/device_register_response_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> register(String email, String password);
  Future<Either<Failure, AuthResponse>> login(String email, String password);
  Future<Either<Failure, AuthResponse?>> getStoredAuth();
  Future<Either<Failure, AuthResponse>> refreshToken(String refreshToken);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User?>> getCurrentUser();
  
  // New: Device registration
  Future<Either<Failure, DeviceRegisterResponseModel>> registerDevice(
    DeviceRegisterRequestModel request,
  );
}
```

#### Step 3.2: Implement in Repository Implementation

Update file: `lib/features/auth/data/repositories/auth_repository_impl.dart`

```dart
import '../models/device_register_request_model.dart';
import '../models/device_register_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  // ... existing code ...

  @override
  Future<Either<Failure, DeviceRegisterResponseModel>> registerDevice(
    DeviceRegisterRequestModel request,
  ) async {
    try {
      final response = await remoteDataSource.registerDevice(request);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to register device: $e'));
    }
  }

  // ... existing methods ...
}
```

### Phase 4: Enhanced Notification Service

#### Step 4.1: Create Device Info Helper

Create file: `lib/core/utils/device_info_helper.dart`

```dart
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceInfoHelper {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Get device type: "ios" or "android"
  static String getDeviceType() {
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'unknown';
  }

  /// Get device name (e.g., "iPhone 13 Pro", "Samsung SM-G991B")
  static Future<String?> getDeviceName() async {
    try {
      if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.name; // e.g., "John's iPhone"
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return '${androidInfo.manufacturer} ${androidInfo.model}';
        // e.g., "Samsung SM-G991B"
      }
    } catch (e) {
      debugPrint('Error getting device name: $e');
    }
    return null;
  }
}
```

#### Step 4.2: Update Notification Service with Registration

Update file: `lib/features/notifications/services/notification_service.dart`

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../core/utils/device_info_helper.dart';
import '../../auth/data/models/device_register_request_model.dart';
import '../../auth/domain/repositories/auth_repository.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final AuthRepository _authRepository;

  NotificationService({required AuthRepository authRepository})
      : _authRepository = authRepository;

  /// Initialize notification service
  Future<void> initialize() async {
    // 1. Request FCM permissions
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ User granted notification permission');

      // 2. Initialize local notifications for foreground messages
      await _initializeLocalNotifications();

      // 3. Get FCM token and register device
      await _getFcmTokenAndRegister();

      // 4. Setup message handlers
      _setupMessageHandlers();

      // 5. Listen for token refresh
      _listenForTokenRefresh();
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('⚠️ User granted provisional permission');
    } else {
      debugPrint('❌ User declined or has not accepted permission');
    }
  }

  /// Initialize Flutter Local Notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // Already requested via FCM
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

    // Create Android notification channel for foreground notifications
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // name
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Get FCM token and register device with backend
  Future<void> _getFcmTokenAndRegister() async {
    int retryCount = 0;
    String? token;

    // Retry logic for getting FCM token
    while (retryCount < 3 && token == null) {
      token = await _fcm.getToken();
      retryCount++;

      if (token == null) {
        debugPrint(
          '⏳ Token is null, retrying in 2 seconds... (Attempt $retryCount/3)',
        );
        await Future.delayed(const Duration(seconds: 2));
      } else {
        debugPrint('✅ FCM Token retrieved: ${token.substring(0, 20)}...');
      }
    }

    // Register device if token is available
    if (token != null && token.isNotEmpty) {
      await _registerDeviceWithBackend(token);
    } else {
      debugPrint('❌ Failed to get FCM token after 3 attempts');
    }
  }

  /// Register device with backend
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
          debugPrint('❌ Device registration failed: ${failure.message}');
        },
        (response) {
          debugPrint('✅ Device registered successfully');
          debugPrint('   Device ID: ${response.id}');
          debugPrint('   Device Type: ${response.deviceType}');
          debugPrint('   Device Name: ${response.deviceName ?? "N/A"}');
          debugPrint('   Active: ${response.isActive}');
        },
      );
    } catch (e) {
      debugPrint('❌ Error registering device: $e');
    }
  }

  /// Setup FCM message handlers
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);

    // Handle notification tap when app was terminated
    _fcm.getInitialMessage().then((message) {
      if (message != null) {
        _handleBackgroundMessageTap(message);
      }
    });
  }

  /// Handle foreground messages - show local notification
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('📨 Foreground message received');
    debugPrint('   Title: ${message.notification?.title}');
    debugPrint('   Body: ${message.notification?.body}');
    debugPrint('   Data: ${message.data}');

    final notification = message.notification;
    if (notification != null) {
      await _showLocalNotification(
        title: notification.title ?? 'New Notification',
        body: notification.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  /// Show local notification
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
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Handle background message tap
  void _handleBackgroundMessageTap(RemoteMessage message) {
    debugPrint('🔔 Notification tapped (background)');
    debugPrint('   Data: ${message.data}');
    
    // TODO: Navigate to relevant screen based on notification type
    // Example: if (message.data['type'] == 'transcription_complete') { ... }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Local notification tapped');
    debugPrint('   Payload: ${response.payload}');
    
    // TODO: Navigate to relevant screen based on payload
  }

  /// Listen for FCM token refresh
  void _listenForTokenRefresh() {
    _fcm.onTokenRefresh.listen((newToken) {
      debugPrint('🔄 FCM Token refreshed: ${newToken.substring(0, 20)}...');
      _registerDeviceWithBackend(newToken);
    });
  }
}
```

**Key Features:**
- ✅ Requests notification permissions
- ✅ Initializes local notifications for foreground messages
- ✅ Retrieves FCM token with retry logic
- ✅ Registers device with backend API
- ✅ Handles foreground, background, and terminated state messages
- ✅ Shows local notifications when app is in foreground
- ✅ Listens for token refresh and re-registers device
- ✅ Gets device type and name automatically

### Phase 5: Dependency Injection

#### Step 5.1: Update Service Locator

Update file: `lib/injection_container/injection_container.dart`

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/utils/device_info_helper.dart';
import '../features/notifications/services/notification_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ========================================
  // Services
  // ========================================

  // Notification Service
  sl.registerLazySingleton<NotificationService>(
    () => NotificationService(authRepository: sl()),
  );

  // ... existing registrations ...

  // ========================================
  // External
  // ========================================

  // Flutter Local Notifications Plugin
  sl.registerLazySingleton<FlutterLocalNotificationsPlugin>(
    () => FlutterLocalNotificationsPlugin(),
  );

  // ... existing external registrations (Dio, FirebaseMessaging, etc.) ...
}
```

### Phase 6: Android Configuration

#### Step 6.1: Update AndroidManifest.xml

Update file: `android/app/src/main/AndroidManifest.xml`

Add permissions and notification channel configuration:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>

    <application
        android:label="voicely_fe"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize"
            android:showWhenLocked="true"
            android:turnScreenOn="true">
            
            <!-- Deep linking / notification taps -->
            <intent-filter>
                <action android:name="FLUTTER_NOTIFICATION_CLICK" />
                <category android:name="android.intent.category.DEFAULT" />
            </intent-filter>
            
            <!-- Existing intent filters -->
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <!-- FCM default notification channel -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="high_importance_channel" />

        <!-- Don't delete the meta-data below.
             This is used by the Flutter tool to generate GeneratedPluginRegistrant.java -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

**Key Changes:**
- Added `POST_NOTIFICATIONS` permission (Android 13+)
- Added `VIBRATE` and `RECEIVE_BOOT_COMPLETED` permissions
- Set `android:showWhenLocked` and `android:turnScreenOn` for notification wake
- Added notification click intent filter
- Set default FCM notification channel

### Phase 7: iOS Configuration

#### Step 7.1: Update Info.plist

Update file: `ios/Runner/Info.plist`

Add notification permissions:

```xml
<dict>
    <!-- Existing keys -->
    
    <!-- Notification Permissions -->
    <key>UIBackgroundModes</key>
    <array>
        <string>fetch</string>
        <string>remote-notification</string>
    </array>
    
    <key>FirebaseAppDelegateProxyEnabled</key>
    <false/>
</dict>
```

### Phase 8: App Initialization

#### Step 8.1: Update main.dart

Update file: `lib/main.dart`

Initialize notification service after Firebase initialization:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'injection_container/injection_container.dart' as di;
import 'features/notifications/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Setup dependency injection
  await di.init();

  // Initialize notification service
  final notificationService = di.sl<NotificationService>();
  await notificationService.initialize();

  runApp(const MyApp());
}
```

**Initialization Order:**
1. ✅ Ensure Flutter bindings initialized
2. ✅ Initialize Firebase
3. ✅ Setup dependency injection
4. ✅ Initialize notification service (requests permissions, gets token, registers device)
5. ✅ Run app

## Testing Guide

### Test 1: Device Registration

#### Expected Flow:
1. App launches
2. Requests notification permission
3. User grants permission
4. Retrieves FCM token
5. Calls `POST /auth/register-device` with token, device type, and device name
6. Backend returns device ID and confirmation
7. Console logs show success

#### Console Output:
```
✅ User granted notification permission
✅ FCM Token retrieved: eyJhbGciOiJIUzI1NiIsI...
✅ Device registered successfully
   Device ID: 123
   Device Type: android
   Device Name: Samsung SM-G991B
   Active: true
```

### Test 2: Foreground Notification

#### Steps:
1. Keep app in foreground
2. Send test notification from Firebase Console or backend
3. Verify local notification appears at the top of screen
4. Tap notification
5. Verify `_onNotificationTapped` callback is triggered

#### Expected Behavior:
- Notification appears as overlay/banner
- Shows title and body
- Plays sound/vibration
- Tappable

### Test 3: Background Notification

#### Steps:
1. Put app in background (press home button)
2. Send test notification
3. Tap notification in system tray
4. Verify app opens and `_handleBackgroundMessageTap` is called

### Test 4: Token Refresh

#### Steps:
1. Force token refresh (reinstall app or clear Firebase data)
2. Verify new token is obtained
3. Verify `_registerDeviceWithBackend` is called again with new token

#### Console Output:
```
🔄 FCM Token refreshed: eyJhbGciOiJIUzI1NiIsI...
✅ Device registered successfully
```

## API Endpoint Reference

### POST /auth/register-device

#### Request Headers:
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

#### Request Body:
```json
{
  "fcm_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "device_type": "android",
  "device_name": "Samsung SM-G991B"
}
```

#### Success Response (200):
```json
{
  "code": 200,
  "success": true,
  "message": "Device registered successfully",
  "data": {
    "id": 123,
    "user_id": 456,
    "fcm_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "device_type": "android",
    "device_name": "Samsung SM-G991B",
    "is_active": true,
    "last_login": "2025-12-27T10:00:00Z"
  }
}
```

#### Error Response (400):
```json
{
  "code": 400,
  "success": false,
  "message": "Invalid device type. Must be 'ios' or 'android'",
  "data": null
}
```

#### Error Response (401):
```json
{
  "code": 401,
  "success": false,
  "message": "Unauthorized - Invalid or expired token",
  "data": null
}
```

## Notification Payload Format

### Foreground Notification:
```dart
RemoteMessage(
  notification: RemoteNotification(
    title: 'Transcription Complete ✅',
    body: 'Your audio "meeting.m4a" has been transcribed successfully',
  ),
  data: {
    'type': 'transcription_complete',
    'audio_id': '30',
    'status': 'completed',
  },
)
```

### Recommended Backend Payload:
```json
{
  "notification": {
    "title": "Transcription Complete ✅",
    "body": "Your audio 'meeting.m4a' has been transcribed successfully"
  },
  "data": {
    "type": "transcription_complete",
    "audio_id": "30",
    "status": "completed",
    "click_action": "FLUTTER_NOTIFICATION_CLICK"
  },
  "android": {
    "priority": "high",
    "notification": {
      "channel_id": "high_importance_channel"
    }
  },
  "apns": {
    "payload": {
      "aps": {
        "sound": "default",
        "badge": 1
      }
    }
  }
}
```

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                          App Layer                          │
│  (main.dart - Initializes NotificationService on startup)  │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                   NotificationService                       │
│  ┌───────────────────────────────────────────────────────┐ │
│  │ 1. Request FCM permissions                            │ │
│  │ 2. Initialize local notifications                     │ │
│  │ 3. Get FCM token with retry                           │ │
│  │ 4. Register device via AuthRepository                 │ │
│  │ 5. Setup message handlers                             │ │
│  │ 6. Listen for token refresh                           │ │
│  └───────────────────────────────────────────────────────┘ │
└────────┬───────────────────────────────────┬───────────────┘
         │                                   │
         │ Uses                              │ Uses
         ▼                                   ▼
┌─────────────────────┐          ┌──────────────────────────┐
│  AuthRepository     │          │ FlutterLocalNotifications│
│  ┌───────────────┐ │          │  ┌────────────────────┐  │
│  │registerDevice │ │          │  │ Show notifications │  │
│  └───────┬───────┘ │          │  │ in foreground      │  │
└──────────┼─────────┘          │  └────────────────────┘  │
           │                     └──────────────────────────┘
           ▼
┌─────────────────────────────┐
│ AuthRemoteDataSource        │
│  ┌───────────────────────┐  │
│  │ POST /auth/register-  │  │
│  │      device           │  │
│  └───────────────────────┘  │
└─────────────────────────────┘
           │
           ▼
┌─────────────────────────────┐
│      Backend API            │
│  (FastAPI + PostgreSQL)     │
└─────────────────────────────┘
```

## File Structure

```
lib/
├── core/
│   └── utils/
│       └── device_info_helper.dart          # NEW: Get device type & name
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_data_source.dart  # UPDATED: Add registerDevice()
│   │   │   ├── models/
│   │   │   │   ├── device_register_request_model.dart   # NEW
│   │   │   │   └── device_register_response_model.dart  # NEW
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart     # UPDATED: Add registerDevice()
│   │   └── domain/
│   │       └── repositories/
│   │           └── auth_repository.dart          # UPDATED: Add registerDevice()
│   └── notifications/
│       └── services/
│           └── notification_service.dart         # UPDATED: Enhanced with registration & local notifications
├── injection_container/
│   └── injection_container.dart                  # UPDATED: Register NotificationService
└── main.dart                                     # UPDATED: Initialize NotificationService
```

## Common Issues & Troubleshooting

### Issue 1: FCM Token is Null
**Symptoms:** Console shows "Token is null, retrying..."

**Solutions:**
1. Verify Firebase is initialized before calling `getToken()`
2. Check `google-services.json` is in `android/app/`
3. Verify internet connection
4. Ensure Firebase project has FCM enabled
5. Retry logic will attempt 3 times with 2-second delays

### Issue 2: Device Registration Fails with 401
**Symptoms:** "Device registration failed: Unauthorized"

**Solutions:**
1. Verify user is logged in
2. Check access token is valid and not expired
3. Ensure Dio interceptor is adding `Authorization` header
4. Try refreshing the token

### Issue 3: Foreground Notifications Not Showing
**Symptoms:** No notification appears when app is open

**Solutions:**
1. Verify `flutter_local_notifications` is initialized
2. Check notification channel is created (Android)
3. Verify notification permissions granted
4. Check `_handleForegroundMessage` is being called
5. Ensure payload has `notification` field (not just `data`)

### Issue 4: Background Notifications Work but Foreground Don't
**Cause:** FCM automatically handles background notifications, but foreground requires manual handling

**Solution:** This is expected behavior. The implementation correctly shows local notifications for foreground messages.

### Issue 5: Device Name is Null
**Symptoms:** `device_name` is null in backend

**Solutions:**
1. This is optional - backend accepts null
2. Verify `device_info_plus` package is installed
3. Check platform permissions for device info
4. Android may return manufacturer + model, iOS returns user-set name

## Next Steps

### Phase 9: Navigation from Notifications
Implement deep linking to navigate to specific screens when notifications are tapped:

```dart
void _onNotificationTapped(NotificationResponse response) {
  final payload = response.payload;
  if (payload != null) {
    final data = jsonDecode(payload);
    final type = data['type'];
    
    switch (type) {
      case 'transcription_complete':
        // Navigate to audio detail screen
        final audioId = data['audio_id'];
        navigatorKey.currentState?.pushNamed(
          '/audio-detail',
          arguments: audioId,
        );
        break;
      case 'summarization_complete':
        // Navigate to summary screen
        break;
      // Add more cases as needed
    }
  }
}
```

### Phase 10: Badge Count Management
Implement badge counter for unread notifications:
- Use `flutter_app_badger` package
- Update badge on new notification
- Clear badge when notifications are read

### Phase 11: Notification Preferences
Allow users to customize notification settings:
- Enable/disable specific notification types
- Quiet hours
- Sound preferences
- Store preferences locally and sync with backend

## Summary

This implementation provides:
- ✅ Automatic device FCM token registration on app launch
- ✅ Token refresh handling with automatic re-registration
- ✅ Device type and name detection
- ✅ Foreground notification display using local notifications
- ✅ Background and terminated state notification handling
- ✅ Clean architecture with proper separation of concerns
- ✅ Error handling and retry logic
- ✅ Comprehensive logging for debugging
- ✅ Support for both Android and iOS platforms

The user's device is now fully registered with the backend and ready to receive push notifications in all app states!
