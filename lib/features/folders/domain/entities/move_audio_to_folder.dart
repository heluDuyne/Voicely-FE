import 'package:equatable/equatable.dart';

class MoveAudioToFolder extends Equatable {
  final int audioId;
  final int? folderId;

  const MoveAudioToFolder({
    required this.audioId,
    required this.folderId,
  });

  Map<String, dynamic> toJson() {
    return {
      'audio_id': audioId,
      'folder_id': folderId,
    };
  }

  @override
  List<Object?> get props => [audioId, folderId];
}
