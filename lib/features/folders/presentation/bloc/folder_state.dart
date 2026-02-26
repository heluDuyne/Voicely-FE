import 'package:equatable/equatable.dart';
import '../../../audio_manager/domain/entities/audio_file.dart';
import '../../domain/entities/folder.dart';

class FolderState extends Equatable {
  final List<Folder> homeFolders;
  final int homeTotalCount;
  final bool isLoadingHome;
  final List<Folder> allFolders;
  final int allPage;
  final int allLimit;
  final bool hasMoreAll;
  final bool isLoadingAll;
  final bool isLoadingMore;
  final String searchQuery;
  final Folder? selectedFolder;
  final List<AudioFile> folderAudios;
  final bool isLoadingDetails;
  final bool isLoadingFolderAudios;
  final List<AudioFile> recentTranscripts;
  final bool isLoadingRecent;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final bool isMovingAudio;
  final String? errorMessage;
  final String? successMessage;

  const FolderState({
    required this.homeFolders,
    required this.homeTotalCount,
    required this.isLoadingHome,
    required this.allFolders,
    required this.allPage,
    required this.allLimit,
    required this.hasMoreAll,
    required this.isLoadingAll,
    required this.isLoadingMore,
    required this.searchQuery,
    required this.selectedFolder,
    required this.folderAudios,
    required this.isLoadingDetails,
    required this.isLoadingFolderAudios,
    required this.recentTranscripts,
    required this.isLoadingRecent,
    required this.isCreating,
    required this.isUpdating,
    required this.isDeleting,
    required this.isMovingAudio,
    required this.errorMessage,
    required this.successMessage,
  });

  factory FolderState.initial() {
    return const FolderState(
      homeFolders: [],
      homeTotalCount: 0,
      isLoadingHome: false,
      allFolders: [],
      allPage: 1,
      allLimit: 10,
      hasMoreAll: true,
      isLoadingAll: false,
      isLoadingMore: false,
      searchQuery: '',
      selectedFolder: null,
      folderAudios: [],
      isLoadingDetails: false,
      isLoadingFolderAudios: false,
      recentTranscripts: [],
      isLoadingRecent: false,
      isCreating: false,
      isUpdating: false,
      isDeleting: false,
      isMovingAudio: false,
      errorMessage: null,
      successMessage: null,
    );
  }

  FolderState copyWith({
    List<Folder>? homeFolders,
    int? homeTotalCount,
    bool? isLoadingHome,
    List<Folder>? allFolders,
    int? allPage,
    int? allLimit,
    bool? hasMoreAll,
    bool? isLoadingAll,
    bool? isLoadingMore,
    String? searchQuery,
    Folder? selectedFolder,
    List<AudioFile>? folderAudios,
    bool? isLoadingDetails,
    bool? isLoadingFolderAudios,
    List<AudioFile>? recentTranscripts,
    bool? isLoadingRecent,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    bool? isMovingAudio,
    String? errorMessage,
    String? successMessage,
  }) {
    return FolderState(
      homeFolders: homeFolders ?? this.homeFolders,
      homeTotalCount: homeTotalCount ?? this.homeTotalCount,
      isLoadingHome: isLoadingHome ?? this.isLoadingHome,
      allFolders: allFolders ?? this.allFolders,
      allPage: allPage ?? this.allPage,
      allLimit: allLimit ?? this.allLimit,
      hasMoreAll: hasMoreAll ?? this.hasMoreAll,
      isLoadingAll: isLoadingAll ?? this.isLoadingAll,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFolder: selectedFolder ?? this.selectedFolder,
      folderAudios: folderAudios ?? this.folderAudios,
      isLoadingDetails: isLoadingDetails ?? this.isLoadingDetails,
      isLoadingFolderAudios:
          isLoadingFolderAudios ?? this.isLoadingFolderAudios,
      recentTranscripts: recentTranscripts ?? this.recentTranscripts,
      isLoadingRecent: isLoadingRecent ?? this.isLoadingRecent,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      isMovingAudio: isMovingAudio ?? this.isMovingAudio,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
    homeFolders,
    homeTotalCount,
    isLoadingHome,
    allFolders,
    allPage,
    allLimit,
    hasMoreAll,
    isLoadingAll,
    isLoadingMore,
    searchQuery,
    selectedFolder,
    folderAudios,
    isLoadingDetails,
    isLoadingFolderAudios,
    recentTranscripts,
    isLoadingRecent,
    isCreating,
    isUpdating,
    isDeleting,
    isMovingAudio,
    errorMessage,
    successMessage,
  ];
}
