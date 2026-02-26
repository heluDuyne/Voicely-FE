import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../audio_manager/domain/entities/audio_file.dart';
import '../entities/folder.dart';
import '../entities/folder_create.dart';
import '../entities/folder_page.dart';
import '../entities/folder_search_dto.dart';
import '../entities/folder_update.dart';
import '../entities/move_audio_to_folder.dart';

abstract class FolderRepository {
  Future<Either<Failure, Folder>> createFolder(FolderCreate request);
  Future<Either<Failure, FolderPage>> searchFolders(FolderSearchDto request);
  Future<Either<Failure, Folder>> getFolderDetails(int folderId);
  Future<Either<Failure, Folder>> updateFolder(
    int folderId,
    FolderUpdate request,
  );
  Future<Either<Failure, bool>> deleteFolder(int folderId);
  Future<Either<Failure, List<AudioFile>>> getAudioInFolder(
    int folderId, {
    int skip = 0,
    int limit = 100,
  });
  Future<Either<Failure, AudioFile>> moveAudioToFolder(
    MoveAudioToFolder request,
  );
}
