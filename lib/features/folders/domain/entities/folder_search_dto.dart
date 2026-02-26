import 'package:equatable/equatable.dart';

class FolderSearchDto extends Equatable {
  final int page;
  final int pageSize;
  final String order;
  final String? search;
  final bool? isDropdown;
  final bool? isDefault;
  final String? color;
  final bool? hasAudio;
  final int? minAudioCount;
  final int? maxAudioCount;
  final DateTime? fromDate;
  final DateTime? toDate;

  const FolderSearchDto({
    this.page = 1,
    this.pageSize = 10,
    this.order = 'DESC',
    this.search,
    this.isDropdown,
    this.isDefault,
    this.color,
    this.hasAudio,
    this.minAudioCount,
    this.maxAudioCount,
    this.fromDate,
    this.toDate,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      'order': order.isEmpty ? 'DESC' : order,
    };
    if (search != null && search!.isNotEmpty) {
      json['search'] = search;
    }
    if (isDropdown != null) {
      json['is_dropdown'] = isDropdown;
    }
    if (isDefault != null) {
      json['is_default'] = isDefault;
    }
    if (color != null) {
      json['color'] = color;
    }
    if (hasAudio != null) {
      json['has_audio'] = hasAudio;
    }
    if (minAudioCount != null) {
      json['min_audio_count'] = minAudioCount;
    }
    if (maxAudioCount != null) {
      json['max_audio_count'] = maxAudioCount;
    }
    if (fromDate != null) {
      json['from_date'] = fromDate!.toIso8601String();
    }
    if (toDate != null) {
      json['to_date'] = toDate!.toIso8601String();
    }
    return json;
  }

  @override
  List<Object?> get props => [
    page,
    pageSize,
    order,
    search,
    isDropdown,
    isDefault,
    color,
    hasAudio,
    minAudioCount,
    maxAudioCount,
    fromDate,
    toDate,
  ];
}
