import '../../domain/entities/audio_file.dart';

class AudioFileModel extends AudioFile {
  const AudioFileModel({
    required super.id,
    required super.filename,
    super.filePath,
    super.fileSize,
    super.duration,
    super.uploadDate,
    super.status,
    super.transcriptionId,
    super.hasSummary,
  });

  factory AudioFileModel.fromJson(Map<String, dynamic> json) {
    return AudioFileModel(
      id: json['id'] as int,
      filename: json['filename'] as String,
      filePath: json['file_path'] as String?,
      fileSize: json['file_size'] as int?,
      duration: (json['duration'] as num?)?.toDouble(),
      uploadDate:
          json['upload_date'] != null
              ? DateTime.parse(json['upload_date'] as String)
              : null,
      status: json['status'] as String?,
      transcriptionId: json['transcription_id'] as int?,
      hasSummary: json['has_summary'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'file_path': filePath,
      'file_size': fileSize,
      'duration': duration,
      'upload_date': uploadDate?.toIso8601String(),
      'status': status,
      'transcription_id': transcriptionId,
      'has_summary': hasSummary,
    };
  }
}
