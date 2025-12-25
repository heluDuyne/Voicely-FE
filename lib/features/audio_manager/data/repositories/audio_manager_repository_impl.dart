import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../domain/entities/audio_file_page.dart';
import '../../domain/entities/audio_filter.dart';
import '../../domain/entities/audio_upload_result.dart';
import '../../domain/entities/pending_task_bucket.dart';
import '../../domain/entities/server_task_bucket.dart';
import '../../domain/repositories/audio_manager_repository.dart';
import '../datasources/audio_manager_local_data_source.dart';
import '../datasources/audio_manager_remote_data_source.dart';
import '../models/audio_filter_model.dart';

class AudioManagerRepositoryImpl implements AudioManagerRepository {
  final AudioManagerRemoteDataSource remoteDataSource;
  final AudioManagerLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final AuthLocalDataSource authLocalDataSource;

  AudioManagerRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.authLocalDataSource,
  });

  @override
  Future<Either<Failure, AudioFilePage>> getUploadedAudios(
    AudioFilter filter,
  ) async {
    final token = await authLocalDataSource.getAccessToken();
    if (token == null) {
      return const Left(UnauthorizedFailure('Please login to view audio files'));
    }

    if (await networkInfo.isConnected) {
      try {
        final page = await remoteDataSource.getAudioFiles(
          AudioFilterModel(
            search: filter.search,
            fromDate: filter.fromDate,
            toDate: filter.toDate,
            page: filter.page,
            limit: filter.limit,
          ),
        );
        await localDataSource.cacheAudioFiles(page);
        return Right(page);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      }
    }

    final cached = await localDataSource.getCachedAudioFiles();
    if (cached != null) {
      return Right(cached);
    }

    return const Left(NetworkFailure('No internet connection'));
  }

  @override
  Future<Either<Failure, AudioUploadResult>> uploadAudioFile(
    File audioFile,
  ) async {
    final token = await authLocalDataSource.getAccessToken();
    if (token == null) {
      return const Left(UnauthorizedFailure('Please login to upload audio'));
    }

    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.uploadAudioFile(audioFile);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      }
    }

    return const Left(NetworkFailure('No internet connection'));
  }

  @override
  Future<Either<Failure, ServerTaskBucket>> getServerTasks() async {
    final token = await authLocalDataSource.getAccessToken();
    if (token == null) {
      return const Left(UnauthorizedFailure('Please login to view tasks'));
    }

    if (await networkInfo.isConnected) {
      try {
        final tasks = await remoteDataSource.getServerTasks();
        await localDataSource.cacheServerTasks(tasks);
        return Right(tasks);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      }
    }

    final cached = await localDataSource.getCachedServerTasks();
    if (cached != null) {
      return Right(cached);
    }

    return const Left(NetworkFailure('No internet connection'));
  }

  @override
  Future<Either<Failure, PendingTaskBucket>> getPendingTasks() async {
    final token = await authLocalDataSource.getAccessToken();
    if (token == null) {
      return const Left(UnauthorizedFailure('Please login to view pending tasks'));
    }

    if (await networkInfo.isConnected) {
      try {
        final tasks = await remoteDataSource.getPendingTasks();
        await localDataSource.cachePendingTasks(tasks);
        return Right(tasks);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      }
    }

    final cached = await localDataSource.getCachedPendingTasks();
    if (cached != null) {
      return Right(cached);
    }

    return const Left(NetworkFailure('No internet connection'));
  }
}
