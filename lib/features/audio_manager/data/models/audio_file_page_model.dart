import '../../domain/entities/audio_file_page.dart';
import 'audio_file_model.dart';

class AudioFilePageModel extends AudioFilePage {
  const AudioFilePageModel({
    required super.items,
    required super.total,
    required super.page,
    required super.limit,
  });

  factory AudioFilePageModel.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? [])
        .map(
          (item) => AudioFileModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    return AudioFilePageModel(
      items: items,
      total: json['total'] as int? ?? items.length,
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? items.length,
    );
  }
}
