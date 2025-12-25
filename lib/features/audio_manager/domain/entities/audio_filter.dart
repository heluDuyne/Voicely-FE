import 'package:equatable/equatable.dart';

class AudioFilter extends Equatable {
  final String? search;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int page;
  final int limit;

  const AudioFilter({
    this.search,
    this.fromDate,
    this.toDate,
    this.page = 1,
    this.limit = 20,
  });

  AudioFilter copyWith({
    String? search,
    DateTime? fromDate,
    DateTime? toDate,
    int? page,
    int? limit,
  }) {
    return AudioFilter(
      search: search ?? this.search,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  @override
  List<Object?> get props => [search, fromDate, toDate, page, limit];
}
