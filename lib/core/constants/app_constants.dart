class AppConstants {
  // API for android emulator
  static const String baseUrl =
      'http://10.0.2.2:8000';
  // static const String apiVersion = '/v1'; // Commented out API version prefix

  // Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String signupEndpoint = '/auth/register';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String audioFilesEndpoint = '/audio/files';
  static const String audioSearchEndpoint = '/audio/search';
  static const String audioUploadEndpoint = '/audio/upload';
  static const String audioUploadAsyncEndpoint = '/audio/upload-async';
  static const String activeTasksEndpoint = '/tasks/active';
  static const String searchTasksEndpoint = '/tasks/search';
  static const String pendingTasksEndpoint = '/tasks/pending';

  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String isFirstTimeKey = 'is_first_time';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Recording limits
  static const Duration maxRecordingDuration = Duration(hours: 2);
  static const int maxRecordingSeconds = 7200;

  // Task polling
  static const Duration taskPollingInterval = Duration(seconds: 3);
  static const int maxPollingRetries = 3;

  // App Info
  static const String appName = 'Voicely';
  static const String appVersion = '1.0.0';
}
