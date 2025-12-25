import 'package:equatable/equatable.dart';
import '../../domain/entities/audio_file.dart';
import '../../domain/entities/pending_task.dart';
import '../../domain/entities/server_task.dart';

class AudioManagerState extends Equatable {
  final List<AudioFile> audios;
  final int totalCount;
  final List<ServerTask> uploadingTasks;
  final List<ServerTask> transcribingTasks;
  final List<ServerTask> summarizingTasks;
  final List<PendingTask> untranscribedAudios;
  final List<PendingTask> unsummarizedTranscripts;
  final bool isLoadingAudios;
  final bool isLoadingTasks;
  final bool isLoadingPending;
  final bool isLoadingMore;
  final bool isUploading;
  final double uploadProgress;
  final String? errorMessage;
  final String? successMessage;
  final String searchQuery;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int page;
  final int limit;
  final bool hasMoreAudios;

  const AudioManagerState({
    required this.audios,
    required this.totalCount,
    required this.uploadingTasks,
    required this.transcribingTasks,
    required this.summarizingTasks,
    required this.untranscribedAudios,
    required this.unsummarizedTranscripts,
    required this.isLoadingAudios,
    required this.isLoadingTasks,
    required this.isLoadingPending,
    required this.isLoadingMore,
    required this.isUploading,
    required this.uploadProgress,
    required this.errorMessage,
    required this.successMessage,
    required this.searchQuery,
    required this.fromDate,
    required this.toDate,
    required this.page,
    required this.limit,
    required this.hasMoreAudios,
  });

  factory AudioManagerState.initial() {
    return const AudioManagerState(
      audios: [],
      totalCount: 0,
      uploadingTasks: [],
      transcribingTasks: [],
      summarizingTasks: [],
      untranscribedAudios: [],
      unsummarizedTranscripts: [],
      isLoadingAudios: false,
      isLoadingTasks: false,
      isLoadingPending: false,
      isLoadingMore: false,
      isUploading: false,
      uploadProgress: 0,
      errorMessage: null,
      successMessage: null,
      searchQuery: '',
      fromDate: null,
      toDate: null,
      page: 1,
      limit: 10,
      hasMoreAudios: true,
    );
  }

  AudioManagerState copyWith({
    List<AudioFile>? audios,
    int? totalCount,
    List<ServerTask>? uploadingTasks,
    List<ServerTask>? transcribingTasks,
    List<ServerTask>? summarizingTasks,
    List<PendingTask>? untranscribedAudios,
    List<PendingTask>? unsummarizedTranscripts,
    bool? isLoadingAudios,
    bool? isLoadingTasks,
    bool? isLoadingPending,
    bool? isLoadingMore,
    bool? isUploading,
    double? uploadProgress,
    String? errorMessage,
    String? successMessage,
    String? searchQuery,
    DateTime? fromDate,
    DateTime? toDate,
    int? page,
    int? limit,
    bool? hasMoreAudios,
  }) {
    return AudioManagerState(
      audios: audios ?? this.audios,
      totalCount: totalCount ?? this.totalCount,
      uploadingTasks: uploadingTasks ?? this.uploadingTasks,
      transcribingTasks: transcribingTasks ?? this.transcribingTasks,
      summarizingTasks: summarizingTasks ?? this.summarizingTasks,
      untranscribedAudios: untranscribedAudios ?? this.untranscribedAudios,
      unsummarizedTranscripts:
          unsummarizedTranscripts ?? this.unsummarizedTranscripts,
      isLoadingAudios: isLoadingAudios ?? this.isLoadingAudios,
      isLoadingTasks: isLoadingTasks ?? this.isLoadingTasks,
      isLoadingPending: isLoadingPending ?? this.isLoadingPending,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      errorMessage: errorMessage,
      successMessage: successMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      hasMoreAudios: hasMoreAudios ?? this.hasMoreAudios,
    );
  }

  @override
  List<Object?> get props => [
    audios,
    totalCount,
    uploadingTasks,
    transcribingTasks,
    summarizingTasks,
    untranscribedAudios,
    unsummarizedTranscripts,
    isLoadingAudios,
    isLoadingTasks,
    isLoadingPending,
    isLoadingMore,
    isUploading,
    uploadProgress,
    errorMessage,
    successMessage,
    searchQuery,
    fromDate,
    toDate,
    page,
    limit,
    hasMoreAudios,
  ];
}
