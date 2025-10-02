import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? avatar;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    avatar,
    createdAt,
    updatedAt,
    isActive,
  ];
}
