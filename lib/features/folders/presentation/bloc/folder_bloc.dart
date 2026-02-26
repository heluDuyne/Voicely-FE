import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../audio_manager/domain/entities/audio_filter.dart';
import '../../../audio_manager/domain/usecases/get_uploaded_audios.dart';
import '../../domain/entities/folder.dart';
import '../../domain/entities/folder_search_dto.dart';
import '../../domain/usecases/create_folder.dart' as folder_create_usecase;
import '../../domain/usecases/delete_folder.dart' as folder_delete_usecase;
import '../../domain/usecases/get_audio_in_folder.dart';
import '../../domain/usecases/get_folder_details.dart';
import '../../domain/usecases/move_audio_to_folder.dart';
import '../../domain/usecases/search_folders.dart' as folder_search_usecase;
import '../../domain/usecases/update_folder.dart' as folder_update_usecase;
import 'folder_event.dart';
import 'folder_state.dart';

class FolderBloc extends Bloc<FolderEvent, FolderState> {
  final folder_create_usecase.CreateFolder createFolder;
  final folder_search_usecase.SearchFolders searchFolders;
  final GetFolderDetails getFolderDetails;
  final folder_update_usecase.UpdateFolder updateFolder;
  final folder_delete_usecase.DeleteFolder deleteFolder;
  final GetAudioInFolder getAudioInFolder;
  final MoveAudioToFolderUseCase moveAudioToFolder;
  final GetUploadedAudios getUploadedAudios;

  FolderBloc({
    required this.createFolder,
    required this.searchFolders,
    required this.getFolderDetails,
    required this.updateFolder,
    required this.deleteFolder,
    required this.getAudioInFolder,
    required this.moveAudioToFolder,
    required this.getUploadedAudios,
  }) : super(FolderState.initial()) {
    on<LoadFolders>(_onLoadFolders);
    on<LoadAllFolders>(_onLoadAllFolders);
    on<SearchFolders>(_onSearchFolders);
    on<LoadMoreFolders>(_onLoadMoreFolders);
    on<CreateFolder>(_onCreateFolder);
    on<LoadFolderDetails>(_onLoadFolderDetails);
    on<LoadAudioInFolder>(_onLoadAudioInFolder);
    on<UpdateFolder>(_onUpdateFolder);
    on<DeleteFolder>(_onDeleteFolder);
    on<MoveAudioToFolderEvent>(_onMoveAudioToFolder);
    on<LoadRecentTranscripts>(_onLoadRecentTranscripts);
    on<ClearFolderMessage>(_onClearMessage);
  }

  Future<void> _onLoadFolders(
    LoadFolders event,
    Emitter<FolderState> emit,
  ) async {
    emit(state.copyWith(isLoadingHome: true, errorMessage: null));

    final result = await searchFolders(
      const FolderSearchDto(page: 1, pageSize: 3, order: 'DESC'),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingHome: false, errorMessage: failure.message),
      ),
      (page) => emit(
        state.copyWith(
          isLoadingHome: false,
          homeFolders: page.items,
          homeTotalCount: page.total,
        ),
      ),
    );
  }

  Future<void> _onLoadAllFolders(
    LoadAllFolders event,
    Emitter<FolderState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoadingAll: true,
        errorMessage: null,
        searchQuery: event.query ?? state.searchQuery,
      ),
    );

    final result = await searchFolders(
      FolderSearchDto(
        page: 1,
        pageSize: event.pageSize,
        order: 'DESC',
        search: event.query ?? state.searchQuery,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingAll: false, errorMessage: failure.message),
      ),
      (page) => emit(
        state.copyWith(
          isLoadingAll: false,
          allFolders: page.items,
          allPage: page.page,
          allLimit: page.limit,
          hasMoreAll:
              page.hasNextPage ??
              page.items.length < page.total,
        ),
      ),
    );
  }

  Future<void> _onSearchFolders(
    SearchFolders event,
    Emitter<FolderState> emit,
  ) async {
    emit(state.copyWith(searchQuery: event.query));
    await _onLoadAllFolders(
      LoadAllFolders(query: event.query, pageSize: state.allLimit),
      emit,
    );
  }

  Future<void> _onLoadMoreFolders(
    LoadMoreFolders event,
    Emitter<FolderState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMoreAll) {
      return;
    }

    final nextPage = state.allPage + 1;
    emit(state.copyWith(isLoadingMore: true, errorMessage: null));

    final result = await searchFolders(
      FolderSearchDto(
        page: nextPage,
        pageSize: state.allLimit,
        order: 'DESC',
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingMore: false, errorMessage: failure.message),
      ),
      (page) => emit(
        state.copyWith(
          isLoadingMore: false,
          allFolders: [...state.allFolders, ...page.items],
          allPage: page.page,
          allLimit: page.limit,
          hasMoreAll:
              page.hasNextPage ??
              state.allFolders.length + page.items.length < page.total,
        ),
      ),
    );
  }

  Future<void> _onCreateFolder(
    CreateFolder event,
    Emitter<FolderState> emit,
  ) async {
    emit(state.copyWith(isCreating: true, errorMessage: null));

    final result = await createFolder(event.request);
    result.fold(
      (failure) => emit(
        state.copyWith(isCreating: false, errorMessage: failure.message),
      ),
      (folder) {
        final updatedHome = [
          folder,
          ...state.homeFolders.where((item) => item.id != folder.id),
        ];
        final limitedHome =
            updatedHome.length > 3 ? updatedHome.sublist(0, 3) : updatedHome;
        final updatedAll = [
          folder,
          ...state.allFolders.where((item) => item.id != folder.id),
        ];
        emit(
          state.copyWith(
            isCreating: false,
            homeFolders: limitedHome,
            homeTotalCount: state.homeTotalCount + 1,
            allFolders: updatedAll,
            successMessage: 'Folder created successfully',
          ),
        );
      },
    );
  }

  Future<void> _onLoadFolderDetails(
    LoadFolderDetails event,
    Emitter<FolderState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoadingDetails: true,
        isLoadingFolderAudios: true,
        errorMessage: null,
      ),
    );

    final detailsResult = await getFolderDetails(event.folderId);
    FolderState nextState = state;
    detailsResult.fold(
      (failure) => nextState = state.copyWith(
        isLoadingDetails: false,
        errorMessage: failure.message,
      ),
      (folder) =>
          nextState = state.copyWith(isLoadingDetails: false, selectedFolder: folder),
    );

    emit(nextState);

    final audioResult = await getAudioInFolder(
      GetAudioInFolderParams(folderId: event.folderId),
    );
    audioResult.fold(
      (failure) => emit(
        state.copyWith(
          isLoadingFolderAudios: false,
          errorMessage: failure.message,
        ),
      ),
      (audios) => emit(
        state.copyWith(isLoadingFolderAudios: false, folderAudios: audios),
      ),
    );
  }

  Future<void> _onLoadAudioInFolder(
    LoadAudioInFolder event,
    Emitter<FolderState> emit,
  ) async {
    emit(state.copyWith(isLoadingFolderAudios: true, errorMessage: null));

    final result = await getAudioInFolder(
      GetAudioInFolderParams(
        folderId: event.folderId,
        skip: event.skip,
        limit: event.limit,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoadingFolderAudios: false,
          errorMessage: failure.message,
        ),
      ),
      (audios) => emit(
        state.copyWith(isLoadingFolderAudios: false, folderAudios: audios),
      ),
    );
  }

  Future<void> _onUpdateFolder(
    UpdateFolder event,
    Emitter<FolderState> emit,
  ) async {
    emit(state.copyWith(isUpdating: true, errorMessage: null));

    final result = await updateFolder(
      folder_update_usecase.UpdateFolderParams(
        folderId: event.folderId,
        update: event.update,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isUpdating: false, errorMessage: failure.message),
      ),
      (folder) {
        emit(
          state.copyWith(
            isUpdating: false,
            selectedFolder: state.selectedFolder?.id == folder.id
                ? folder
                : state.selectedFolder,
            homeFolders: _replaceFolder(state.homeFolders, folder),
            allFolders: _replaceFolder(state.allFolders, folder),
            successMessage: 'Folder updated',
          ),
        );
      },
    );
  }

  Future<void> _onDeleteFolder(
    DeleteFolder event,
    Emitter<FolderState> emit,
  ) async {
    emit(state.copyWith(isDeleting: true, errorMessage: null));

    final result = await deleteFolder(event.folderId);
    result.fold(
      (failure) => emit(
        state.copyWith(isDeleting: false, errorMessage: failure.message),
      ),
      (_) {
        final updatedHome =
            state.homeFolders.where((item) => item.id != event.folderId).toList();
        final updatedAll =
            state.allFolders.where((item) => item.id != event.folderId).toList();
        emit(
          state.copyWith(
            isDeleting: false,
            homeFolders: updatedHome,
            allFolders: updatedAll,
            homeTotalCount:
                state.homeTotalCount > 0 ? state.homeTotalCount - 1 : 0,
            selectedFolder:
                state.selectedFolder?.id == event.folderId
                    ? null
                    : state.selectedFolder,
            folderAudios:
                state.selectedFolder?.id == event.folderId
                    ? []
                    : state.folderAudios,
            successMessage: 'Folder deleted',
          ),
        );
      },
    );
  }

  Future<void> _onMoveAudioToFolder(
    MoveAudioToFolderEvent event,
    Emitter<FolderState> emit,
  ) async {
    emit(state.copyWith(isMovingAudio: true, errorMessage: null));

    final result = await moveAudioToFolder(event.request);
    result.fold(
      (failure) => emit(
        state.copyWith(isMovingAudio: false, errorMessage: failure.message),
      ),
      (audioFile) {
        final selectedFolderId = state.selectedFolder?.id;
        final updatedAudios = [...state.folderAudios];
        final existingIndex = updatedAudios.indexWhere(
          (item) => item.id == audioFile.id,
        );
        if (selectedFolderId != null &&
            audioFile.folderId != selectedFolderId) {
          if (existingIndex != -1) {
            updatedAudios.removeAt(existingIndex);
          }
        } else if (existingIndex != -1) {
          updatedAudios[existingIndex] = audioFile;
        }
        emit(
          state.copyWith(
            isMovingAudio: false,
            folderAudios: updatedAudios,
            successMessage: 'Audio moved successfully',
          ),
        );
      },
    );
  }

  Future<void> _onLoadRecentTranscripts(
    LoadRecentTranscripts event,
    Emitter<FolderState> emit,
  ) async {
    emit(state.copyWith(isLoadingRecent: true, errorMessage: null));

    final result = await getUploadedAudios(
      const AudioFilter(
        page: 1,
        limit: 3,
        order: 'DESC',
        status: 'completed',
        hasTranscript: true,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingRecent: false, errorMessage: failure.message),
      ),
      (page) => emit(
        state.copyWith(isLoadingRecent: false, recentTranscripts: page.items),
      ),
    );
  }

  void _onClearMessage(
    ClearFolderMessage event,
    Emitter<FolderState> emit,
  ) {
    emit(state.copyWith(errorMessage: null, successMessage: null));
  }

  List<Folder> _replaceFolder(List<Folder> list, Folder updated) {
    return list
        .map((item) => item.id == updated.id ? updated : item)
        .toList();
  }
}
