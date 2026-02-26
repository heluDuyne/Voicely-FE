import 'package:flutter/material.dart';
import '../../domain/entities/folder.dart';
import 'folder_ui_helpers.dart';

class FolderListItem extends StatelessWidget {
  final Folder folder;
  final VoidCallback? onTap;

  const FolderListItem({
    super.key,
    required this.folder,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = parseHexColor(folder.color);
    final icon = folderIconFromName(folder.icon);
    final description = folder.description;
    final audioCount = folder.audioCount ?? 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF282E39),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    folder.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description == null || description.isEmpty
                        ? '$audioCount audio files'
                        : '$description • $audioCount files',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}
