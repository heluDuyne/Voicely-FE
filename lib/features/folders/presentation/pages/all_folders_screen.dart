import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../injection_container/injection_container.dart';
import '../../domain/entities/folder.dart';
import '../bloc/folder_bloc.dart';
import '../bloc/folder_event.dart';
import '../bloc/folder_state.dart';
import '../widgets/folder_list_item.dart';

class AllFoldersScreen extends StatefulWidget {
  const AllFoldersScreen({super.key});

  @override
  State<AllFoldersScreen> createState() => _AllFoldersScreenState();
}

class _AllFoldersScreenState extends State<AllFoldersScreen> {
  late final FolderBloc _folderBloc;
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _folderBloc = sl<FolderBloc>();
    _searchController = TextEditingController();
    _scrollController = ScrollController()..addListener(_onScroll);
    _folderBloc.add(const LoadAllFolders());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _folderBloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    if (_scrollController.position.extentAfter < 240) {
      _folderBloc.add(const LoadMoreFolders());
    }
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final query = _searchController.text.trim();
      _folderBloc.add(SearchFolders(query));
    });
  }

  Future<void> _handleFolderTap(Folder folder) async {
    await context.push('/folders/${folder.id}');
    final query = _searchController.text.trim();
    _folderBloc.add(LoadAllFolders(query: query.isEmpty ? null : query));
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
          context.read<FolderBloc>().add(const ClearFolderMessage());
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFF101822),
            appBar: AppBar(
              backgroundColor: const Color(0xFF101822),
              elevation: 0,
              title: const Text(
                'All Folders',
                style: TextStyle(color: Colors.white),
              ),
              leading: IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF282E39),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => _onSearchChanged(),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search folders...',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          prefixIcon:
                              Icon(Icons.search, color: Colors.grey[600]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildFolderList(state),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFolderList(FolderState state) {
    if (state.isLoadingAll && state.allFolders.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!state.isLoadingAll && state.allFolders.isEmpty) {
      return Center(
        child: Text(
          'No folders found',
          style: TextStyle(color: Colors.grey[400]),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: state.allFolders.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.allFolders.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final folder = state.allFolders[index];
        return FolderListItem(
          folder: folder,
          onTap: () => _handleFolderTap(folder),
        );
      },
    );
  }
}
