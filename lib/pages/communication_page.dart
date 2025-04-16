import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../services/ble_service_provider.dart';
import '../services/ble_service_interface.dart';
import '../services/mock_ble_service.dart';

class CommunicationPage extends StatefulWidget {
  const CommunicationPage({Key? key}) : super(key: key);

  @override
  _CommunicationPageState createState() => _CommunicationPageState();
}

class _CommunicationPageState extends State<CommunicationPage> {
  final BleServiceProvider _serviceProvider = BleServiceProvider();
  late BleServiceInterface _bleService;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<dynamic> _scanResults = [];
  
  // 消息历史和计时器
  List<Map<String, dynamic>> _messageHistory = [];
  Timer? _messageHistoryTimer;
  Timer? _autoMessageTimer;

  bool _isConnected = false;
  bool _isScanning = false;
  StreamSubscription? _scanSubscription;
  bool _useMockService = true;

  @override
  void initState() {
    super.initState();
    _bleService = _serviceProvider.service;
    _useMockService = _serviceProvider.serviceType == BleServiceType.mock;
    _checkConnectionStatus();
    
    // 定期更新消息历史（仅在模拟模式下）
    _startMessageHistoryTimer();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _scanSubscription?.cancel();
    _messageHistoryTimer?.cancel();
    _autoMessageTimer?.cancel();
    super.dispose();
  }
  
  // 开始消息历史定时更新
  void _startMessageHistoryTimer() {
    _messageHistoryTimer?.cancel();
    
    // 每0.5秒更新一次消息历史
    _messageHistoryTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_useMockService && _isConnected) {
        final mockService = _serviceProvider.getMockService();
        if (mockService != null) {
          setState(() {
            _messageHistory = mockService.messageHistory;
          });
          
          // 自动滚动到底部
          if (_scrollController.hasClients && _messageHistory.isNotEmpty) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        }
      }
    });
    
    // 随机时间自动发送设备消息
    _startAutoMessageTimer();
  }
  
  // 随机时间自动发送设备消息
  void _startAutoMessageTimer() {
    _autoMessageTimer?.cancel();
    
    if (_useMockService) {
      _autoMessageTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
        if (_isConnected) {
          final mockService = _serviceProvider.getMockService();
          if (mockService != null && Random().nextDouble() < 0.7) {
            // 使用通用接口发送较短的随机系统信息
            final messages = [
              '控制正常',
              '自检完成',
              '状态良好',
              '信号稳定',
              '连接正常',
            ];
            final message = messages[Random().nextInt(messages.length)];
            mockService.sendMessage(message);
          }
        }
      });
    }
  }

  Future<void> _checkConnectionStatus() async {
    setState(() {
      _isConnected = _bleService.isConnected;
    });
  }

  void _startScan() {
    setState(() {
      _isScanning = true;
      _scanResults.clear();
    });

    try {
      _addMessage("系统", "开始扫描设备...");
      
      if (_useMockService) {
        // 使用模拟服务
        _scanSubscription = (_bleService.scanForDevices() as Stream<Map<String, dynamic>>).listen(
          (device) {
            setState(() {
              _scanResults.add(device);
            });
            _addMessage("系统", "发现设备: ${device['name']}");
          },
          onDone: () {
            setState(() => _isScanning = false);
            _addMessage("系统", "扫描完成");
          },
          onError: (error) {
            _addMessage("系统", "扫描错误: $error");
            setState(() => _isScanning = false);
          }
        );
      } else {
        // 使用真实蓝牙服务
        _scanSubscription = (_bleService.scanForDevices() as Stream<BluetoothDevice>).listen(
          (device) {
            setState(() {
              _scanResults.add(device);
            });
            _addMessage("系统", "发现设备: ${device.platformName}");
          },
          onDone: () {
            setState(() => _isScanning = false);
            _addMessage("系统", "扫描完成");
          },
          onError: (error) {
            _addMessage("系统", "扫描错误: $error");
            setState(() => _isScanning = false);
          }
        );
      }
      
      // 4秒后自动停止扫描
      Future.delayed(const Duration(seconds: 4), () {
        if (_isScanning) {
          _stopScan();
        }
      });
    } catch (e) {
      print('扫描错误: $e');
      setState(() => _isScanning = false);
      _showError('蓝牙扫描失败: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _stopScan() {
    _scanSubscription?.cancel();
    setState(() => _isScanning = false);
    _addMessage("系统", "停止扫描");
  }

  Future<void> _connectToDevice(dynamic device) async {
    try {
      setState(() => _isScanning = true);
      _addMessage("系统", "正在连接设备...");
      
      final connected = await _bleService.connectToDevice(device);
      
      if (connected) {
        setState(() {
          _isConnected = true;
          if (_useMockService) {
            _addMessage("系统", "已连接到模拟设备: ${device['name']}");
          } else {
            _addMessage("系统", "已连接到设备: ${(device as BluetoothDevice).platformName}");
          }
        });
        
        // 设置监听器
        _setupListeners();
        
        // 如果是模拟模式，启动自动消息
        if (_useMockService) {
          _startAutoMessageTimer();
        }
      } else {
        if (_useMockService) {
          _addMessage("系统", "连接失败: ${device['name']}");
        } else {
          _addMessage("系统", "连接失败: ${(device as BluetoothDevice).platformName}");
        }
      }
    } catch (e) {
      _addMessage("系统", "连接错误: $e");
    } finally {
      setState(() => _isScanning = false);
    }
  }
  
  void _setupListeners() {
    // 监听速度变化
    _bleService.subscribeToSpeed()?.listen((speed) {
      _addMessage("速度", "$speed km/h");
    });
    
    // 监听电池变化
    _bleService.subscribeToBattery()?.listen((battery) {
      _addMessage("电池", "$battery%");
    });
    
    // 监听设备消息（仅在真实蓝牙模式下）
    if (!_useMockService) {
      _bleService.subscribeToMessages()?.listen((message) {
        if (message.isNotEmpty) {
          _addMessage("接收", message);
        }
      });
    }
  }
  
  Future<void> _disconnect() async {
    await _bleService.disconnect();
    setState(() {
      _isConnected = false;
    });
    _addMessage("系统", "已断开连接");
    
    // 停止自动消息
    _autoMessageTimer?.cancel();
  }

  void _addMessage(String sender, String message) {
    if (_useMockService) {
      // 模拟模式下，消息直接添加到模拟服务的历史记录中
      final mockService = _serviceProvider.getMockService();
      if (mockService != null) {
        // 这里不需要做任何事情，因为我们已经通过计时器定期获取消息历史
      }
    } else {
      // 实际模式下，将消息添加到本地列表
      setState(() {
        _messageHistory.add({
          'sender': sender,
          'message': message,
          'type': 'info',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      });
    }
  }

  Future<void> _sendMessage() async {
    if (!_isConnected || _messageController.text.isEmpty) return;

    final message = _messageController.text;
    _messageController.clear();

    // 发送消息
    final success = await _bleService.sendMessage(message);
    
    // 在非模拟模式下，手动添加消息到历史记录
    if (!_useMockService) {
      _addMessage("发送", message);
      
      if (!success) {
        _addMessage("错误", "消息发送失败");
      }
    }
  }
  
  // 切换服务类型
  void _toggleServiceType() {
    if (_isConnected) {
      _disconnect();
    }
    
    setState(() {
      _useMockService = !_useMockService;
      _serviceProvider.switchServiceType(
        _useMockService ? BleServiceType.mock : BleServiceType.real
      );
      _bleService = _serviceProvider.service;
      
      // 清空消息历史
      _messageHistory.clear();
    });
    
    _addMessage("系统", "切换到${_useMockService ? '模拟' : '真实'}蓝牙服务");
    
    // 更新定时器
    if (_useMockService) {
      _startMessageHistoryTimer();
    } else {
      _messageHistoryTimer?.cancel();
      _autoMessageTimer?.cancel();
    }
  }
  
  // 模拟事件(仅在模拟模式下有效)
  void _simulateEvents() {
    if (!_useMockService || !_isConnected) return;
    
    final mockService = _serviceProvider.getMockService();
    if (mockService != null) {
      showDialog(
        context: context,
        builder: (context) => SimpleDialog(
          title: const Text('选择模拟事件'),
          children: [
            SimpleDialogOption(
              onPressed: () {
                mockService.simulateBatteryDrain();
                Navigator.pop(context);
              },
              child: const Text('电池电量急剧下降'),
            ),
            SimpleDialogOption(
              onPressed: () {
                mockService.simulateSuddenAcceleration();
                Navigator.pop(context);
              },
              child: const Text('设备突然加速'),
            ),
            SimpleDialogOption(
              onPressed: () {
                mockService.simulateDisconnect();
                setState(() => _isConnected = false);
                Navigator.pop(context);
              },
              child: const Text('蓝牙连接断开'),
            ),
            SimpleDialogOption(
              onPressed: () {
                mockService.simulateIncomingMessage();
                Navigator.pop(context);
              },
              child: const Text('设备主动发送消息'),
            ),
            SimpleDialogOption(
              onPressed: () {
                _showSendCustomMessageDialog(mockService);
                Navigator.pop(context);
              },
              child: const Text('发送自定义消息'),
            ),
          ],
        ),
      );
    }
  }
  
  // 显示发送自定义消息的对话框
  void _showSendCustomMessageDialog(MockBleService mockService) {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('发送自定义消息'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '输入要发送的消息',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final message = controller.text.trim();
              if (message.isNotEmpty) {
                mockService.sendMessage(message);
              }
              Navigator.pop(context);
            },
            child: const Text('发送'),
          ),
        ],
      ),
    ).then((_) => controller.dispose());
  }
  
  // 读取设备数据
  void _readDeviceData() {
    if (!_isConnected) return;
    
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('读取设备数据'),
        children: [
          SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(context);
              final speed = await _bleService.readSpeed();
              if (speed != null) {
                _addMessage("系统", "读取速度成功: $speed km/h");
              } else {
                _addMessage("错误", "读取速度失败");
              }
            },
            child: const Text('读取当前速度'),
          ),
          SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(context);
              final battery = await _bleService.readBattery();
              if (battery != null) {
                _addMessage("系统", "读取电量成功: $battery%");
              } else {
                _addMessage("错误", "读取电量失败");
              }
            },
            child: const Text('读取电池电量'),
          ),
        ],
      ),
    );
  }
  
  // 设置锁定状态
  void _setLockState(bool locked) async {
    if (!_isConnected) return;
    
    final success = await _bleService.setLockState(locked);
    if (success) {
      _addMessage("系统", "${locked ? '锁定' : '解锁'}设备成功");
    } else {
      _addMessage("错误", "${locked ? '锁定' : '解锁'}设备失败");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('蓝牙通信'),
        actions: [
          // 切换服务类型按钮
          IconButton(
            icon: Icon(_useMockService ? Icons.devices : Icons.bluetooth),
            onPressed: _toggleServiceType,
            tooltip: _useMockService ? "切换到真实蓝牙" : "切换到模拟模式",
          ),
          // 扫描/停止扫描按钮
          IconButton(
            icon: Icon(_isScanning ? Icons.stop : Icons.search),
            onPressed: _isScanning ? _stopScan : _startScan,
            tooltip: _isScanning ? "停止扫描" : "开始扫描",
          ),
        ],
      ),
      body: Column(
        children: [
          // 状态栏
          Container(
            color: Colors.grey.shade200,
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              children: [
                Icon(
                  _isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                  color: _isConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  _isConnected ? "已连接" : "未连接",
                  style: TextStyle(
                    color: _isConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  _useMockService ? "模拟模式" : "真实模式",
                  style: TextStyle(
                    color: _useMockService ? Colors.orange : Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          if (_scanResults.isNotEmpty && !_isConnected)
            Expanded(
              flex: 1,
              child: ListView.builder(
                itemCount: _scanResults.length,
                itemBuilder: (context, index) {
                  final device = _scanResults[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    child: ListTile(
                      leading: const Icon(Icons.bluetooth, color: Colors.blue),
                      title: Text(
                        _useMockService 
                            ? device['name'] 
                            : (device as BluetoothDevice).platformName
                      ),
                      subtitle: Text(
                        _useMockService 
                            ? "信号强度: ${device['rssi']} dBm" 
                            : "ID: ${(device as BluetoothDevice).remoteId}"
                      ),
                      trailing: ElevatedButton(
                        child: const Text("连接"),
                        onPressed: () => _connectToDevice(device),
                      ),
                    ),
                  );
                },
              ),
            ),
          
          // 消息历史记录
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8.0),
              ),
              margin: const EdgeInsets.all(8.0),
              child: _messageHistory.isEmpty 
              ? const Center(
                  child: Text(
                    '无消息记录',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: _messageHistory.length,
                  itemBuilder: (context, index) {
                    final message = _messageHistory[index];
                    
                    // 如果是帧数据，使用特殊格式显示
                    if (message['type'] == 'frame') {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(width: 16), // 缩进
                            Expanded(
                              child: Text(
                                '${message['message']}',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontFamily: 'monospace',
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '[${message['sender']}]',
                            style: TextStyle(
                              color: _getMessageSenderColor(message['type'] ?? 'info'),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              message['message'] ?? '',
                              style: TextStyle(
                                color: _getMessageColor(message['type'] ?? 'info'),
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ),
          ),
          
          // 控制按钮区域
          if (_isConnected)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                alignment: WrapAlignment.spaceEvenly,
                children: [
                  if (_useMockService)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.bolt),
                      label: const Text("模拟事件"),
                      onPressed: _simulateEvents,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                    ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.read_more),
                    label: const Text("读取数据"),
                    onPressed: _readDeviceData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.lock_open),
                    label: const Text("解锁设备"),
                    onPressed: () => _setLockState(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.lock),
                    label: const Text("锁定设备"),
                    onPressed: () => _setLockState(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          
          // 消息输入区域
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: '输入消息',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    enabled: _isConnected,
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isConnected ? _sendMessage : null,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
            
          // 断开连接按钮
          if (_isConnected)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.bluetooth_disabled),
                label: const Text("断开连接"),
                onPressed: _disconnect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 40),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Color _getMessageColor(String type) {
    switch (type) {
      case 'error': return Colors.red;
      case 'warning': return Colors.orange;
      case 'status': return Colors.lightBlue;
      case 'incoming': return Colors.green;
      case 'outgoing': return Colors.cyan;
      case 'frame': return Colors.grey[500]!;
      default: return Colors.white;
    }
  }
  
  Color _getMessageSenderColor(String type) {
    switch (type) {
      case 'error': return Colors.red;
      case 'warning': return Colors.orange;
      case 'status': return Colors.yellow;
      case 'incoming': return Colors.green;
      case 'outgoing': return Colors.cyan;
      case 'frame': return Colors.grey[700]!;
      default: return Colors.white;
    }
  }
} 