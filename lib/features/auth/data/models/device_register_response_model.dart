import 'package:equatable/equatable.dart';

class DeviceRegisterResponseModel extends Equatable {
  final int id;
  final int userId;
  final String fcmToken;
  final String deviceType;
  final String? deviceName;
  final bool isActive;
  final DateTime lastLogin;

  const DeviceRegisterResponseModel({
    required this.id,
    required this.userId,
    required this.fcmToken,
    required this.deviceType,
    this.deviceName,
    required this.isActive,
    required this.lastLogin,
  });

  factory DeviceRegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return DeviceRegisterResponseModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      fcmToken: json['fcm_token'] as String,
      deviceType: json['device_type'] as String,
      deviceName: json['device_name'] as String?,
      isActive: json['is_active'] as bool,
      lastLogin: DateTime.parse(json['last_login'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        fcmToken,
        deviceType,
        deviceName,
        isActive,
        lastLogin,
      ];
}
