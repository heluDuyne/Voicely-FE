import 'package:equatable/equatable.dart';
import 'audio_file.dart';

class AudioFilePage extends Equatable {
  final List<AudioFile> items;
  final int total;
  final int page;
  final int limit;

  const AudioFilePage({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  @override
  List<Object?> get props => [items, total, page, limit];
}
