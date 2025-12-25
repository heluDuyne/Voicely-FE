import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_router.dart';
import '../../domain/entities/pending_task.dart';
import '../bloc/audio_manager_bloc.dart';
import '../bloc/audio_manager_event.dart';
import '../bloc/audio_manager_state.dart';
import '../widgets/common_task_item.dart';

class PendingTab extends StatelessWidget {
  const PendingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioManagerBloc, AudioManagerState>(
      builder: (context, state) {
        final isEmpty =
            state.untranscribedAudios.isEmpty &&
            state.unsummarizedTranscripts.isEmpty;

        return RefreshIndicator(
          onRefresh: () async {
            context.read<AudioManagerBloc>().add(const LoadPendingTasks());
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              if (state.isLoadingPending && isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF3B82F6),
                      ),
                    ),
                  ),
                )
              else if (isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: Center(
                    child: Text(
                      'No pending tasks',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                )
              else ...[
                _SectionHeader(
                  title: 'Audio Not Transcribed',
                  showSeeAll: state.untranscribedAudios.length > 3,
                  onSeeAll:
                      () => _showSeeAllSheet(
                        context,
                        title: 'Audio Not Transcribed',
                        tasks: state.untranscribedAudios,
                        icon: Icons.mic,
                        iconColor: Colors.purple,
                      ),
                ),
                ...state.untranscribedAudios
                    .take(3)
                    .map(
                      (task) => _buildPendingItem(
                        context,
                        task,
                        icon: Icons.mic,
                        iconColor: Colors.purple,
                      ),
                    ),
                const SizedBox(height: 16),
                _SectionHeader(
                  title: 'Transcript Not Summarized',
                  showSeeAll: state.unsummarizedTranscripts.length > 3,
                  onSeeAll:
                      () => _showSeeAllSheet(
                        context,
                        title: 'Transcript Not Summarized',
                        tasks: state.unsummarizedTranscripts,
                        icon: Icons.notes,
                        iconColor: Colors.teal,
                      ),
                ),
                ...state.unsummarizedTranscripts
                    .take(3)
                    .map(
                      (task) => _buildPendingItem(
                        context,
                        task,
                        icon: Icons.notes,
                        iconColor: Colors.teal,
                      ),
                    ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPendingItem(
    BuildContext context,
    PendingTask task, {
    required IconData icon,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CommonTaskItem(
        icon: icon,
        iconColor: iconColor,
        title: task.title,
        description: task.description,
        onTap: () => _handlePendingTap(context, task),
      ),
    );
  }

  void _handlePendingTap(BuildContext context, PendingTask task) {
    if (task.type == PendingTaskType.untranscribedAudio) {
      final url =
          '${AppRoutes.transcription}?title=${Uri.encodeComponent(task.title)}&audioId=${task.id}';
      context.push(url);
      return;
    }

    final url =
        '${AppRoutes.summary}?title=${Uri.encodeComponent(task.title)}&transcriptionId=${task.id}';
    context.push(url);
  }

  void _showSeeAllSheet(
    BuildContext context, {
    required String title,
    required List<PendingTask> tasks,
    required IconData icon,
    required Color iconColor,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF101822),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return CommonTaskItem(
                        icon: icon,
                        iconColor: iconColor,
                        title: task.title,
                        description: task.description,
                        onTap: () {
                          Navigator.of(context).pop();
                          _handlePendingTap(context, task);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool showSeeAll;
  final VoidCallback onSeeAll;

  const _SectionHeader({
    required this.title,
    required this.showSeeAll,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (showSeeAll)
            TextButton(
              onPressed: onSeeAll,
              child: const Text(
                'See All',
                style: TextStyle(color: Color(0xFF3B82F6)),
              ),
            ),
        ],
      ),
    );
  }
}
