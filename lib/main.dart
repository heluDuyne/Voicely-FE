import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:voicely_fe/features/notifications/services/notification_service.dart';
import 'package:voicely_fe/firebase_options.dart';

import 'injection_container/injection_container.dart' as di;
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/recording/presentation/bloc/recording_bloc.dart';
import 'features/transcription/presentation/bloc/transcription_bloc.dart';
import 'features/summary/presentation/bloc/summary_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await di.init();
  final notificationService = di.sl<NotificationService>();
  await notificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(CheckAuthStatus()),
        ),
        BlocProvider<RecordingBloc>(create: (_) => di.sl<RecordingBloc>()),
        BlocProvider<TranscriptionBloc>(
          create: (_) => di.sl<TranscriptionBloc>(),
        ),
        BlocProvider<SummaryBloc>(create: (_) => di.sl<SummaryBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Voicely',
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [FlutterQuillLocalizations.delegate],
      ),
    );
  }
}
