import 'dart:async';
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import '../../../../core/errors/failures.dart';
import '../../../../injection_container/injection_container.dart';
import '../../../folders/domain/entities/folder_page.dart';
import '../../../folders/domain/entities/folder_search_dto.dart';
import '../../../folders/domain/entities/move_audio_to_folder.dart'
    as folder_dto;
import '../../../folders/domain/repositories/folder_repository.dart';
import '../../../folders/presentation/widgets/folder_ui_helpers.dart';
import '../../domain/entities/audio_file.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/audio_manager_repository.dart';
import 'summary_tab.dart';
import 'transcription_tab.dart';

enum AudioMenuAction { rename, addToFolder, delete, download }

class AudioDetailScreen extends StatefulWidget {
  final AudioFile audioFile;

  const AudioDetailScreen({super.key, required this.audioFile});

  @override
  State<AudioDetailScreen> createState() => _AudioDetailScreenState();
}

class _AudioDetailScreenState extends State<AudioDetailScreen>
    with SingleTickerProviderStateMixin {
  final AudioManagerRepository _repository = sl<AudioManagerRepository>();
  final FolderRepository _folderRepository = sl<FolderRepository>();
  late final TabController _tabController;

  AudioFile? _audioFile;
  Note? _summaryNote;
  Timer? _taskPollingTimer;
  List<Task> _activeTasks = [];
  bool _hadActiveTasks = false;
  bool _isWaitingForTranscription = false;
  bool _isWaitingForSummarization = false;
  bool _isLoading = true;
  String? _errorMessage;
  bool _transcriptDirty = false;
  bool _summaryDirty = false;
  String? _currentFolderName;

  bool get _hasTranscript {
    final text = _audioFile?.transcription;
    return text != null && text.trim().isNotEmpty;
  }

  bool get _hasSummary {
    if (_summaryNote != null) {
      return true;
    }
    final summaryText = _audioFile?.summary;
    return summaryText != null && summaryText.trim().isNotEmpty;
  }

  bool get _isTranscribing {
    return _activeTasks.any((task) => task.isTranscribing) ||
        _isWaitingForTranscription;
  }

  bool get _isSummarizing {
    return _activeTasks.any((task) => task.isSummarizing) ||
        _isWaitingForSummarization;
  }

  bool get _hasUnsavedChanges => _transcriptDirty || _summaryDirty;

  @override
  void initState() {
    super.initState();
    _audioFile = widget.audioFile;
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChanged);
    _loadAudioDetails();
  }

  @override
  void dispose() {
    _stopTaskPolling();
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
          const SnackBar(content: Text('Please transcribe the audio first')),
        );
      });
    }
  }

  Future<void> _loadAudioDetails({bool startPolling = true}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _repository.getAudioFileById(widget.audioFile.id);
    if (!mounted) {
      return;
    }

    await result.fold(
      (failure) async {
        setState(() {
          _isLoading = false;
          _errorMessage = failure.message;
        });
      },
      (audioFile) async {
        setState(() {
          _audioFile = audioFile;
          _isLoading = false;
        });
        await _loadCurrentFolderName(audioFile.folderId);
        await _loadSummary();
        if (startPolling) {
          _startTaskPolling();
        }
      },
    );
  }

  Future<void> _loadSummary() async {
    final audioFile = _audioFile;
    if (audioFile == null) {
      return;
    }

    final shouldLoad =
        audioFile.isSummarize == true ||
        audioFile.hasSummary == true ||
        audioFile.summary != null;
    if (!shouldLoad) {
      if (mounted) {
        setState(() {
          _summaryNote = null;
        });
      }
      return;
    }

    final result = await _repository.getSummaryNote(audioFile.id);
    if (!mounted) {
      return;
    }

    result.fold((_) {}, (note) {
      setState(() {
        _summaryNote = note;
      });
    });
  }

  Future<void> _loadCurrentFolderName(int? folderId) async {
    if (folderId == null) {
      if (mounted) {
        setState(() {
          _currentFolderName = null;
        });
      }
      return;
    }

    final result = await _folderRepository.getFolderDetails(folderId);
    if (!mounted) {
      return;
    }

    result.fold((_) {}, (folder) {
      setState(() {
        _currentFolderName = folder.name;
      });
    });
  }

  void _startTaskPolling() {
    _stopTaskPolling();
    _pollTasks();
    _taskPollingTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _pollTasks(),
    );
  }

  Future<void> _pollTasks() async {
    final audioFile = _audioFile;
    if (audioFile == null) {
      return;
    }

    final result = await _repository.getActiveTasks(audioFile.id);
    if (!mounted) {
      return;
    }

    result.fold((_) {}, (tasks) {
      final hasActiveTasks = tasks.any((task) => task.isActive);
      final hasTranscribeActive = tasks.any((task) => task.isTranscribing);
      final hasSummarizeActive = tasks.any((task) => task.isSummarizing);

      setState(() {
        _activeTasks = tasks;
        if (hasTranscribeActive) {
          _isWaitingForTranscription = false;
        }
        if (hasSummarizeActive) {
          _isWaitingForSummarization = false;
        }
      });

      if (hasActiveTasks) {
        _hadActiveTasks = true;
        return;
      }

      if (_isWaitingForTranscription || _isWaitingForSummarization) {
        return;
      }

      _stopTaskPolling();
      if (_hadActiveTasks) {
        _hadActiveTasks = false;
        _loadAudioDetails(startPolling: false);
      }
    });
  }

  void _stopTaskPolling() {
    _taskPollingTimer?.cancel();
    _taskPollingTimer = null;
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
      builder:
          (context) => AlertDialog(
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
      case AudioMenuAction.addToFolder:
        _showAddToFolderDialog();
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
    final audioFile = _audioFile ?? widget.audioFile;
    final currentName = audioFile.originalFilename ?? audioFile.filename;
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
                  _handleRename(newName);
                },
                child: const Text('Rename'),
              ),
            ],
          ),
    );
  }

  Future<void> _handleRename(String newName) async {
    final audioFile = _audioFile;
    if (audioFile == null) {
      return;
    }

    final result = await _repository.renameAudio(audioFile.id, newName);
    if (!mounted) {
      return;
    }

    result.fold(
      (failure) => _showSnackBar('Failed to rename audio: ${failure.message}'),
      (updatedAudio) {
        setState(() {
          _audioFile = updatedAudio;
        });
        _showSnackBar('Audio renamed successfully');
      },
    );
  }

  Future<void> _showAddToFolderDialog() async {
    final audioFile = _audioFile;
    if (audioFile == null) {
      return;
    }

    final selection = await showModalBottomSheet<_FolderSelectionResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF101822),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => _FolderSelectionSheet(
            repository: _folderRepository,
            currentFolderId: audioFile.folderId,
          ),
    );

    if (!mounted || selection == null) {
      return;
    }

    await _moveAudioToFolder(selection);
  }

  Future<void> _moveAudioToFolder(_FolderSelectionResult selection) async {
    final audioFile = _audioFile;
    if (audioFile == null) {
      return;
    }

    final result = await _folderRepository.moveAudioToFolder(
      folder_dto.MoveAudioToFolder(
        audioId: audioFile.id,
        folderId: selection.folderId,
      ),
    );

    if (!mounted) {
      return;
    }

    result.fold(
      (failure) =>
          _showSnackBar('Failed to move audio: ${failure.message}'),
      (updatedAudio) {
        setState(() {
          _audioFile = updatedAudio;
          if (selection.folderId == null) {
            _currentFolderName = null;
          } else if (selection.folderName != null) {
            _currentFolderName = selection.folderName;
          }
        });
        if (selection.folderId == null) {
          _showSnackBar('Audio removed from folder');
        } else if (selection.folderName != null) {
          _showSnackBar('Moved to ${selection.folderName}');
        } else {
          _showSnackBar('Audio moved successfully');
        }
      },
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
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
                  _handleDelete();
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  Future<void> _handleDelete() async {
    final audioFile = _audioFile;
    if (audioFile == null) {
      return;
    }

    final result = await _repository.deleteAudio(audioFile.id);
    if (!mounted) {
      return;
    }

    result.fold(
      (failure) => _showSnackBar('Failed to delete audio: ${failure.message}'),
      (_) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context);
        messenger.showSnackBar(
          const SnackBar(content: Text('Audio deleted successfully')),
        );
      },
    );
  }

  Future<void> _handleDownload() async {
    final audioFile = _audioFile;
    if (audioFile == null) {
      return;
    }

    _showSnackBar('Downloading audio...');

    final filename =
        audioFile.originalFilename ?? audioFile.filename ?? 'audio.mp3';
    final result = await _repository.downloadAudio(audioFile.id, filename);
    if (!mounted) {
      return;
    }

    result.fold(
      (failure) =>
          _showSnackBar('Failed to download audio: ${failure.message}'),
      (_) => _showSnackBar('Audio downloaded successfully'),
    );
  }

  Future<String?> _handleSaveTranscription(String transcription) async {
    final audioFile = _audioFile;
    if (audioFile == null) {
      return 'Audio details are missing';
    }

    final result = await _repository.updateTranscription(
      audioFile.id,
      transcription,
    );
    if (!mounted) {
      return 'Audio details are no longer available';
    }

    String? errorMessage;
    result.fold((failure) => errorMessage = failure.message, (updatedAudio) {
      setState(() {
        _audioFile = updatedAudio;
      });
    });

    return errorMessage;
  }

  Future<String?> _handleStartTranscription() async {
    final audioFile = _audioFile;
    if (audioFile == null) {
      return 'Audio details are missing';
    }

    final result = await _repository.startTranscription(audioFile.id);
    if (!mounted) {
      return 'Audio details are no longer available';
    }

    String? errorMessage;
    result.fold((failure) => errorMessage = failure.message, (_) {
      _isWaitingForTranscription = true;
      _startTaskPolling();
    });

    return errorMessage;
  }

  Future<String?> _handleStartSummarization() async {
    final audioFile = _audioFile;
    if (audioFile == null) {
      return 'Audio details are missing';
    }

    final result = await _repository.startSummarization(audioFile.id);
    if (!mounted) {
      return 'Audio details are no longer available';
    }

    String? errorMessage;
    result.fold((failure) => errorMessage = failure.message, (_) {
      _isWaitingForSummarization = true;
      _startTaskPolling();
    });

    return errorMessage;
  }

  Future<String?> _handleSaveSummary(String summary) async {
    final summaryNote = _summaryNote;
    if (summaryNote == null) {
      return 'Summary note not available';
    }

    final result = await _repository.updateNoteSummary(summaryNote.id, summary);
    if (!mounted) {
      return 'Summary note is no longer available';
    }

    String? errorMessage;
    result.fold((failure) => errorMessage = failure.message, (updatedNote) {
      setState(() {
        _summaryNote = updatedNote;
      });
    });

    return errorMessage;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAudioDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioFile = _audioFile ?? widget.audioFile;
    final title =
        audioFile.originalFilename ?? audioFile.filename ?? 'Audio Details';

    return WillPopScope(
      onWillPop: _handleBackPressed,
      child: Scaffold(
        backgroundColor: const Color(0xFF101822),
        appBar: AppBar(
          backgroundColor: const Color(0xFF101822),
          elevation: 0,
          title: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white),
          ),
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
              itemBuilder:
                  (context) => [
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
                      value: AudioMenuAction.addToFolder,
                      child: Row(
                        children: [
                          Icon(Icons.folder_open),
                          SizedBox(width: 12),
                          Text('Add to Folder'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: AudioMenuAction.delete,
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 12),
                          Text(
                            'Delete Audio',
                            style: TextStyle(color: Colors.red),
                          ),
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
        body:
            _errorMessage != null && !_isLoading
                ? _buildErrorState(_errorMessage!)
                : Column(
                  children: [
                    if (_isLoading)
                      const LinearProgressIndicator(
                        backgroundColor: Color(0xFF101822),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF3B82F6),
                        ),
                      ),
                    if (_currentFolderName != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        color: const Color(0xFF141C26),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.folder_open,
                              color: Color(0xFF3B82F6),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Folder: $_currentFolderName',
                                style: const TextStyle(color: Colors.white70),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        physics:
                            _hasTranscript
                                ? null
                                : const NeverScrollableScrollPhysics(),
                        children: [
                          TranscriptionTab(
                            audioFile: audioFile,
                            hasTranscript: _hasTranscript,
                            isTranscribing: _isTranscribing,
                            onChanged:
                                () => setState(() => _transcriptDirty = true),
                            onSaved:
                                () => setState(() => _transcriptDirty = false),
                            onSaveTranscription: _handleSaveTranscription,
                            onStartTranscription: _handleStartTranscription,
                          ),
                          SummaryTab(
                            noteId: _summaryNote?.id,
                            summaryHtml:
                                _summaryNote?.summary ?? audioFile.summary,
                            hasSummary: _hasSummary,
                            enabled: _hasTranscript,
                            isSummarizing: _isSummarizing,
                            onChanged:
                                () => setState(() => _summaryDirty = true),
                            onSaved:
                                () => setState(() => _summaryDirty = false),
                            onStartSummarization: _handleStartSummarization,
                            onSaveSummary: _handleSaveSummary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}

class _FolderSelectionResult {
  final int? folderId;
  final String? folderName;

  const _FolderSelectionResult({this.folderId, this.folderName});
}

class _FolderSelectionSheet extends StatefulWidget {
  final FolderRepository repository;
  final int? currentFolderId;

  const _FolderSelectionSheet({
    required this.repository,
    required this.currentFolderId,
  });

  @override
  State<_FolderSelectionSheet> createState() => _FolderSelectionSheetState();
}

class _FolderSelectionSheetState extends State<_FolderSelectionSheet> {
  late final TextEditingController _searchController;
  late final Future<dartz.Either<Failure, FolderPage>> _future;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _future = widget.repository.searchFolders(
      const FolderSearchDto(
        page: 1,
        pageSize: 100,
        order: 'DESC',
        isDropdown: true,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFF101822),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Move to Folder',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF282E39),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search folders...',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        prefixIcon:
                            Icon(Icons.search, color: Colors.grey[600]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: FutureBuilder<dartz.Either<Failure, FolderPage>>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final data = snapshot.data;
                      if (data == null) {
                        return const Center(
                          child: Text(
                            'Failed to load folders',
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }

                      return data.fold(
                        (failure) => Center(
                          child: Text(
                            failure.message,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                        (page) {
                          final query = _searchController.text.trim().toLowerCase();
                          final folders = query.isEmpty
                              ? page.items
                              : page.items.where((folder) {
                                  final name = folder.name.toLowerCase();
                                  final description =
                                      folder.description?.toLowerCase() ?? '';
                                  return name.contains(query) ||
                                      description.contains(query);
                                }).toList();

                          return ListView.builder(
                            controller: scrollController,
                            itemCount: folders.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                final isSelected =
                                    widget.currentFolderId == null;
                                return _buildFolderOption(
                                  context,
                                  title: 'No Folder',
                                  icon: Icons.folder_off_outlined,
                                  color: Colors.grey,
                                  isSelected: isSelected,
                                  onTap: () {
                                    Navigator.pop(
                                      context,
                                      const _FolderSelectionResult(),
                                    );
                                  },
                                );
                              }
                              final folder = folders[index - 1];
                              final color = parseHexColor(folder.color);
                              final icon = folderIconFromName(folder.icon);
                              final isSelected =
                                  widget.currentFolderId == folder.id;
                              return _buildFolderOption(
                                context,
                                title: folder.name,
                                subtitle: folder.description,
                                icon: icon,
                                color: color,
                                isSelected: isSelected,
                                onTap: () {
                                  Navigator.pop(
                                    context,
                                    _FolderSelectionResult(
                                      folderId: folder.id,
                                      folderName: folder.name,
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFolderOption(
    BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.withOpacity(0.18),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle:
          subtitle == null || subtitle.isEmpty
              ? null
              : Text(
                subtitle,
                style: TextStyle(color: Colors.grey[500]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
      trailing:
          isSelected
              ? const Icon(Icons.check, color: Color(0xFF3B82F6))
              : null,
    );
  }
}
