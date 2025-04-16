import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../shared/providers/vehicle_provider.dart';

class VcuScreen extends StatefulWidget {
  const VcuScreen({super.key});

  @override
  State<VcuScreen> createState() => _VcuScreenState();
}

class _VcuScreenState extends State<VcuScreen> {
  bool _isVcuConnected = false;
  String _selectedChannel = "CH 1";
  
  // 模拟数据
  String _vcuModelType = "-----";
  String _vcuType = "-----";
  String _vcuSoc = "--%";
  int _batteryPercentage = 0;
  int _remainingDistance = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBatteryStatus(),
                    const SizedBox(height: 16),
                    _buildVcuInfo(),
                    const SizedBox(height: 16),
                    _buildVcuUpdateButton(),
                    const SizedBox(height: 16),
                    _buildActionButtons(),
                    const SizedBox(height: 16),
                    _buildSettings(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 头部区域
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 18, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "My FarDriver's Control System: ${_isVcuConnected ? 'VCU Connected' : 'No VCU Connected'}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _isVcuConnected ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 电池状态区域
  Widget _buildBatteryStatus() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "电池状态",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "$_batteryPercentage%",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Rest SOC",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _batteryPercentage / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getBatteryColor(_batteryPercentage),
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: Colors.grey.shade300,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "续航里程",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "$_remainingDistance",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Km",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Text(
                      "Rest Distance",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 16),
            child: Icon(
              Icons.bolt,
              size: 40,
              color: _getBatteryColor(_batteryPercentage),
            ),
          ),
        ],
      ),
    );
  }
  
  // VCU信息区域
  Widget _buildVcuInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow("VCU ModelType", _vcuModelType, Icons.memory),
          const Divider(),
          _buildInfoRow("VCU", _vcuType, Icons.developer_board),
          const Divider(),
          _buildInfoRow("VCU SOC", _vcuSoc, Icons.battery_full),
        ],
      ),
    );
  }
  
  // 单行信息
  Widget _buildInfoRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue, size: 16),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  // 操作按钮区域
  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton("远程开锁", Icons.lock_open, Colors.blue),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildActionButton("设防", Icons.shield, Colors.green),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildActionButton("坐桶开锁", Icons.electric_scooter, Colors.orange),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildActionButton("Switch CH", Icons.swap_horiz, Colors.purple, badge: _selectedChannel),
          ),
        ],
      ),
    );
  }
  
  // 单个操作按钮
  Widget _buildActionButton(String title, IconData icon, Color color, {String? badge}) {
    return InkWell(
      onTap: () {
        // 处理点击事件
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title 功能尚未实现'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
            if (badge != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  // 设置项列表
  Widget _buildSettings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingItem(
            "RatedVoltage", 
            "额定电压",
            Icons.electrical_services, 
            trailing: const Icon(Icons.chevron_right),
          ),
          const Divider(height: 1),
          _buildSettingItem(
            "SpeedLimit", 
            "限速开关状态",
            Icons.speed, 
            trailing: Switch(
              value: false,
              onChanged: (value) {},
            ),
          ),
          const Divider(height: 1),
          _buildSettingItem(
            "OverSpeedAlarm", 
            "超速报警状态",
            Icons.notifications_active, 
            trailing: Switch(
              value: false,
              onChanged: (value) {},
            ),
          ),
          const Divider(height: 1),
          _buildSettingItem(
            "AutoLock", 
            "AutoLock Delay 5-30s",
            Icons.lock_clock, 
            trailing: const Icon(Icons.chevron_right),
          ),
          const Divider(height: 1),
          _buildSettingItem(
            "Vibration Alarm", 
            "Vibration Alarm:On",
            Icons.vibration, 
            trailing: const Icon(Icons.chevron_right),
          ),
          const Divider(height: 1),
          _buildSettingItem(
            "Wheel Motion Alarm", 
            "Wheel motion alarm",
            Icons.warning, 
            trailing: Switch(
              value: false,
              onChanged: (value) {},
            ),
          ),
          const Divider(height: 1),
          _buildSettingItem(
            "Phone Key", 
            "Phone Key bluetooth sensor distance: 1",
            Icons.phone_android, 
            trailing: const Icon(Icons.chevron_right),
          ),
          const Divider(height: 1),
          _buildSettingItem(
            "Driving Record", 
            "Driving stage tracking record",
            Icons.book, 
            trailing: const Icon(Icons.chevron_right),
          ),
          const Divider(height: 1),
          _buildSettingItem(
            "Message", 
            "Messages of VCU and Server",
            Icons.message, 
            trailing: const Icon(Icons.chevron_right),
          ),
          const Divider(height: 1),
          _buildSettingItem(
            "Usermanual", 
            "User manual of fardriver controller",
            Icons.help_outline, 
            trailing: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
  
  // 单个设置项
  Widget _buildSettingItem(String title, String subtitle, IconData icon, {Widget? trailing}) {
    return InkWell(
      onTap: () {
        if (trailing is! Switch) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title 功能尚未实现'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade200,
              child: Icon(icon, size: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
  
  // 获取电池颜色
  Color _getBatteryColor(int percentage) {
    if (percentage <= 20) {
      return Colors.red;
    } else if (percentage <= 50) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
  
  // VCU更新按钮
  Widget _buildVcuUpdateButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton(
        onPressed: () {
          // 处理VCU更新
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('VCU更新功能尚未实现'),
              duration: Duration(seconds: 1),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text(
          'VCU Update',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
} 