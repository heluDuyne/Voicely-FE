import 'package:equatable/equatable.dart';

class DeviceRegisterRequestModel extends Equatable {
  final String fcmToken;
  final String deviceType;
  final String? deviceName;

  const DeviceRegisterRequestModel({
    required this.fcmToken,
    required this.deviceType,
    this.deviceName,
  });

  Map<String, dynamic> toJson() {
    return {
      'fcm_token': fcmToken,
      'device_type': deviceType,
      if (deviceName != null) 'device_name': deviceName,
    };
  }

  @override
  List<Object?> get props => [fcmToken, deviceType, deviceName];
}
