import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/folder.dart';
import '../entities/folder_update.dart';
import '../repositories/folder_repository.dart';

class UpdateFolder
    implements UseCase<Either<Failure, Folder>, UpdateFolderParams> {
  final FolderRepository repository;

  UpdateFolder(this.repository);

  @override
  Future<Either<Failure, Folder>> call(UpdateFolderParams params) async {
    return await repository.updateFolder(params.folderId, params.update);
  }
}

class UpdateFolderParams extends Equatable {
  final int folderId;
  final FolderUpdate update;

  const UpdateFolderParams({
    required this.folderId,
    required this.update,
  });

  @override
  List<Object?> get props => [folderId, update];
}
