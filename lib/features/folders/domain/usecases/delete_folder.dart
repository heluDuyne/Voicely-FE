import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../repositories/folder_repository.dart';

class DeleteFolder
    implements UseCase<Either<Failure, bool>, int> {
  final FolderRepository repository;

  DeleteFolder(this.repository);

  @override
  Future<Either<Failure, bool>> call(int params) async {
    return await repository.deleteFolder(params);
  }
}
