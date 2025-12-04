import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/forgot_password_screen.dart';
import '../../features/landing/presentation/pages/landing_page.dart';
import '../../features/recording/presentation/pages/recording_page.dart';
import '../../features/transcription/presentation/pages/transcript_list_screen.dart';
import '../../features/transcription/presentation/pages/add_folder_screen.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import '../../features/profile/presentation/pages/edit_profile_screen.dart';
import '../../features/test/presentation/pages/test_screen.dart';
import '../../features/transcription/presentation/pages/transcription_page.dart';
import '../../features/summary/presentation/pages/summary_page.dart';

class AppRoutes {
  static const String landing = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String recording = '/recording';
  static const String transcriptList = '/transcript-list';
  static const String addFolder = '/add-folder';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String test = '/test';
  static const String transcriptionResult = '/transcription-result';
  static const String transcription = '/transcription';
  static const String summary = '/summary';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.landing,
  routes: [
    GoRoute(
      path: AppRoutes.landing,
      name: 'landing',
      builder: (context, state) => const LandingPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      name: 'signup',
      builder: (context, state) => const SignupPage(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      name: 'forgotPassword',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.recording,
      name: 'recording',
      builder: (context, state) => const RecordingPage(),
    ),
    GoRoute(
      path: AppRoutes.transcriptList,
      name: 'transcriptList',
      builder: (context, state) => const TranscriptListScreen(),
    ),
    GoRoute(
      path: AppRoutes.addFolder,
      name: 'addFolder',
      builder: (context, state) => const AddFolderScreen(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      name: 'editProfile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.test,
      name: 'test',
      builder: (context, state) => const TestPage(),
    ),
    GoRoute(
      path: AppRoutes.transcription,
      name: 'transcription',
      builder: (context, state) {
        final meetingTitle = state.uri.queryParameters['title'];
        return TranscriptionPage(meetingTitle: meetingTitle);
      },
    ),
    GoRoute(
      path: AppRoutes.summary,
      name: 'summary',
      builder: (context, state) {
        final meetingTitle = state.uri.queryParameters['title'];
        final transcriptionId = state.uri.queryParameters['transcriptionId'];
        return SummaryPage(
          meetingTitle: meetingTitle,
          transcriptionId: transcriptionId,
        );
      },
    ),
  ],
  errorBuilder:
      (context, state) =>
          Scaffold(body: Center(child: Text('Page not found: ${state.error}'))),
);
