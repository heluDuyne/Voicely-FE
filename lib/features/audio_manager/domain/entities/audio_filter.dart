import 'package:equatable/equatable.dart';

class AudioFilter extends Equatable {
  final String? search;
  final DateTime? fromDate;
  final DateTime? toDate;
  final bool? hasTranscript;
  final String order;
  final int page;
  final int limit;
  final String? status;

  const AudioFilter({
    this.search,
    this.fromDate,
    this.toDate,
    this.hasTranscript,
    this.order = 'DESC',
    this.page = 1,
    this.limit = 10,
    this.status,
  });

  AudioFilter copyWith({
    String? search,
    DateTime? fromDate,
    DateTime? toDate,
    bool? hasTranscript,
    String? order,
    int? page,
    int? limit,
    String? status,
  }) {
    return AudioFilter(
      search: search ?? this.search,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      hasTranscript: hasTranscript ?? this.hasTranscript,
      order: order ?? this.order,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
    search,
    fromDate,
    toDate,
    hasTranscript,
    order,
    page,
    limit,
    status,
  ];
}
