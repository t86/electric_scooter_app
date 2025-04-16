import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// 蓝牙服务接口
abstract class BleServiceInterface {
  /// 检查设备是否已连接
  bool get isConnected;
  
  /// 扫描设备
  dynamic scanForDevices();
  
  /// 连接到设备
  Future<bool> connectToDevice(dynamic device);
  
  /// 断开连接
  Future<void> disconnect();
  
  /// 读取速度
  Future<double?> readSpeed();
  
  /// 读取电量
  Future<int?> readBattery();
  
  /// 设置锁定状态
  Future<bool> setLockState(bool locked);
  
  /// 监听速度变化
  Stream<double>? subscribeToSpeed();
  
  /// 监听电量变化
  Stream<int>? subscribeToBattery();
  
  /// 发送消息
  Future<bool> sendMessage(String message);
  
  /// 监听消息
  Stream<String>? subscribeToMessages();
} 