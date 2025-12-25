import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/audio_manager_bloc.dart';
import '../bloc/audio_manager_event.dart';
import '../bloc/audio_manager_state.dart';
import '../tabs/pending_tab.dart';
import '../tabs/tasks_tab.dart';
import '../tabs/upload_tab.dart';

class AudioManagerPage extends StatefulWidget {
  const AudioManagerPage({super.key});

  @override
  State<AudioManagerPage> createState() => _AudioManagerPageState();
}

class _AudioManagerPageState extends State<AudioManagerPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: BlocListener<AudioManagerBloc, AudioManagerState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage ||
            previous.successMessage != current.successMessage,
        listener: (context, state) {
          final message = state.errorMessage ?? state.successMessage;
          if (message == null) {
            return;
          }
          final isError = state.errorMessage != null;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: isError ? Colors.red : const Color(0xFF3B82F6),
            ),
          );
          context.read<AudioManagerBloc>().add(const ClearMessage());
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF101822),
          body: SafeArea(
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    backgroundColor: const Color(0xFF101822),
                    elevation: 0,
                    centerTitle: true,
                    automaticallyImplyLeading: false,
                    floating: true,
                    snap: true,
                    pinned: false,
                    title: const Text(
                      'Audio Manager',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      const TabBar(
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Color(0xFF3B82F6),
                        dividerColor: Colors.transparent,
                        tabs: [
                          Tab(text: 'Upload'),
                          Tab(text: 'Tasks'),
                          Tab(text: 'Pending'),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: const TabBarView(
                children: [
                  UploadTab(),
                  TasksTab(),
                  PendingTab(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: const Color(0xFF101822),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
