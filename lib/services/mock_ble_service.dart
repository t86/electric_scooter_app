import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import '../models/ble_protocol.dart';
import 'ble_service_interface.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// 模拟的蓝牙服务类，用于开发和测试
class MockBleService implements BleServiceInterface {
  static final MockBleService _instance = MockBleService._internal();
  factory MockBleService() => _instance;
  MockBleService._internal();

  // 模拟设备连接状态
  bool _connected = false;
  String? _connectedDeviceName;
  @override
  bool get isConnected => _connected;

  // 模拟设备数据
  double _currentSpeed = 0.0;
  int _currentBattery = 100;
  bool _isLocked = true;
  
  // 响应延迟配置
  final int _minResponseDelay = 100; // 最小响应延迟(毫秒)
  final int _maxResponseDelay = 500; // 最大响应延迟(毫秒)
  
  // 数据流控制器
  final _speedStreamController = StreamController<double>.broadcast();
  final _batteryStreamController = StreamController<int>.broadcast();
  final _messageStreamController = StreamController<String>.broadcast();
  
  // 消息历史记录
  List<Map<String, dynamic>> _messageHistory = [];
  
  // 获取消息历史
  List<Map<String, dynamic>> get messageHistory => List.from(_messageHistory);
  
  // 模拟设备列表
  final List<Map<String, dynamic>> _mockDevices = [
    {
      'id': '00:11:22:33:44:55',
      'name': 'Electric Scooter 001',
      'rssi': -65,
    },
    {
      'id': 'AA:BB:CC:DD:EE:FF',
      'name': 'Electric Scooter 002',
      'rssi': -78,
    },
  ];
  
  /// 扫描设备
  @override
  Stream<Map<String, dynamic>> scanForDevices() {
    // 返回一个延迟发送模拟设备列表的流
    return Stream.fromIterable(_mockDevices)
        .delay(const Duration(milliseconds: 500))
        .asyncMap((device) async {
          // 随机延迟以模拟真实的发现时间
          await Future.delayed(Duration(milliseconds: Random().nextInt(300) + 200));
          return device;
        });
  }

  /// 连接到设备
  @override
  Future<bool> connectToDevice(dynamic device) async {
    // 模拟连接延迟
    await Future.delayed(const Duration(seconds: 1));
    
    // 随机决定是否连接成功(90%概率成功)
    final success = Random().nextDouble() < 0.9;
    
    if (success) {
      _connected = true;
      
      // 记录连接消息
      _addToHistory('系统', '成功连接到设备', 'info');
      
      // 发送初始设备状态
      _addToHistory('设备', '初始状态: 速度=${_currentSpeed}km/h, 电量=${_currentBattery}%, 锁定=${_isLocked}', 'status');
      
      // 模拟设备连接后开始定期发送数据更新
      _startPeriodicUpdates();
      
      print('已连接到模拟设备: ${device['name']}');
    } else {
      _addToHistory('系统', '连接失败', 'error');
      print('连接到模拟设备失败: ${device['name']}');
    }
    
    return success;
  }

  /// 断开连接
  @override
  Future<void> disconnect() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _connected = false;
    _addToHistory('系统', '断开连接', 'info');
    print('已断开与模拟设备的连接');
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

  /// 读取速度
  @override
  Future<double?> readSpeed() async {
    if (!_connected) return null;
    
    // 创建读取速度请求帧
    List<int> requestFrame = [0x5A, 0xA5, 0x01, 0x00, 0x01, 0x01, 0x00, 0x00, 0x3C];
    int requestCrc = _calculateCRC16(requestFrame);
    requestFrame.add((requestCrc >> 8) & 0xFF);
    requestFrame.add(requestCrc & 0xFF);
    
    final requestHexString = requestFrame.map((byte) => '0x${byte.toRadixString(16).padLeft(2, '0')}').join(' ');
    _addToHistory('请求', '读取速度', 'outgoing');
    _addToHistory('帧', requestHexString, 'frame');
    print('请求: 读取速度');
    print('原始16进制报文: $requestHexString');
    
    await Future.delayed(Duration(milliseconds: _getRandomResponseDelay()));
    
    // 创建速度响应帧
    final speedByte = _currentSpeed.toInt() & 0xFF;
    List<int> responseFrame = [0x5A, 0xA5, 0x01, 0x00, 0x11, 0x01, 0x00, speedByte, 0x3C];
    int responseCrc = _calculateCRC16(responseFrame);
    responseFrame.add((responseCrc >> 8) & 0xFF);
    responseFrame.add(responseCrc & 0xFF);
    
    final responseHexString = responseFrame.map((byte) => '0x${byte.toRadixString(16).padLeft(2, '0')}').join(' ');
    _addToHistory('响应', '当前速度: ${_currentSpeed}km/h', 'incoming');
    _addToHistory('帧', responseHexString, 'frame');
    print('响应: 当前速度: ${_currentSpeed}km/h');
    print('原始16进制报文: $responseHexString');
    
    return _currentSpeed;
  }

  /// 读取电量
  @override
  Future<int?> readBattery() async {
    if (!_connected) return null;
    
    // 创建读取电量请求帧
    List<int> requestFrame = [0x5A, 0xA5, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x3C];
    int requestCrc = _calculateCRC16(requestFrame);
    requestFrame.add((requestCrc >> 8) & 0xFF);
    requestFrame.add(requestCrc & 0xFF);
    
    final requestHexString = requestFrame.map((byte) => '0x${byte.toRadixString(16).padLeft(2, '0')}').join(' ');
    _addToHistory('请求', '读取电量', 'outgoing');
    _addToHistory('帧', requestHexString, 'frame');
    print('请求: 读取电量');
    print('原始16进制报文: $requestHexString');
    
    await Future.delayed(Duration(milliseconds: _getRandomResponseDelay()));
    
    // 创建电量响应帧
    final batteryByte = _currentBattery & 0xFF;
    List<int> responseFrame = [0x5A, 0xA5, 0x01, 0x01, 0x11, 0x01, 0x00, batteryByte, 0x3C];
    int responseCrc = _calculateCRC16(responseFrame);
    responseFrame.add((responseCrc >> 8) & 0xFF);
    responseFrame.add(responseCrc & 0xFF);
    
    final responseHexString = responseFrame.map((byte) => '0x${byte.toRadixString(16).padLeft(2, '0')}').join(' ');
    _addToHistory('响应', '当前电量: ${_currentBattery}%', 'incoming');
    _addToHistory('帧', responseHexString, 'frame');
    print('响应: 当前电量: ${_currentBattery}%');
    print('原始16进制报文: $responseHexString');
    
    return _currentBattery;
  }

  /// 设置锁定状态
  @override
  Future<bool> setLockState(bool locked) async {
    if (!_connected) return false;
    
    // 创建设置锁定状态请求帧
    final lockByte = locked ? 0x01 : 0x00;
    List<int> requestFrame = [0x5A, 0xA5, 0x01, 0x02, 0x02, 0x01, 0x00, lockByte, 0x3C];
    int requestCrc = _calculateCRC16(requestFrame);
    requestFrame.add((requestCrc >> 8) & 0xFF);
    requestFrame.add(requestCrc & 0xFF);
    
    final requestHexString = requestFrame.map((byte) => '0x${byte.toRadixString(16).padLeft(2, '0')}').join(' ');
    _addToHistory('请求', '设置锁定状态: ${locked ? "锁定" : "解锁"}', 'outgoing');
    _addToHistory('帧', requestHexString, 'frame');
    
    await Future.delayed(Duration(milliseconds: _getRandomResponseDelay()));
    
    // 90%概率操作成功
    final success = Random().nextDouble() < 0.9;
    
    if (success) {
      _isLocked = locked;
      
      // 创建锁定状态响应帧
      List<int> responseFrame = [0x5A, 0xA5, 0x01, 0x02, 0x12, 0x01, 0x00, lockByte, 0x3C];
      int responseCrc = _calculateCRC16(responseFrame);
      responseFrame.add((responseCrc >> 8) & 0xFF);
      responseFrame.add(responseCrc & 0xFF);
      
      final responseHexString = responseFrame.map((byte) => '0x${byte.toRadixString(16).padLeft(2, '0')}').join(' ');
      _addToHistory('响应', '锁定状态已更新为: ${locked ? "锁定" : "解锁"}', 'incoming');
      _addToHistory('帧', responseHexString, 'frame');
      
      // 如果解锁，开始模拟速度变化
      if (!locked) {
        _simulateSpeedChanges();
        _addToHistory('设备', '设备已解锁，可以启动', 'status');
      } else {
        _currentSpeed = 0;
        _speedStreamController.add(_currentSpeed);
        _addToHistory('设备', '设备已锁定，已停止', 'status');
      }
    } else {
      // 创建锁定失败响应帧
      List<int> errorFrame = [0x5A, 0xA5, 0x01, 0x02, 0x22, 0x01, 0x00, 0xFF, 0x3C];
      int errorCrc = _calculateCRC16(errorFrame);
      errorFrame.add((errorCrc >> 8) & 0xFF);
      errorFrame.add(errorCrc & 0xFF);
      
      final errorHexString = errorFrame.map((byte) => '0x${byte.toRadixString(16).padLeft(2, '0')}').join(' ');
      _addToHistory('错误', '设置锁定状态失败', 'error');
      _addToHistory('帧', errorHexString, 'frame');
    }
    
    return success;
  }

  /// 监听速度变化
  @override
  Stream<double>? subscribeToSpeed() {
    if (!_connected) return null;
    return _speedStreamController.stream;
  }

  /// 监听电量变化
  @override
  Stream<int>? subscribeToBattery() {
    if (!_connected) return null;
    return _batteryStreamController.stream;
  }
  
  /// 开始周期性更新
  void _startPeriodicUpdates() {
    // 电量每30秒降低1%
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_connected) {
        timer.cancel();
        return;
      }
      
      if (_currentBattery > 0 && !_isLocked) {
        _currentBattery -= 1;
        _batteryStreamController.add(_currentBattery);
        _addToHistory('设备', '电量更新: ${_currentBattery}%', 'status');
      }
    });
  }
  
  /// 模拟速度变化
  void _simulateSpeedChanges() {
    if (_isLocked) return;
    
    // 随机增减速度，模拟真实骑行
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_connected || _isLocked) {
        timer.cancel();
        return;
      }
      
      // 随机增减速度，保持在0-25km/h之间
      final speedChange = Random().nextDouble() * 2 - 0.5; // -0.5到1.5之间的变化
      _currentSpeed = (_currentSpeed + speedChange).clamp(0, 25);
      _speedStreamController.add(_currentSpeed);
      
      // 只在速度变化超过1km/h时记录日志，避免过多消息
      if (speedChange.abs() > 1.0) {
        _addToHistory('设备', '速度更新: ${_currentSpeed.toStringAsFixed(1)}km/h', 'status');
      }
    });
  }
  
  /// 发送自定义命令(用于测试异常情况)
  Future<Map<String, dynamic>?> sendCustomCommand({
    required int command,
    required int commandType,
    required List<int> data,
  }) async {
    if (!_connected) return null;
    
    await Future.delayed(Duration(milliseconds: _getRandomResponseDelay()));
    
    // 构造请求数据的十六进制表示
    final hexData = data.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(' ');
    _addToHistory('请求', '发送命令: 0x${command.toRadixString(16)}, 类型: 0x${commandType.toRadixString(16)}, 数据: $hexData', 'outgoing');
    
    // 85%概率成功响应
    final isSuccess = Random().nextDouble() < 0.85;
    
    // 构造响应数据
    final response = {
      'command': command,
      'commandType': isSuccess
          ? (commandType == BleProtocol.CMD_READ 
              ? BleProtocol.CMD_READ_SUCCESS 
              : BleProtocol.CMD_WRITE_SUCCESS)
          : BleProtocol.CMD_ERROR,
      'data': isSuccess ? data : [0xFF], // 失败时返回错误代码
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    if (isSuccess) {
      _addToHistory('响应', '命令执行成功，响应数据: ${response['data']}', 'incoming');
    } else {
      _addToHistory('错误', '命令执行失败，错误代码: 0xFF', 'error');
    }
    
    return response;
  }
  
  /// 发送消息接口实现
  @override
  Future<bool> sendMessage(String message) async {
    if (!_connected) return false;
    
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
    
    // 构建16进制报文字符串
    final hexString = frame.map((byte) => '0x${byte.toRadixString(16).padLeft(2, '0')}').join(' ');
    
    // 添加到消息历史
    _addToHistory('发送', message, 'outgoing');
    _addToHistory('帧', hexString, 'frame');
    
    print('发送消息: $message');
    print('原始16进制报文: $hexString');
    
    await Future.delayed(Duration(milliseconds: _getRandomResponseDelay()));
    
    // 90%概率收到回复
    final willReply = Random().nextDouble() < 0.9;
    
    if (willReply) {
      // 模拟设备回复
      final replies = [
        '收到',
        '已执行',
        '成功',
        '有效',
        '正常',
      ];
      final reply = replies[Random().nextInt(replies.length)];
      
      // 将回复转换为UTF-16编码的字节数组
      List<int> replyData = [];
      for (int i = 0; i < reply.length; i++) {
        int charCode = reply.codeUnitAt(i);
        replyData.add((charCode >> 8) & 0xFF);  // 高字节
        replyData.add(charCode & 0xFF);         // 低字节
      }
      
      // 构建回复消息帧
      List<int> replyFrame = [];
      replyFrame.addAll([0x5A, 0xA5]);                   // 帧头
      replyFrame.add(replyData.length);                 // 数据长度
      replyFrame.addAll([0xFF, 0x12, 0x01]);           // 命令类型、命令、参数个数
      replyFrame.add(0x00);                            // 序号(非Log消息固定为0x00)
      replyFrame.addAll(replyData);                    // 数据
      replyFrame.add(0x3C);                            // 帧尾
      
      // 计算CRC
      int replyCrc = _calculateCRC16(replyFrame);
      replyFrame.add((replyCrc >> 8) & 0xFF);          // CRC高字节
      replyFrame.add(replyCrc & 0xFF);                 // CRC低字节
      
      // 构建回复的16进制报文字符串
      final replyHexString = replyFrame.map((byte) => '0x${byte.toRadixString(16).padLeft(2, '0')}').join(' ');
      
      // 添加到消息历史
      _addToHistory('接收', reply, 'incoming');
      _addToHistory('帧', replyHexString, 'frame');
      
      print('收到回复: $reply');
      print('原始16进制报文: $replyHexString');
    } else {
      // 创建错误响应帧
      List<int> errorFrame = [];
      errorFrame.addAll([0x5A, 0xA5, 0x01, 0xFF, 0x22, 0x01, 0x00, 0xFF, 0x3C]);
      
      // 计算CRC
      int errorCrc = _calculateCRC16(errorFrame);
      errorFrame.add((errorCrc >> 8) & 0xFF);
      errorFrame.add(errorCrc & 0xFF);
      
      final errorHexString = errorFrame.map((byte) => '0x${byte.toRadixString(16).padLeft(2, '0')}').join(' ');
      
      _addToHistory('错误', '设备未响应', 'error');
      _addToHistory('帧', errorHexString, 'frame');
      
      print('设备未响应');
      print('原始16进制报文: $errorHexString');
    }
    
    return willReply;
  }
  
  /// 监听消息接口实现
  @override
  Stream<String>? subscribeToMessages() {
    if (!_connected) return null;
    
    // 创建一个控制器，用于发送消息
    final controller = StreamController<String>.broadcast();
    
    // 创建一个监听器，监听_messageHistory变化
    // 当有新的'incoming'类型消息时，将其发送到流中
    Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!_connected) {
        timer.cancel();
        controller.close();
        return;
      }
      
      // 查找最近的一条incoming消息
      final recentMessages = List.from(_messageHistory.reversed);
      for (final msg in recentMessages) {
        if (msg['type'] == 'incoming' && 
            msg['timestamp'] > DateTime.now().millisecondsSinceEpoch - 500) {
          controller.add(msg['message']);
          break;
        }
      }
    });
    
    return controller.stream;
  }
  
  /// 模拟设备连接中断
  void simulateDisconnect() {
    if (_connected) {
      _connected = false;
      
      // 创建简化的连接断开事件帧
      _addToHistory('错误', '设备连接意外断开', 'error');
      _addToHistory('帧', '0x5AA5 0x01 0xFF 0xFF 0x01 0xEE 0x3C', 'frame');
      
      print('模拟设备连接中断');
    }
  }
  
  /// 模拟设备电量急剧下降
  void simulateBatteryDrain() {
    if (_connected) {
      _currentBattery = (_currentBattery - 15).clamp(0, 100);
      _batteryStreamController.add(_currentBattery);
      
      // 创建简化的电量变化事件帧
      final batteryByte = _currentBattery & 0xFF; // 确保是单字节
      _addToHistory('警告', '电池电量急剧下降：${_currentBattery}%', 'warning');
      _addToHistory('帧', '0x5AA5 0x01 0x01 0x11 0x01 0x${batteryByte.toRadixString(16).padLeft(2, '0')} 0x3C', 'frame');
      
      print('模拟电量急剧下降，当前电量: $_currentBattery%');
    }
  }
  
  /// 模拟设备突然加速
  void simulateSuddenAcceleration() {
    if (_connected && !_isLocked) {
      _currentSpeed = (_currentSpeed + 5).clamp(0, 25);
      _speedStreamController.add(_currentSpeed);
      
      // 创建简化的速度变化事件帧
      final speedByte = _currentSpeed.toInt() & 0xFF; // 确保是单字节
      _addToHistory('警告', '设备突然加速：${_currentSpeed.toStringAsFixed(1)}km/h', 'warning');
      _addToHistory('帧', '0x5AA5 0x01 0x00 0x11 0x01 0x${speedByte.toRadixString(16).padLeft(2, '0')} 0x3C', 'frame');
      
      print('模拟突然加速，当前速度: $_currentSpeed km/h');
    }
  }
  
  /// 模拟收到设备主动发送的消息
  void simulateIncomingMessage() {
    if (!_connected) return;
    
    final messages = [
      '温度:42°C',
      '电池:96%',
      '里程:15km',
      '气压正常',
      '自检完成',
    ];
    
    final message = messages[Random().nextInt(messages.length)];
    
    // 将消息转换为UTF-16编码的字节数组
    List<int> data = [];
    for (int i = 0; i < message.length; i++) {
      int charCode = message.codeUnitAt(i);
      data.add((charCode >> 8) & 0xFF);  // 高字节
      data.add(charCode & 0xFF);         // 低字节
    }
    
    // 构建消息帧
    List<int> frame = [];
    frame.addAll([0x5A, 0xA5]);                   // 帧头
    frame.add(data.length);                       // 数据长度
    frame.addAll([0xFF, 0x02, 0x01]);            // 命令类型、命令、参数个数
    frame.add(0x00);                             // 序号(非Log消息固定为0x00)
    frame.addAll(data);                          // 数据
    frame.add(0x3C);                             // 帧尾
    
    // 计算CRC
    int crc = _calculateCRC16(frame);
    frame.add((crc >> 8) & 0xFF);               // CRC高字节
    frame.add(crc & 0xFF);                      // CRC低字节
    
    // 构建16进制报文字符串
    final hexString = frame.map((byte) => '0x${byte.toRadixString(16).padLeft(2, '0')}').join(' ');
    
    // 添加到消息历史
    _addToHistory('设备', message, 'status');
    _addToHistory('帧', hexString, 'frame');
    
    // 触发消息流
    _messageStreamController.add(message);
    
    print('模拟设备发送消息: $message');
    print('原始16进制报文: $hexString');
  }
  
  /// 生成随机响应延迟时间
  int _getRandomResponseDelay() {
    return _minResponseDelay + Random().nextInt(_maxResponseDelay - _minResponseDelay);
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
  }
  
  /// 清理消息历史
  void clearHistory() {
    _messageHistory.clear();
    _addToHistory('系统', '消息历史已清除', 'info');
  }
  
  /// 清理资源
  void dispose() {
    _speedStreamController.close();
    _batteryStreamController.close();
    _messageStreamController.close();
  }
}

/// 模拟蓝牙设备
class MockBluetoothDevice implements BluetoothDevice {
  final String name;
  final DeviceIdentifier remoteId;
  
  MockBluetoothDevice(this.name, String id)
      : remoteId = DeviceIdentifier(id);
  
  @override
  String get platformName => name;
  
  @override
  String toString() => 'MockBluetoothDevice{name: $name, id: $remoteId}';
  
  // 实现接口必要的方法，但不会被使用
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}