import 'package:equatable/equatable.dart';

class AudioFile extends Equatable {
  final int id;
  final String filename;
  final String? filePath;
  final int? fileSize;
  final double? duration;
  final DateTime? uploadDate;
  final String? status;
  final int? transcriptionId;
  final bool? hasSummary;

  const AudioFile({
    required this.id,
    required this.filename,
    this.filePath,
    this.fileSize,
    this.duration,
    this.uploadDate,
    this.status,
    this.transcriptionId,
    this.hasSummary,
  });

  @override
  List<Object?> get props => [
    id,
    filename,
    filePath,
    fileSize,
    duration,
    uploadDate,
    status,
    transcriptionId,
    hasSummary,
  ];
}
