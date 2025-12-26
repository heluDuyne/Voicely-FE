import 'package:flutter/material.dart';
import '../../domain/entities/audio_file.dart';
import 'common_task_item.dart';

class AudioFileListItem extends StatelessWidget {
  final AudioFile audioFile;
  final VoidCallback? onTap;
  final IconData icon;
  final Color iconColor;
  final bool showPendingStatus;
  final bool showStatusIcon;

  const AudioFileListItem({
    super.key,
    required this.audioFile,
    this.onTap,
    this.icon = Icons.audiotrack,
    this.iconColor = const Color(0xFF3B82F6),
    this.showPendingStatus = false,
    this.showStatusIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return CommonTaskItem(
      icon: icon,
      iconColor: iconColor,
      title: audioFile.originalFilename ?? audioFile.filename,
      description: _buildDescription(),
      onTap: onTap ?? () {},
      showChevron: !showStatusIcon,
      trailing: showStatusIcon ? _buildTrailing() : null,
    );
  }

  String _buildDescription() {
    final parts = <String>[];
    if (audioFile.duration != null) {
      parts.add('Duration ${_formatDuration(audioFile.duration!)}');
    }
    if (audioFile.status != null && audioFile.status!.isNotEmpty) {
      parts.add('Status: ${_formatStatus(audioFile.status!)}');
    }
    final created = audioFile.createdAt ?? audioFile.uploadDate;
    if (created != null) {
      parts.add('Uploaded ${_formatDate(created)}');
    }
    if (audioFile.fileSize != null) {
      parts.add(_formatBytes(audioFile.fileSize!));
    }
    if (showPendingStatus && _needsSummary()) {
      parts.add('Not summarized');
    }
    return parts.isEmpty ? 'Tap to view' : parts.join(' • ');
  }

  Widget _buildTrailing() {
    if (showPendingStatus) {
      if (_needsTranscription()) {
        return const Icon(Icons.description_outlined, color: Colors.orange);
      }
      if (_needsSummary()) {
        return const Icon(Icons.summarize, color: Colors.blue);
      }
    }

    final status = audioFile.status?.toLowerCase().trim();
    switch (status) {
      case 'completed':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'processing':
      case 'queued':
      case 'pending':
        return const Icon(Icons.sync, color: Colors.orange);
      case 'failed':
        return const Icon(Icons.error, color: Colors.redAccent);
      default:
        return Icon(Icons.chevron_right, color: Colors.grey[600]);
    }
  }

  bool _needsTranscription() {
    return audioFile.transcription == null || audioFile.transcription!.isEmpty;
  }

  bool _needsSummary() {
    final summarized = audioFile.isSummarize ?? audioFile.hasSummary;
    return summarized == false && !_needsTranscription();
  }

  String _formatDuration(double seconds) {
    final duration = Duration(seconds: seconds.round());
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds.remainder(60);
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _formatBytes(int bytes) {
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  String _formatStatus(String status) {
    final normalized = status.trim().toLowerCase();
    if (normalized.isEmpty) {
      return 'Unknown';
    }
    final words =
        normalized.replaceAll(RegExp(r'[_-]+'), ' ').split(' ');
    return words
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
