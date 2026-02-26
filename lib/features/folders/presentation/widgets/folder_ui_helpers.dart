import 'package:flutter/material.dart';

const List<String> kFolderColorOptions = [
  '#3B82F6',
  '#10B981',
  '#F59E0B',
  '#EF4444',
  '#8B5CF6',
  '#14B8A6',
];

const Map<String, IconData> kFolderIconOptions = {
  'folder': Icons.folder,
  'work': Icons.work_outline,
  'mic': Icons.mic_none,
  'music': Icons.music_note,
  'book': Icons.book_outlined,
  'star': Icons.star_border,
};

Color parseHexColor(String? hex, {Color fallback = const Color(0xFF3B82F6)}) {
  if (hex == null || hex.trim().isEmpty) {
    return fallback;
  }
  var value = hex.trim().replaceAll('#', '');
  if (value.length == 6) {
    value = 'FF$value';
  }
  if (value.length != 8) {
    return fallback;
  }
  final parsed = int.tryParse(value, radix: 16);
  if (parsed == null) {
    return fallback;
  }
  return Color(parsed);
}

IconData folderIconFromName(String? name) {
  if (name == null) {
    return Icons.folder;
  }
  return kFolderIconOptions[name] ?? Icons.folder;
}
