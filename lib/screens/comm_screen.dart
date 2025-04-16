import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CommScreen extends StatefulWidget {
  const CommScreen({super.key});

  @override
  State<CommScreen> createState() => _CommScreenState();
}

class _CommScreenState extends State<CommScreen> with SingleTickerProviderStateMixin {
  bool _isScanning = false;
  final List<_BluetoothDevice> _devices = [
    _BluetoothDevice(
      name: 'FarDriver Controller',
      address: '00:11:22:33:44:55',
      rssi: -65,
      isConnected: false,
    ),
  ];
  
  late TabController _tabController;
  final LatLng _currentPosition = LatLng(39.9042, 116.4074); // 默认位置：北京
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 标签页切换
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.bluetooth),
                text: '设备连接',
              ),
              Tab(
                icon: Icon(Icons.map),
                text: '位置地图',
              ),
            ],
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
          ),
          
          // 标签页内容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDeviceTab(),
                _buildMapTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDeviceTab() {
    return Column(
      children: [
        // 扫描按钮区域
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _toggleScan,
                  icon: Icon(_isScanning ? Icons.stop : Icons.search),
                  label: Text(_isScanning ? '停止扫描' : '扫描设备'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isScanning
                        ? Colors.red.shade100
                        : Theme.of(context).primaryColor,
                    foregroundColor: _isScanning
                        ? Colors.red.shade900
                        : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // 设备列表标题
        Container(
          color: Colors.grey.shade200,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Row(
            children: [
              const Text(
                '可用设备',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (_isScanning)
                Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.only(right: 8),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              Text(
                '${_devices.length}个设备',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        
        // 设备列表
        Expanded(
          child: _devices.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: _devices.length,
                  itemBuilder: (context, index) {
                    final device = _devices[index];
                    return _buildDeviceItem(device);
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildMapTab() {
    return Column(
      children: [
        // 地图状态信息
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade100,
          child: Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '当前位置',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '经度: ${_currentPosition.longitude.toStringAsFixed(4)}, 纬度: ${_currentPosition.latitude.toStringAsFixed(4)}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _refreshLocation,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('刷新'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // 地图区域
        Expanded(
          child: FlutterMap(
            options: MapOptions(
              center: _currentPosition,
              zoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.fardriver.escooter',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 40.0,
                    height: 40.0,
                    point: _currentPosition,
                    builder: (ctx) => const Icon(
                      Icons.electric_moped,
                      color: Colors.red,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.bluetooth_disabled,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            '未找到设备',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isScanning ? '正在扫描中...' : '点击扫描按钮开始搜索',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceItem(_BluetoothDevice device) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: device.isConnected
              ? Colors.green.withOpacity(0.1)
              : Colors.blue.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.bluetooth,
          color: device.isConnected ? Colors.green : Colors.blue,
        ),
      ),
      title: Text(device.name),
      subtitle: Text(device.address),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 信号强度指示器
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${device.rssi} dBm',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                _buildSignalStrength(device.rssi),
              ],
            ),
          ),
          
          // 连接按钮
          ElevatedButton(
            onPressed: () => _connectToDevice(device),
            style: ElevatedButton.styleFrom(
              backgroundColor: device.isConnected
                  ? Colors.red.shade50
                  : Colors.blue.shade50,
              foregroundColor: device.isConnected
                  ? Colors.red
                  : Colors.blue,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              minimumSize: const Size(80, 36),
            ),
            child: Text(
              device.isConnected ? '断开' : '连接',
            ),
          ),
        ],
      ),
      onTap: () => _showDeviceDetails(device),
    );
  }

  Widget _buildSignalStrength(int rssi) {
    // 计算信号强度，范围从 -100 到 -40
    final strength = ((rssi + 100) / 60).clamp(0.0, 1.0);
    final int bars = (strength * 4).ceil();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        return Container(
          width: 4,
          height: 6 + (index * 2),
          margin: const EdgeInsets.symmetric(horizontal: 1),
          color: index < bars ? Colors.blue : Colors.grey.shade300,
        );
      }),
    );
  }

  void _toggleScan() {
    setState(() {
      _isScanning = !_isScanning;
      
      // 在真实应用中，这里应该开始或停止蓝牙扫描
      if (!_isScanning) return;
      
      // 模拟扫描行为
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _isScanning) {
          setState(() {
            _isScanning = false;
            
            // 添加模拟设备
            if (_devices.isEmpty) {
              _devices.add(_BluetoothDevice(
                name: 'FarDriver Controller',
                address: '00:11:22:33:44:55',
                rssi: -65,
                isConnected: false,
              ));
            }
          });
        }
      });
    });
  }
  
  void _refreshLocation() {
    // 在真实应用中，这里应该获取实际位置
    // 模拟位置更新
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('位置已刷新'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _connectToDevice(_BluetoothDevice device) {
    setState(() {
      device.isConnected = !device.isConnected;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          device.isConnected
              ? '已连接到 ${device.name}'
              : '已断开与 ${device.name} 的连接',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDeviceDetails(_BluetoothDevice device) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildDeviceDetails(device),
    );
  }

  Widget _buildDeviceDetails(_BluetoothDevice device) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: device.isConnected
                      ? Colors.green.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bluetooth,
                  color: device.isConnected ? Colors.green : Colors.blue,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      device.address,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: device.isConnected
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  device.isConnected ? '已连接' : '未连接',
                  style: TextStyle(
                    color: device.isConnected ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            '设备信息',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildDetailItem('信号强度', '${device.rssi} dBm'),
          _buildDetailItem('设备类型', '电动车控制器'),
          _buildDetailItem('设备ID', '${device.address.substring(0, 8)}...'),
          _buildDetailItem('上次连接', '2023-06-23 15:30'),
          
          const SizedBox(height: 24),
          const Text(
            '可用服务',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: [
                _buildServiceItem('电池服务', '0x180F', true),
                _buildServiceItem('设备信息', '0x180A', true),
                _buildServiceItem('控制服务', '0xFFA0', true),
                _buildServiceItem('OTA更新', '0xFFC0', false),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _connectToDevice(device),
              style: ElevatedButton.styleFrom(
                backgroundColor: device.isConnected
                    ? Colors.red
                    : Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                device.isConnected ? '断开连接' : '连接设备',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label:',
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String name, String uuid, bool isAvailable) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isAvailable
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bluetooth_searching,
              color: isAvailable ? Colors.blue : Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  uuid,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          if (isAvailable)
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20,
            )
          else
            Icon(
              Icons.cancel,
              color: Colors.grey.shade400,
              size: 20,
            ),
        ],
      ),
    );
  }
}

class _BluetoothDevice {
  final String name;
  final String address;
  final int rssi;
  bool isConnected;

  _BluetoothDevice({
    required this.name,
    required this.address,
    required this.rssi,
    required this.isConnected,
  });
} 