import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/recording.dart';
import '../../domain/repositories/recording_repository.dart';
import '../datasources/recording_local_data_source.dart';

class RecordingRepositoryImpl implements RecordingRepository {
  final RecordingLocalDataSource localDataSource;

  RecordingRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, void>> startRecording() async {
    try {
      await localDataSource.startRecording();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, Recording>> stopRecording() async {
    try {
      final recording = await localDataSource.stopRecording();
      return Right(recording);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> pauseRecording() async {
    try {
      await localDataSource.pauseRecording();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> resumeRecording() async {
    try {
      await localDataSource.resumeRecording();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, File>> importAudioFile() async {
    try {
      final file = await localDataSource.importAudioFile();
      return Right(file);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  RecordingStatus getRecordingStatus() {
    return localDataSource.getRecordingStatus();
  }

  @override
  Stream<Duration> get durationStream => localDataSource.durationStream;
}





