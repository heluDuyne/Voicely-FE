import 'package:equatable/equatable.dart';

class FolderCreate extends Equatable {
  final String name;
  final String? description;
  final String? color;
  final String? icon;
  final bool? isDefault;

  const FolderCreate({
    required this.name,
    this.description,
    this.color,
    this.icon,
    this.isDefault,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'name': name};
    if (description != null) {
      json['description'] = description;
    }
    if (color != null) {
      json['color'] = color;
    }
    if (icon != null) {
      json['icon'] = icon;
    }
    if (isDefault != null) {
      json['is_default'] = isDefault;
    }
    return json;
  }

  @override
  List<Object?> get props => [name, description, color, icon, isDefault];
}
