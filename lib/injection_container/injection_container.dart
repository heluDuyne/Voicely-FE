import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import '../core/network/network_client.dart';
import '../core/network/network_info.dart';

// Features - Auth
import '../features/auth/data/datasources/auth_local_data_source.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/login_user.dart';
import '../features/auth/domain/usecases/signup_user.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';

// Features - Transcription
import '../features/transcription/data/datasources/transcription_remote_data_source.dart';
import '../features/transcription/data/repositories/transcription_repository_impl.dart';
import '../features/transcription/domain/repositories/transcription_repository.dart';
import '../features/transcription/domain/usecases/upload_audio.dart';
import '../features/transcription/domain/usecases/transcribe_audio.dart';
import '../features/transcription/presentation/bloc/transcription_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // Bloc
  sl.registerFactory(() => AuthBloc(loginUser: sl(), signupUser: sl()));

  // Use cases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => SignupUser(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );

  //! Features - Transcription
  // Bloc
  sl.registerFactory(
    () => TranscriptionBloc(uploadAudio: sl(), transcribeAudio: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => UploadAudio(sl()));
  sl.registerLazySingleton(() => TranscribeAudio(sl()));

  // Repository
  sl.registerLazySingleton<TranscriptionRepository>(
    () => TranscriptionRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
      authLocalDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<TranscriptionRemoteDataSource>(
    () => TranscriptionRemoteDataSourceImpl(dio: sl()),
  );

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Register AuthLocalDataSource first
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  final networkClient = NetworkClient(
    authLocalDataSource: sl<AuthLocalDataSource>(),
  );
  sl.registerLazySingleton(() => networkClient.dio);
}
