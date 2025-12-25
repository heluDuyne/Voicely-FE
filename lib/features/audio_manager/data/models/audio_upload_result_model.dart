import '../../domain/entities/audio_upload_result.dart';

class AudioUploadResultModel extends AudioUploadResult {
  const AudioUploadResultModel({
    required super.audioId,
    required super.filename,
    required super.filePath,
    required super.taskId,
  });

  factory AudioUploadResultModel.fromJson(Map<String, dynamic> json) {
    return AudioUploadResultModel(
      audioId: json['audio_id'] as int,
      filename: json['filename'] as String,
      filePath: json['file_path'] as String,
      taskId: json['task_id'] as String,
    );
  }
}
