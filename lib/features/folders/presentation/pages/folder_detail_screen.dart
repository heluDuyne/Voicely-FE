import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container/injection_container.dart';
import '../../../audio_manager/domain/entities/audio_file.dart';
import '../../../audio_manager/presentation/pages/audio_detail_screen.dart';
import '../../../audio_manager/presentation/widgets/audio_file_list_item.dart';
import '../../domain/entities/folder.dart';
import '../../domain/entities/folder_update.dart';
import '../bloc/folder_bloc.dart';
import '../bloc/folder_event.dart';
import '../bloc/folder_state.dart';
import '../widgets/folder_ui_helpers.dart';

class FolderDetailScreen extends StatefulWidget {
  final int folderId;

  const FolderDetailScreen({super.key, required this.folderId});

  @override
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  late final FolderBloc _folderBloc;

  @override
  void initState() {
    super.initState();
    _folderBloc = sl<FolderBloc>();
    _folderBloc.add(LoadFolderDetails(widget.folderId));
  }

  @override
  void dispose() {
    _folderBloc.close();
    super.dispose();
  }

  void _openAudio(AudioFile audioFile) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => AudioDetailScreen(audioFile: audioFile)));
  }

  Future<void> _refreshAudioList() async {
    _folderBloc.add(LoadAudioInFolder(folderId: widget.folderId));
    await Future.delayed(const Duration(milliseconds: 300));
  }

  void _showRenameDialog(Folder folder) {
    final controller = TextEditingController(text: folder.name);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Rename Folder'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Folder name',
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
                  final name = controller.text.trim();
                  if (name.isEmpty) {
                    return;
                  }
                  Navigator.pop(context);
                  _folderBloc.add(
                    UpdateFolder(folderId: folder.id, update: FolderUpdate(name: name)),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showColorPickerDialog(Folder folder) {
    String? selected = folder.color ?? kFolderColorOptions.first;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Change Color'),
            content: StatefulBuilder(
              builder: (context, setState) {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children:
                      kFolderColorOptions.map((hex) {
                        final color = parseHexColor(hex);
                        final isSelected = selected == hex;
                        return GestureDetector(
                          onTap: () => setState(() => selected = hex),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 2)
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _folderBloc.add(
                    UpdateFolder(
                      folderId: folder.id,
                      update: FolderUpdate(color: selected),
                    ),
                  );
                },
                child: const Text('Apply'),
              ),
            ],
          ),
    );
  }

  void _showDeleteConfirmation(Folder folder) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Folder'),
            content: const Text(
              'Deleting this folder will unassign its audio files.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _folderBloc.add(DeleteFolder(folder.id));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _folderBloc,
      child: BlocConsumer<FolderBloc, FolderState>(
        listener: (context, state) {
          final message = state.errorMessage ?? state.successMessage;
          if (message == null) {
            return;
          }
          if (state.successMessage == 'Folder deleted') {
            Navigator.pop(context);
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
          context.read<FolderBloc>().add(const ClearFolderMessage());
        },
        builder: (context, state) {
          final folder = state.selectedFolder;
          return Scaffold(
            backgroundColor: const Color(0xFF101822),
            appBar: AppBar(
              backgroundColor: const Color(0xFF101822),
              elevation: 0,
              title: Text(
                folder?.name ?? 'Folder',
                style: const TextStyle(color: Colors.white),
              ),
              leading: IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                if (folder != null)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'rename') {
                        _showRenameDialog(folder);
                      } else if (value == 'color') {
                        _showColorPickerDialog(folder);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(folder);
                      }
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'rename',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 12),
                                Text('Rename'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'color',
                            child: Row(
                              children: [
                                Icon(Icons.palette_outlined),
                                SizedBox(width: 12),
                                Text('Change Color'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 12),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                  ),
              ],
            ),
            body:
                state.isLoadingDetails && folder == null
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                      onRefresh: _refreshAudioList,
                      child: _buildBody(state),
                    ),
          );
        },
      ),
    );
  }

  Widget _buildBody(FolderState state) {
    if (state.isLoadingFolderAudios && state.folderAudios.isEmpty) {
      return ListView(
        children: [
          SizedBox(height: 240),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (state.folderAudios.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 80),
          Icon(Icons.folder_off_outlined, size: 72, color: Colors.grey[600]),
          const SizedBox(height: 16),
          const Text(
            'No audio in this folder',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Move audio files into this folder to keep things organized.',
            style: TextStyle(color: Colors.grey[400]),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.folderAudios.length,
      itemBuilder: (context, index) {
        final audio = state.folderAudios[index];
        return AudioFileListItem(
          audioFile: audio,
          onTap: () => _openAudio(audio),
        );
      },
    );
  }
}
