import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class AudioManagerEvent extends Equatable {
  const AudioManagerEvent();

  @override
  List<Object?> get props => [];
}

class LoadUploadedAudios extends AudioManagerEvent {
  final String? searchQuery;
  final DateTime? fromDate;
  final DateTime? toDate;

  const LoadUploadedAudios({
    this.searchQuery,
    this.fromDate,
    this.toDate,
  });

  @override
  List<Object?> get props => [searchQuery, fromDate, toDate];
}

class UploadAudioFile extends AudioManagerEvent {
  final File audioFile;

  const UploadAudioFile(this.audioFile);

  @override
  List<Object?> get props => [audioFile];
}

class LoadServerTasks extends AudioManagerEvent {
  const LoadServerTasks();
}

class LoadPendingTasks extends AudioManagerEvent {
  const LoadPendingTasks();
}

class SearchAudios extends AudioManagerEvent {
  final String query;

  const SearchAudios(this.query);

  @override
  List<Object?> get props => [query];
}

class ApplyFilter extends AudioManagerEvent {
  final DateTime? fromDate;
  final DateTime? toDate;

  const ApplyFilter({this.fromDate, this.toDate});

  @override
  List<Object?> get props => [fromDate, toDate];
}

class RefreshAllData extends AudioManagerEvent {
  const RefreshAllData();
}

class LoadMoreAudios extends AudioManagerEvent {
  const LoadMoreAudios();
}

class ClearMessage extends AudioManagerEvent {
  const ClearMessage();
}
