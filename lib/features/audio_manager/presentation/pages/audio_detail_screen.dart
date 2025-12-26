import 'package:flutter/material.dart';
import '../../domain/entities/audio_file.dart';
import 'summary_tab.dart';
import 'transcription_tab.dart';

enum AudioMenuAction { rename, delete, download }

class AudioDetailScreen extends StatefulWidget {
  final AudioFile audioFile;

  const AudioDetailScreen({super.key, required this.audioFile});

  @override
  State<AudioDetailScreen> createState() => _AudioDetailScreenState();
}

class _AudioDetailScreenState extends State<AudioDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _transcriptDirty = false;
  bool _summaryDirty = false;

  bool get _hasTranscript {
    final text = widget.audioFile.transcription;
    return text != null && text.trim().isNotEmpty;
  }

  bool get _hasSummary {
    final summaryText = widget.audioFile.summary;
    if (summaryText != null && summaryText.trim().isNotEmpty) {
      return true;
    }
    final summarized = widget.audioFile.isSummarize ?? widget.audioFile.hasSummary;
    return summarized == true;
  }

  bool get _hasUnsavedChanges => _transcriptDirty || _summaryDirty;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChanged() {
    if (_tabController.index == 1 && !_hasTranscript) {
      _tabController.index = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please transcribe the audio first'),
          ),
        );
      });
    }
  }

  Future<bool> _handleBackPressed() async {
    if (!_hasUnsavedChanges) {
      return true;
    }
    final shouldExit = await _showUnsavedChangesDialog();
    return shouldExit ?? false;
  }

  Future<bool?> _showUnsavedChangesDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
          'You have unsaved changes. Do you want to save before leaving?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(AudioMenuAction action) {
    switch (action) {
      case AudioMenuAction.rename:
        _showRenameDialog();
        break;
      case AudioMenuAction.delete:
        _showDeleteConfirmation();
        break;
      case AudioMenuAction.download:
        _handleDownload();
        break;
    }
  }

  void _showRenameDialog() {
    final currentName =
        widget.audioFile.originalFilename ?? widget.audioFile.filename;
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Audio'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New filename',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isEmpty) {
                return;
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(content: Text('Renamed to: $newName')),
              );
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Audio'),
        content: const Text(
          'Are you sure you want to delete this audio? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogContext);
              if (!mounted) {
                return;
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Audio deleted successfully')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _handleDownload() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download started...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title =
        widget.audioFile.originalFilename ??
        widget.audioFile.filename ??
        'Audio Details';

    return WillPopScope(
      onWillPop: _handleBackPressed,
      child: Scaffold(
        backgroundColor: const Color(0xFF101822),
        appBar: AppBar(
          backgroundColor: const Color(0xFF101822),
          elevation: 0,
          title: Text(title, overflow: TextOverflow.ellipsis),
          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () async {
              final shouldPop = await _handleBackPressed();
              if (shouldPop && mounted) {
                Navigator.pop(context);
              }
            },
          ),
          actions: [
            PopupMenuButton<AudioMenuAction>(
              icon: const Icon(Icons.more_vert),
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: AudioMenuAction.rename,
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 12),
                      Text('Rename Audio'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: AudioMenuAction.delete,
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Delete Audio', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: AudioMenuAction.download,
                  child: Row(
                    children: [
                      Icon(Icons.download),
                      SizedBox(width: 12),
                      Text('Download Audio'),
                    ],
                  ),
                ),
              ],
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF3B82F6),
            tabs: [
              const Tab(text: 'Transcription'),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Summary'),
                    if (!_hasTranscript) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.lock, size: 16),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          physics:
              _hasTranscript ? null : const NeverScrollableScrollPhysics(),
          children: [
            TranscriptionTab(
              audioFile: widget.audioFile,
              hasTranscript: _hasTranscript,
              onChanged: () => setState(() => _transcriptDirty = true),
              onSaved: () => setState(() => _transcriptDirty = false),
            ),
            SummaryTab(
              audioFile: widget.audioFile,
              hasSummary: _hasSummary,
              enabled: _hasTranscript,
              onChanged: () => setState(() => _summaryDirty = true),
              onSaved: () => setState(() => _summaryDirty = false),
            ),
          ],
        ),
      ),
    );
  }
}
