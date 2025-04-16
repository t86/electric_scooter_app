import 'dart:async';
import 'package:flutter/material.dart';
import '../services/ble_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({Key? key}) : super(key: key);

  @override
  _DevicePageState createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  final BleService _bleService = BleService();
  StreamSubscription? _speedSubscription;
  StreamSubscription? _batterySubscription;
  
  double _speed = 0.0;
  int _battery = 100;
  bool _isLocked = true;
  bool _isConnected = false;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    _speedSubscription?.cancel();
    _batterySubscription?.cancel();
    _bleService.disconnect();
    super.dispose();
  }

  void _startScan() {
    setState(() => _isScanning = true);
    
    _bleService.scanForDevices().listen(
      (device) async {
        setState(() => _isScanning = false);
        
        final connected = await _bleService.connectToDevice(device);
        if (connected) {
          setState(() => _isConnected = true);
          _setupSubscriptions();
        }
      },
      onDone: () => setState(() => _isScanning = false),
    );
  }

  void _setupSubscriptions() {
    // 订阅速度更新
    final speedStream = _bleService.subscribeToSpeed();
    if (speedStream != null) {
      _speedSubscription = speedStream.listen((speed) {
        setState(() => _speed = speed);
      });
    }

    // 订阅电量更新
    final batteryStream = _bleService.subscribeToBattery();
    if (batteryStream != null) {
      _batterySubscription = batteryStream.listen((battery) {
        setState(() => _battery = battery);
      });
    }

    // 初始读取数据
    _updateData();
  }

  Future<void> _updateData() async {
    final speed = await _bleService.readSpeed();
    if (speed != null) {
      setState(() => _speed = speed);
    }

    final battery = await _bleService.readBattery();
    if (battery != null) {
      setState(() => _battery = battery);
    }
  }

  Future<void> _toggleLock() async {
    final success = await _bleService.setLockState(!_isLocked);
    if (success) {
      setState(() => _isLocked = !_isLocked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('电动滑板车'),
        actions: [
          IconButton(
            icon: Icon(_isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled),
            onPressed: _isConnected ? null : _startScan,
          ),
        ],
      ),
      body: _isScanning
          ? const Center(child: CircularProgressIndicator())
          : _isConnected
              ? _buildConnectedView()
              : _buildDisconnectedView(),
    );
  }

  Widget _buildConnectedView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    '${_speed.toStringAsFixed(1)} km/h',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Text('当前速度'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    '$_battery%',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Text('电池电量'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _toggleLock,
            icon: Icon(_isLocked ? Icons.lock : Icons.lock_open),
            label: Text(_isLocked ? '解锁' : '锁定'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisconnectedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('未连接到设备'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _startScan,
            icon: const Icon(Icons.bluetooth_searching),
            label: const Text('扫描设备'),
          ),
        ],
      ),
    );
  }
} 