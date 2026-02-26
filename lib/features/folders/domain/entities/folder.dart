import 'package:equatable/equatable.dart';

class Folder extends Equatable {
  final int id;
  final int? userId;
  final String name;
  final String? description;
  final String? color;
  final String? icon;
  final bool? isDefault;
  final int? audioCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Folder({
    required this.id,
    this.userId,
    required this.name,
    this.description,
    this.color,
    this.icon,
    this.isDefault,
    this.audioCount,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    description,
    color,
    icon,
    isDefault,
    audioCount,
    createdAt,
    updatedAt,
  ];
}
