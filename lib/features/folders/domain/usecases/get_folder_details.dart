import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/folder.dart';
import '../repositories/folder_repository.dart';

class GetFolderDetails
    implements UseCase<Either<Failure, Folder>, int> {
  final FolderRepository repository;

  GetFolderDetails(this.repository);

  @override
  Future<Either<Failure, Folder>> call(int params) async {
    return await repository.getFolderDetails(params);
  }
}
