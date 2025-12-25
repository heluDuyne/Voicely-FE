import '../../domain/entities/audio_filter.dart';

class AudioFilterModel extends AudioFilter {
  const AudioFilterModel({
    super.search,
    super.fromDate,
    super.toDate,
    super.page,
    super.limit,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (search != null && search!.isNotEmpty) {
      params['search'] = search;
    }
    if (fromDate != null) {
      params['from_date'] = fromDate!.toIso8601String();
    }
    if (toDate != null) {
      params['to_date'] = toDate!.toIso8601String();
    }

    return params;
  }
}
