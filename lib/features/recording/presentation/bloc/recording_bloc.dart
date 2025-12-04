import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/import_audio.dart';
import '../../domain/usecases/start_recording.dart';
import '../../domain/usecases/stop_recording.dart';
import '../../domain/repositories/recording_repository.dart';
import 'recording_event.dart';
import 'recording_state.dart';

class RecordingBloc extends Bloc<RecordingEvent, RecordingState> {
  final StartRecording startRecording;
  final StopRecording stopRecording;
  final ImportAudio importAudio;
  final RecordingRepository repository;

  StreamSubscription<Duration>? _durationSubscription;

  RecordingBloc({
    required this.startRecording,
    required this.stopRecording,
    required this.importAudio,
    required this.repository,
  }) : super(const RecordingInitial()) {
    on<StartRecordingRequested>(_onStartRecording);
    on<StopRecordingRequested>(_onStopRecording);
    on<PauseRecordingRequested>(_onPauseRecording);
    on<ResumeRecordingRequested>(_onResumeRecording);
    on<ImportAudioRequested>(_onImportAudio);
    on<DurationUpdated>(_onDurationUpdated);
  }

  Future<void> _onStartRecording(
    StartRecordingRequested event,
    Emitter<RecordingState> emit,
  ) async {
    final result = await startRecording();

    result.fold(
      (failure) => emit(RecordingError(message: failure.message)),
      (_) {
        emit(const RecordingInProgress());
        _durationSubscription?.cancel();
        _durationSubscription = repository.durationStream.listen((duration) {
          add(DurationUpdated(duration));
        });
      },
    );
  }

  Future<void> _onStopRecording(
    StopRecordingRequested event,
    Emitter<RecordingState> emit,
  ) async {
    _durationSubscription?.cancel();

    final result = await stopRecording();

    result.fold(
      (failure) => emit(RecordingError(message: failure.message)),
      (recording) => emit(RecordingCompleted(recording: recording)),
    );
  }

  Future<void> _onPauseRecording(
    PauseRecordingRequested event,
    Emitter<RecordingState> emit,
  ) async {
    _durationSubscription?.cancel();

    final result = await repository.pauseRecording();

    result.fold(
      (failure) => emit(RecordingError(message: failure.message)),
      (_) {
        if (state is RecordingInProgress) {
          emit(RecordingPaused(
            duration: (state as RecordingInProgress).duration,
          ));
        }
      },
    );
  }

  Future<void> _onResumeRecording(
    ResumeRecordingRequested event,
    Emitter<RecordingState> emit,
  ) async {
    final currentDuration =
        state is RecordingPaused ? (state as RecordingPaused).duration : Duration.zero;

    final result = await repository.resumeRecording();

    result.fold(
      (failure) => emit(RecordingError(message: failure.message)),
      (_) {
        emit(RecordingInProgress(duration: currentDuration));
        _durationSubscription?.cancel();
        _durationSubscription = repository.durationStream.listen((duration) {
          add(DurationUpdated(duration));
        });
      },
    );
  }

  Future<void> _onImportAudio(
    ImportAudioRequested event,
    Emitter<RecordingState> emit,
  ) async {
    final result = await importAudio();

    result.fold(
      (failure) => emit(RecordingError(message: failure.message)),
      (file) => emit(AudioImported(audioFile: file)),
    );
  }

  void _onDurationUpdated(
    DurationUpdated event,
    Emitter<RecordingState> emit,
  ) {
    if (state is RecordingInProgress) {
      emit(RecordingInProgress(duration: event.duration));
    }
  }

  @override
  Future<void> close() {
    _durationSubscription?.cancel();
    return super.close();
  }
}





