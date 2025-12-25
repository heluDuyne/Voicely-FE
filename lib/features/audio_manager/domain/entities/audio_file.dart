import 'package:equatable/equatable.dart';

class AudioFile extends Equatable {
  final int id;
  final int? userId;
  final String filename;
  final String? originalFilename;
  final String? filePath;
  final int? fileSize;
  final double? duration;
  final String? format;
  final DateTime? uploadDate;
  final String? status;
  final String? transcription;
  final double? confidenceScore;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? transcriptionId;
  final bool? hasSummary;

  const AudioFile({
    required this.id,
    this.userId,
    required this.filename,
    this.originalFilename,
    this.filePath,
    this.fileSize,
    this.duration,
    this.format,
    this.uploadDate,
    this.status,
    this.transcription,
    this.confidenceScore,
    this.createdAt,
    this.updatedAt,
    this.transcriptionId,
    this.hasSummary,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    filename,
    originalFilename,
    filePath,
    fileSize,
    duration,
    format,
    uploadDate,
    status,
    transcription,
    confidenceScore,
    createdAt,
    updatedAt,
    transcriptionId,
    hasSummary,
  ];
}
