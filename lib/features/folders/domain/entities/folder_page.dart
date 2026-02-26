import 'package:equatable/equatable.dart';
import 'folder.dart';

class FolderPage extends Equatable {
  final List<Folder> items;
  final int total;
  final int page;
  final int limit;
  final bool? hasNextPage;

  const FolderPage({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    this.hasNextPage,
  });

  @override
  List<Object?> get props => [items, total, page, limit, hasNextPage];
}
