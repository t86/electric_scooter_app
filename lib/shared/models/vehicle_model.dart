class VehicleModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int batteryLevel;
  final int remainingRange;
  final String lastUsed;
  final String status;

  VehicleModel({
    required this.id,
    required this.name,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.batteryLevel = 0,
    this.remainingRange = 0,
    required this.lastUsed,
    this.status = 'idle',
  });

  // 友好显示的最后使用时间
  String get lastUsedFriendly {
    final now = DateTime.now();
    final lastUsedDate = DateTime.parse(lastUsed);
    final difference = now.difference(lastUsedDate);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  // 从JSON创建实例
  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      batteryLevel: (json['batteryLevel'] as num?)?.toInt() ?? 0,
      remainingRange: (json['remainingRange'] as num?)?.toInt() ?? 0,
      lastUsed: json['lastUsed'] as String,
      status: json['status'] as String? ?? 'idle',
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'batteryLevel': batteryLevel,
      'remainingRange': remainingRange,
      'lastUsed': lastUsed,
      'status': status,
    };
  }

  // 复制当前实例并更新部分属性
  VehicleModel copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    int? batteryLevel,
    int? remainingRange,
    String? lastUsed,
    String? status,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      remainingRange: remainingRange ?? this.remainingRange,
      lastUsed: lastUsed ?? this.lastUsed,
      status: status ?? this.status,
    );
  }
} 