import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../../../audio_manager/domain/entities/audio_file.dart';
import '../repositories/folder_repository.dart';

class GetAudioInFolder
    implements UseCase<Either<Failure, List<AudioFile>>, GetAudioInFolderParams> {
  final FolderRepository repository;

  GetAudioInFolder(this.repository);

  @override
  Future<Either<Failure, List<AudioFile>>> call(
    GetAudioInFolderParams params,
  ) async {
    return await repository.getAudioInFolder(
      params.folderId,
      skip: params.skip,
      limit: params.limit,
    );
  }
}

class GetAudioInFolderParams extends Equatable {
  final int folderId;
  final int skip;
  final int limit;

  const GetAudioInFolderParams({
    required this.folderId,
    this.skip = 0,
    this.limit = 100,
  });

  @override
  List<Object?> get props => [folderId, skip, limit];
}
