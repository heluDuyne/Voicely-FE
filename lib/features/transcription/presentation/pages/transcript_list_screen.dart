import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../injection_container/injection_container.dart';
import '../../../audio_manager/domain/entities/audio_file.dart';
import '../../../audio_manager/presentation/pages/audio_detail_screen.dart';
import '../../../folders/domain/entities/folder.dart';
import '../../../folders/domain/entities/folder_create.dart';
import '../../../folders/presentation/bloc/folder_bloc.dart';
import '../../../folders/presentation/bloc/folder_event.dart';
import '../../../folders/presentation/bloc/folder_state.dart';
import '../../../folders/presentation/widgets/folder_ui_helpers.dart';
import '../widgets/folder_card.dart';
import '../widgets/transcript_card.dart';

class TranscriptListScreen extends StatefulWidget {
  const TranscriptListScreen({super.key});

  @override
  State<TranscriptListScreen> createState() => _TranscriptListScreenState();
}

class _TranscriptListScreenState extends State<TranscriptListScreen> {
  late final FolderBloc _folderBloc;

  @override
  void initState() {
    super.initState();
    _folderBloc = sl<FolderBloc>();
    _folderBloc
      ..add(const LoadFolders())
      ..add(const LoadRecentTranscripts());
  }

  @override
  void dispose() {
    _folderBloc.close();
    super.dispose();
  }

  void _openAllFolders() {
    context.push(AppRoutes.allFolders);
  }

  Future<void> _openFolder(Folder folder) async {
    await context.push('/folders/${folder.id}');
    _folderBloc.add(const LoadFolders());
  }

  void _openAudio(AudioFile audioFile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AudioDetailScreen(audioFile: audioFile),
      ),
    );
  }

  Future<void> _handleCreateFolder() async {
    final result = await _showCreateFolderDialog();
    if (result == null) {
      return;
    }
    _folderBloc.add(CreateFolder(result));
  }

  Future<FolderCreate?> _showCreateFolderDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedColor = kFolderColorOptions.first;
    String selectedIcon = kFolderIconOptions.keys.first;

    final created = await showDialog<FolderCreate>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create Folder'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Folder name',
                        border: OutlineInputBorder(),
                      ),
                      autofocus: true,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Color',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children:
                          kFolderColorOptions.map((hex) {
                            final color = parseHexColor(hex);
                            final isSelected = selectedColor == hex;
                            return GestureDetector(
                              onTap: () => setState(() => selectedColor = hex),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: isSelected
                                      ? Border.all(
                                          color: Colors.black87,
                                          width: 2,
                                        )
                                      : null,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Icon',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children:
                          kFolderIconOptions.entries.map((entry) {
                            final isSelected = selectedIcon == entry.key;
                            return GestureDetector(
                              onTap: () => setState(() => selectedIcon = entry.key),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.black12
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.black87
                                        : Colors.black26,
                                  ),
                                ),
                                child: Icon(entry.value),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a folder name'),
                        ),
                      );
                      return;
                    }
                    final description = descriptionController.text.trim();
                    Navigator.pop(
                      context,
                      FolderCreate(
                        name: name,
                        description: description.isEmpty ? null : description,
                        color: selectedColor,
                        icon: selectedIcon,
                      ),
                    );
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );

    return created;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocProvider.value(
      value: _folderBloc,
      child: BlocConsumer<FolderBloc, FolderState>(
        listener: (context, state) {
          final message = state.errorMessage ?? state.successMessage;
          if (message == null) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
          context.read<FolderBloc>().add(const ClearFolderMessage());
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFF101822),
            body: SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: const Color(0xFF101822),
                    elevation: 0,
                    centerTitle: true,
                    automaticallyImplyLeading: false,
                    floating: true,
                    snap: true,
                    pinned: false,
                    title: const Text(
                      'Folders',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth > 600
                          ? screenWidth * 0.1
                          : 16.0,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 8),
                        if (state.isCreating)
                          const LinearProgressIndicator(
                            backgroundColor: Color(0xFF101822),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF3B82F6),
                            ),
                          ),
                        const SizedBox(height: 16),
                        _buildFoldersSection(state),
                        const SizedBox(height: 24),
                        _buildRecentTranscriptsSection(state),
                        const SizedBox(height: 24),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFoldersSection(FolderState state) {
    final showSeeAll = state.homeTotalCount > 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Folders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (showSeeAll)
              TextButton(
                onPressed: _openAllFolders,
                child: const Text('See All'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _handleCreateFolder,
            icon: const Icon(Icons.add),
            label: const Text('Create Folder'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (state.isLoadingHome)
          _buildFolderLoadingGrid()
        else if (state.homeFolders.isEmpty)
          _buildEmptyFoldersState()
        else
          _buildFolderGrid(state.homeFolders),
      ],
    );
  }

  Widget _buildFolderLoadingGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF282E39),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }

  Widget _buildEmptyFoldersState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF282E39),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.folder_off_outlined, size: 48, color: Colors.grey[500]),
          const SizedBox(height: 12),
          const Text(
            'No folders yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Create a folder to organize your recordings.',
            style: TextStyle(color: Colors.grey[400]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFolderGrid(List<Folder> folders) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: folders.length,
      itemBuilder: (context, index) {
        final folder = folders[index];
        final color = parseHexColor(folder.color);
        return FolderCard(
          name: folder.name,
          fileCount: folder.audioCount ?? 0,
          iconColor: color,
          indicatorColor: color,
          icon: folderIconFromName(folder.icon),
          onTap: () => _openFolder(folder),
        );
      },
    );
  }

  Widget _buildRecentTranscriptsSection(FolderState state) {
    if (state.isLoadingRecent) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Transcripts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        if (state.recentTranscripts.isEmpty)
          Text(
            'No recent transcripts yet.',
            style: TextStyle(color: Colors.grey[400]),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.recentTranscripts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final audio = state.recentTranscripts[index];
              final duration = Duration(
                seconds: (audio.duration ?? 0).round(),
              );
              return TranscriptCardWithDuration(
                title: audio.originalFilename ?? audio.filename,
                duration: duration,
                createdAt: audio.createdAt,
                onTap: () => _openAudio(audio),
              );
            },
          ),
      ],
    );
  }
}
