import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../../../audio_manager/domain/entities/audio_file.dart';
import '../entities/move_audio_to_folder.dart' as dto;
import '../repositories/folder_repository.dart';

class MoveAudioToFolderUseCase
    implements UseCase<Either<Failure, AudioFile>, dto.MoveAudioToFolder> {
  final FolderRepository repository;

  MoveAudioToFolderUseCase(this.repository);

  @override
  Future<Either<Failure, AudioFile>> call(
    dto.MoveAudioToFolder params,
  ) async {
    return await repository.moveAudioToFolder(params);
  }
}
