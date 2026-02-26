import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/folder_page.dart';
import '../entities/folder_search_dto.dart';
import '../repositories/folder_repository.dart';

class SearchFolders
    implements UseCase<Either<Failure, FolderPage>, FolderSearchDto> {
  final FolderRepository repository;

  SearchFolders(this.repository);

  @override
  Future<Either<Failure, FolderPage>> call(FolderSearchDto params) async {
    return await repository.searchFolders(params);
  }
}
