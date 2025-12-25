import 'dart:io';
import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/errors/failures.dart';
import '../entities/audio_file_page.dart';
import '../entities/audio_filter.dart';
import '../entities/audio_upload_result.dart';
import '../entities/server_task_bucket.dart';
import '../entities/pending_task_bucket.dart';
import '../entities/task.dart';
import '../entities/task_search_criteria.dart';

abstract class AudioManagerRepository {
  Future<Either<Failure, AudioFilePage>> getUploadedAudios(
    AudioFilter filter,
  );
  Future<Either<Failure, AudioUploadResult>> uploadAudioFile(File audioFile);
  Future<Either<Failure, ServerTaskBucket>> getServerTasks();
  Future<Either<Failure, PendingTaskBucket>> getPendingTasks();
  Future<Either<Failure, List<Task>>> searchTasks(
    TaskSearchCriteria criteria,
  );
}
