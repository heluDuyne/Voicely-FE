import 'package:equatable/equatable.dart';
import '../../domain/entities/folder_create.dart';
import '../../domain/entities/folder_update.dart';
import '../../domain/entities/move_audio_to_folder.dart' as dto;

abstract class FolderEvent extends Equatable {
  const FolderEvent();

  @override
  List<Object?> get props => [];
}

class LoadFolders extends FolderEvent {
  const LoadFolders();
}

class LoadAllFolders extends FolderEvent {
  final String? query;
  final int pageSize;

  const LoadAllFolders({this.query, this.pageSize = 10});

  @override
  List<Object?> get props => [query, pageSize];
}

class SearchFolders extends FolderEvent {
  final String query;

  const SearchFolders(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadMoreFolders extends FolderEvent {
  const LoadMoreFolders();
}

class CreateFolder extends FolderEvent {
  final FolderCreate request;

  const CreateFolder(this.request);

  @override
  List<Object?> get props => [request];
}

class LoadFolderDetails extends FolderEvent {
  final int folderId;

  const LoadFolderDetails(this.folderId);

  @override
  List<Object?> get props => [folderId];
}

class LoadAudioInFolder extends FolderEvent {
  final int folderId;
  final int skip;
  final int limit;

  const LoadAudioInFolder({
    required this.folderId,
    this.skip = 0,
    this.limit = 100,
  });

  @override
  List<Object?> get props => [folderId, skip, limit];
}

class UpdateFolder extends FolderEvent {
  final int folderId;
  final FolderUpdate update;

  const UpdateFolder({required this.folderId, required this.update});

  @override
  List<Object?> get props => [folderId, update];
}

class DeleteFolder extends FolderEvent {
  final int folderId;

  const DeleteFolder(this.folderId);

  @override
  List<Object?> get props => [folderId];
}

class MoveAudioToFolderEvent extends FolderEvent {
  final dto.MoveAudioToFolder request;

  const MoveAudioToFolderEvent(this.request);

  @override
  List<Object?> get props => [request];
}

class LoadRecentTranscripts extends FolderEvent {
  const LoadRecentTranscripts();
}

class ClearFolderMessage extends FolderEvent {
  const ClearFolderMessage();
}
