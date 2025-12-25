import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/server_task.dart';
import '../bloc/audio_manager_bloc.dart';
import '../bloc/audio_manager_event.dart';
import '../bloc/audio_manager_state.dart';
import '../widgets/collapsible_section.dart';
import '../widgets/common_task_item.dart';

class TasksTab extends StatelessWidget {
  const TasksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioManagerBloc, AudioManagerState>(
      builder: (context, state) {
        final totalTasks =
            state.uploadingTasks.length +
            state.transcribingTasks.length +
            state.summarizingTasks.length;

        return RefreshIndicator(
          onRefresh: () async {
            context.read<AudioManagerBloc>().add(const LoadServerTasks());
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              if (state.isLoadingTasks && totalTasks == 0)
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
              else if (totalTasks == 0)
                const Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: Center(
                    child: Text(
                      'No active tasks right now',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                )
              else ...[
                CollapsibleSection(
                  title: 'Uploading',
                  count: state.uploadingTasks.length,
                  children:
                      state.uploadingTasks
                          .map(
                            (task) => _buildTaskItem(
                              context,
                              task,
                              icon: Icons.upload_file,
                              iconColor: Colors.orange,
                              description: _buildStatus(task),
                            ),
                          )
                          .toList(),
                ),
                CollapsibleSection(
                  title: 'Transcribing',
                  count: state.transcribingTasks.length,
                  children:
                      state.transcribingTasks
                          .map(
                            (task) => _buildTaskItem(
                              context,
                              task,
                              icon: Icons.description,
                              iconColor: Colors.blue,
                              description: _buildStatus(task),
                            ),
                          )
                          .toList(),
                ),
                CollapsibleSection(
                  title: 'Summarizing',
                  count: state.summarizingTasks.length,
                  children:
                      state.summarizingTasks
                          .map(
                            (task) => _buildTaskItem(
                              context,
                              task,
                              icon: Icons.notes,
                              iconColor: Colors.purple,
                              description: _buildStatus(task),
                            ),
                          )
                          .toList(),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskItem(
    BuildContext context,
    ServerTask task, {
    required IconData icon,
    required Color iconColor,
    required String description,
  }) {
    return CommonTaskItem(
      icon: icon,
      iconColor: iconColor,
      title: task.filename,
      description: description,
      isLoading: true,
      showChevron: false,
      onTap: () => _showTaskNotification(context, task.type),
    );
  }

  void _showTaskNotification(BuildContext context, ServerTaskType type) {
    final label = _taskLabel(type);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label in progress...'),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF3B82F6),
      ),
    );
  }

  String _taskLabel(ServerTaskType type) {
    switch (type) {
      case ServerTaskType.uploading:
        return 'Uploading';
      case ServerTaskType.transcribing:
        return 'Transcribing';
      case ServerTaskType.summarizing:
        return 'Summarizing';
    }
  }

  String _buildStatus(ServerTask task) {
    if (task.progress != null) {
      return '${task.status} ${task.progress}%';
    }
    return '${task.status}...';
  }
}
