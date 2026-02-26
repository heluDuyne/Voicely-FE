import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/folder.dart';
import '../entities/folder_create.dart';
import '../repositories/folder_repository.dart';

class CreateFolder
    implements UseCase<Either<Failure, Folder>, FolderCreate> {
  final FolderRepository repository;

  CreateFolder(this.repository);

  @override
  Future<Either<Failure, Folder>> call(FolderCreate params) async {
    return await repository.createFolder(params);
  }
}
