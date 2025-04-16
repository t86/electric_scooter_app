import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:rxdart/rxdart.dart';
import '../models/ble_protocol.dart';
import 'ble_service_interface.dart';

/// 真实的蓝牙服务类，使用flutter_blue_plus库实现
class BleService implements BleServiceInterface {
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal();

  BluetoothDevice? _device;
  Map<String, BluetoothCharacteristic> _characteristics = {};
  bool _isConnected = false;
  
  // 数据流控制器
  final _speedStreamController = StreamController<double>.broadcast();
  final _batteryStreamController = StreamController<int>.broadcast();
  final _messageStreamController = StreamController<String>.broadcast();
  
  // 消息历史记录
  List<Map<String, dynamic>> _messageHistory = [];
  
  // 获取消息历史
  List<Map<String, dynamic>> get messageHistory => List.from(_messageHistory);

  @override
  bool get isConnected => _isConnected && _device != null;

  /// 扫描设备
  @override
  Stream<BluetoothDevice> scanForDevices() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
    
    _addToHistory('系统', '开始扫描设备', 'info');
    _addToHistory('帧', '0x01 0x03 0xFF 0xFF 0x00 0x00', 'frame');
    
    // 过滤出名称包含"Electric Scooter"的设备
    return FlutterBluePlus.scanResults
        .map((results) => results
            .where((r) => r.device.platformName.contains('Electric Scooter'))
            .map((r) => r.device))
        .expand((devices) => devices)
        .distinct();
  }

  /// 连接到设备
  @override
  Future<bool> connectToDevice(dynamic device) async {
    if (device is! BluetoothDevice) {
      print('无效的设备类型');
      return false;
    }
    
    BluetoothDevice bluetoothDevice = device;
    
    try {
      _addToHistory('系统', '正在连接到设备: ${bluetoothDevice.platformName}', 'info');
      _addToHistory('帧', '0x02 0x03 0x${bluetoothDevice.remoteId.toString().substring(0, 4).codeUnits.map((c) => c.toRadixString(16).padLeft(2, '0')).join(' ')} 0xFF 0xFF', 'frame');
      
      await bluetoothDevice.connect();
      _device = bluetoothDevice;
      _isConnected = true;
      
      _addToHistory('系统', '成功连接到设备: ${bluetoothDevice.platformName}', 'info');
      _addToHistory('帧', '0x02 0x04 0x${bluetoothDevice.remoteId.toString().substring(0, 4).codeUnits.map((c) => c.toRadixString(16).padLeft(2, '0')).join(' ')} 0x00 0x00', 'frame');
      
      // 发现服务和特征
      await _discoverServicesAndCharacteristics();
      
      return true;
    } catch (e) {
      print('连接设备时出错: $e');
      _addToHistory('错误', '连接设备失败: $e', 'error');
      _addToHistory('帧', '0x02 0x05 0xFF 0xFF 0xFF 0xFF', 'frame');
      return false;
    }
  }

  /// 断开连接
  @override
  Future<void> disconnect() async {
    try {
      if (_device != null) {
        _addToHistory('系统', '正在断开连接', 'info');
        _addToHistory('帧', '0x03 0x01 0xFF 0xFF 0x00 0x00', 'frame');
        
        await _device!.disconnect();
        _device = null;
        _isConnected = false;
        _characteristics.clear();
        
        _addToHistory('系统', '已断开连接', 'info');
        _addToHistory('帧', '0x03 0x02 0xFF 0xFF 0x00 0x00', 'frame');
      }
    } catch (e) {
      print('断开连接时出错: $e');
      _addToHistory('错误', '断开连接失败: $e', 'error');
      _addToHistory('帧', '0x03 0x05 0xFF 0xFF 0xFF 0xFF', 'frame');
    }
  }

  /// 发现服务和特征
  Future<void> _discoverServicesAndCharacteristics() async {
    if (_device == null) return;
    
    try {
      _addToHistory('系统', '正在发现服务和特征', 'info');
      _addToHistory('帧', '0x04 0x01 0xFF 0xFF 0x00 0x00', 'frame');
      
      List<BluetoothService> services = await _device!.discoverServices();
      
      for (var service in services) {
        // 寻找电动滑板车服务的UUID
        if (service.uuid.toString().toUpperCase().contains('181A')) {
          for (var characteristic in service.characteristics) {
            final uuid = characteristic.uuid.toString().toUpperCase();
            
            // 存储特征UUID到字典中
            if (uuid.contains('2A6D')) {         // 速度特征
              _characteristics['speed'] = characteristic;
              _addToHistory('系统', '发现速度特征: ${characteristic.uuid}', 'info');
            } else if (uuid.contains('2A19')) {  // 电池特征
              _characteristics['battery'] = characteristic;
              _addToHistory('系统', '发现电池特征: ${characteristic.uuid}', 'info');
            } else if (uuid.contains('2A6F')) {  // 锁定特征
              _characteristics['lock'] = characteristic;
              _addToHistory('系统', '发现锁定特征: ${characteristic.uuid}', 'info');
            } else if (uuid.contains('2A3D')) {  // 消息特征
              _characteristics['message'] = characteristic;
              _addToHistory('系统', '发现消息特征: ${characteristic.uuid}', 'info');
              
              // 订阅消息通知
              await characteristic.setNotifyValue(true);
              characteristic.lastValueStream.listen((value) {
                if (value.isNotEmpty) {
                  // 尝试解析为文本
                  String message = String.fromCharCodes(value);
                  _messageStreamController.add(message);
                  
                  _addToHistory('接收', message, 'incoming');
                  _addToHistory('帧', value.map((byte) => '0x${byte.toRadixString(16).padLeft(2, '0').toUpperCase()}').join(' '), 'frame');
                }
              });
            }
          }
        }
      }
      
      _addToHistory('系统', '服务和特征发现完成', 'info');
      _addToHistory('帧', '0x04 0x02 0xFF 0xFF 0x00 0x00', 'frame');
    } catch (e) {
      print('发现服务和特征时出错: $e');
      _addToHistory('错误', '发现服务和特征失败: $e', 'error');
      _addToHistory('帧', '0x04 0x05 0xFF 0xFF 0xFF 0xFF', 'frame');
    }
  }

  /// 读取速度
  @override
  Future<double?> readSpeed() async {
    if (!isConnected || !_characteristics.containsKey('speed')) {
      return null;
    }
    
    try {
      // 构建读取速度的命令帧
      List<int> frame = [];
      frame.addAll([0x5A, 0xA5, 0x01, 0x00, 0x01, 0x01, 0x00, 0x00, 0x3C]);
      
      // 计算CRC
      int crc = _calculateCRC16(frame);
      frame.add((crc >> 8) & 0xFF);
      frame.add(crc & 0xFF);
      
      _addToHistory('请求', '读取速度', 'outgoing');
      _addToHistory('帧', frame.map((byte) => '0x${byte.toRadixString(16).padLeft(2, '0')}').join(' '), 'frame');
      
      // 发送请求，然后读取特征值
      await _characteristics['speed']!.write(frame, withoutResponse: false);
      List<int> value = await _characteristics['speed']!.read();
      
      // 假设速度值是单字节或双字节值，转换为km/h
      double speed = 0;
      if (value.length >= 1) {
        speed = value[0].toDouble();
        if (value.length >= 2) {
          speed += value[1] * 256;
        }
        speed = speed / 10; // 转换为km/h
      }
      
      _addToHistory('响应', '当前速度: ${speed.toStringAsFixed(1)}km/h', 'incoming');
      _addToHistory('帧', '0x5AA5 0x03 0x00 0x11 0x01 0x00 ${value.map((byte) => '0x${byte.toRadixString(16).padLeft(2, '0')}').join(' ')} 0x3C', 'frame');
      
      return speed;
    } catch (e) {
      print('读取速度时出错: $e');
      _addToHistory('错误', '读取速度失败: $e', 'error');
      _addToHistory('帧', '0x5AA5 0x01 0x00 0x21 0x01 0x00 0xFF 0x3C', 'frame');
      return null;
    }
  }

  /// 读取电量
  @override
  Future<int?> readBattery() async {
    if (!isConnected || !_characteristics.containsKey('battery')) {
      return null;
    }
    
    try {
      // 构建读取电量的命令帧
      List<int> frame = [];
      frame.addAll([0x5A, 0xA5, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x3C]);
      
      // 计算CRC
      int crc = _calculateCRC16(frame);
      frame.add((crc >> 8) & 0xFF);
      frame.add(crc & 0xFF);
      
      _addToHistory('请求', '读取电量', 'outgoing');
      _addToHistory('帧', frame.map((byte) => '0x${byte.toRadixString(16).padLeft(2, '0')}').join(' '), 'frame');
      
      // 发送请求，然后读取特征值
      await _characteristics['battery']!.write(frame, withoutResponse: false);
      List<int> value = await _characteristics['battery']!.read();
      
      // 假设电量值是单字节值，范围0-100
      int battery = value.isNotEmpty ? value[0] : 0;
      
      _addToHistory('响应', '当前电量: $battery%', 'incoming');
      _addToHistory('帧', '0x5AA5 0x01 0x01 0x11 0x01 0x00 0x${battery.toRadixString(16).padLeft(2, '0')} 0x3C', 'frame');
      
      return battery;
    } catch (e) {
      print('读取电量时出错: $e');
      _addToHistory('错误', '读取电量失败: $e', 'error');
      _addToHistory('帧', '0x5AA5 0x01 0x01 0x21 0x01 0x00 0xFF 0x3C', 'frame');
      return null;
    }
  }

  /// 设置锁定状态
  @override
  Future<bool> setLockState(bool locked) async {
    if (!isConnected || !_characteristics.containsKey('lock')) {
      return false;
    }
    
    try {
      // 创建锁定命令帧
      List<int> frame = [];
      final lockByte = locked ? 0x01 : 0x00;
      frame.addAll([0x5A, 0xA5, 0x01, 0x02, 0x02, 0x01, 0x00, lockByte, 0x3C]);
      
      // 计算CRC
      int crc = _calculateCRC16(frame);
      frame.add((crc >> 8) & 0xFF);
      frame.add(crc & 0xFF);
      
      _addToHistory('请求', '设置锁定状态: ${locked ? "锁定" : "解锁"}', 'outgoing');
      _addToHistory('帧', frame.map((byte) => '0x${byte.toRadixString(16).padLeft(2, '0')}').join(' '), 'frame');
      
      await _characteristics['lock']!.write(frame, withoutResponse: false);
      
      _addToHistory('响应', '锁定状态已更新为: ${locked ? "锁定" : "解锁"}', 'incoming');
      _addToHistory('帧', '0x5AA5 0x01 0x02 0x12 0x01 0x00 0x${lockByte.toRadixString(16).padLeft(2, '0')} 0x3C', 'frame');
      
      return true;
    } catch (e) {
      print('设置锁定状态时出错: $e');
      _addToHistory('错误', '设置锁定状态失败: $e', 'error');
      _addToHistory('帧', '0x5AA5 0x01 0x02 0x22 0x01 0x00 0xFF 0x3C', 'frame');
      return false;
    }
  }

  /// 监听速度变化
  @override
  Stream<double>? subscribeToSpeed() {
    if (!isConnected || !_characteristics.containsKey('speed')) {
      return null;
    }
    
    try {
      _addToHistory('系统', '开始监听速度变化', 'info');
      _addToHistory('帧', '0x5AA5 0x01 0x00 0x03 0x01 0x01 0x3C', 'frame');
      
      _characteristics['speed']!.setNotifyValue(true);
      
      return _characteristics['speed']!.lastValueStream
          .map((value) {
            // 转换二进制数据为速度值
            double speed = 0;
            if (value.length >= 1) {
              speed = value[0].toDouble();
              if (value.length >= 2) {
                speed += value[1] * 256;
              }
              speed = speed / 10; // 转换为km/h
            }
            
            _addToHistory('通知', '速度更新: ${speed.toStringAsFixed(1)}km/h', 'status');
            _addToHistory('帧', '0x5AA5 0x${value.length.toRadixString(16).padLeft(2, '0')} 0x00 0x13 0x01 ${value.map((byte) => '0x${byte.toRadixString(16).padLeft(2, '0')}').join(' ')} 0x3C', 'frame');
            
            return speed;
          });
    } catch (e) {
      print('订阅速度变化时出错: $e');
      _addToHistory('错误', '无法监听速度变化: $e', 'error');
      return null;
    }
  }

  /// 监听电量变化
  @override
  Stream<int>? subscribeToBattery() {
    if (!isConnected || !_characteristics.containsKey('battery')) {
      return null;
    }
    
    try {
      _addToHistory('系统', '开始监听电量变化', 'info');
      _addToHistory('帧', '0x5AA5 0x01 0x01 0x03 0x01 0x01 0x3C', 'frame');
      
      _characteristics['battery']!.setNotifyValue(true);
      
      return _characteristics['battery']!.lastValueStream
          .map((value) {
            // 转换二进制数据为电量值
            int battery = value.isNotEmpty ? value[0] : 0;
            
            _addToHistory('通知', '电量更新: $battery%', 'status');
            _addToHistory('帧', '0x5AA5 0x01 0x01 0x13 0x01 0x${battery.toRadixString(16).padLeft(2, '0')} 0x3C', 'frame');
            
            return battery;
          });
    } catch (e) {
      print('订阅电量变化时出错: $e');
      _addToHistory('错误', '无法监听电量变化: $e', 'error');
      return null;
    }
  }

  /// 发送消息
  @override
  Future<bool> sendMessage(String message) async {
    if (!isConnected || !_characteristics.containsKey('message')) {
      return false;
    }
    
    try {
      // 消息过长时截断，避免问题
      if (message.length > 10) {
        message = message.substring(0, 10);
      }
      
      // 将消息转换为UTF-16编码的字节数组（每个中文字符2字节）
      List<int> data = [];
      for (int i = 0; i < message.length; i++) {
        int charCode = message.codeUnitAt(i);
        data.add((charCode >> 8) & 0xFF);  // 高字节
        data.add(charCode & 0xFF);         // 低字节
      }
      
      // 计算实际数据长度（字节数）
      int dataLength = data.length;
      
      // 构建消息帧（包括帧尾，但不包括CRC）
      List<int> frame = [];
      frame.addAll([0x5A, 0xA5]);                    // 帧头
      frame.add(dataLength);                         // 数据长度
      frame.addAll([0xFF, 0x02, 0x01]);             // 命令类型、命令、参数个数
      frame.add(0x00);                              // 序号(非Log消息固定为0x00)
      frame.addAll(data);                           // 数据
      frame.add(0x3C);                              // 帧尾
      
      // 计算CRC16校验（使用MODBUS算法）
      int crc = _calculateCRC16(frame);              // 计算包括帧尾在内的所有数据的CRC
      frame.add((crc >> 8) & 0xFF);                 // CRC高字节
      frame.add(crc & 0xFF);                        // CRC低字节
      
      _addToHistory('发送', message, 'outgoing');
      _addToHistory('帧', frame.map((byte) => '0x${byte.toRadixString(16).padLeft(2, '0')}').join(' '), 'frame');
      
      await _characteristics['message']!.write(frame, withoutResponse: false);
      
      return true;
    } catch (e) {
      print('发送消息时出错: $e');
      _addToHistory('错误', '发送消息失败: $e', 'error');
      _addToHistory('帧', '0x5AA5 0x01 0xFF 0x22 0x01 0x00 0xFF 0x3C', 'frame');
      return false;
    }
  }
  
  /// 计算CRC16校验（MODBUS算法）
  int _calculateCRC16(List<int> data) {
    int crc = 0xFFFF;
    for (int byte in data) {
      crc ^= byte;
      for (int i = 0; i < 8; i++) {
        if ((crc & 0x0001) != 0) {
          crc = (crc >> 1) ^ 0xA001;
        } else {
          crc = crc >> 1;
        }
      }
    }
    return crc;
  }

  /// 监听消息
  @override
  Stream<String>? subscribeToMessages() {
    if (!isConnected) {
      return null;
    }
    
    // 返回消息流
    return _messageStreamController.stream;
  }
  
  /// 添加消息到历史记录
  void _addToHistory(String sender, String message, String type) {
    _messageHistory.add({
      'sender': sender,
      'message': message,
      'type': type,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    
    // 限制历史记录长度，避免内存过度占用
    if (_messageHistory.length > 100) {
      _messageHistory.removeAt(0);
    }
    
    // 打印到控制台
    if (type == 'frame') {
      print('[$sender] 原始16进制报文: $message');
    } else {
      print('[$sender] $message');
    }
  }
  
  /// 清理资源
  void dispose() {
    _speedStreamController.close();
    _batteryStreamController.close();
    _messageStreamController.close();
  }
} 