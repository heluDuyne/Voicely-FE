import '../../domain/entities/folder.dart';

class FolderModel extends Folder {
  const FolderModel({
    required super.id,
    super.userId,
    required super.name,
    super.description,
    super.color,
    super.icon,
    super.isDefault,
    super.audioCount,
    super.createdAt,
    super.updatedAt,
  });

  factory FolderModel.fromJson(Map<String, dynamic> json) {
    int? _intFrom(dynamic value) {
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      if (value is String) {
        return int.tryParse(value);
      }
      return null;
    }

    bool? _boolFrom(dynamic value) {
      if (value is bool) {
        return value;
      }
      if (value is String) {
        if (value.toLowerCase() == 'true') {
          return true;
        }
        if (value.toLowerCase() == 'false') {
          return false;
        }
      }
      return null;
    }

    DateTime? _dateFrom(dynamic value) {
      if (value == null) {
        return null;
      }
      if (value is DateTime) {
        return value;
      }
      return DateTime.tryParse(value.toString());
    }

    return FolderModel(
      id: _intFrom(json['id']) ?? 0,
      userId: _intFrom(json['user_id']),
      name: json['name']?.toString() ?? 'Untitled',
      description: json['description']?.toString(),
      color: json['color']?.toString(),
      icon: json['icon']?.toString(),
      isDefault: _boolFrom(json['is_default']),
      audioCount: _intFrom(json['audio_count']),
      createdAt: _dateFrom(json['created_at']),
      updatedAt: _dateFrom(json['updated_at']),
    );
  }
}
