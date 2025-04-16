import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../shared/providers/vehicle_provider.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  // 模拟数据
  final Random _random = Random();
  double _power = 0;
  double _speed = 0;
  double _batteryCapacity = 0;
  double _controllerTemp = 0;
  double _motorTemp = 0;
  double _lineVoltage = 0;
  double _current = 0;
  double _throttle = 0;
  
  @override
  void initState() {
    super.initState();
    
    // 创建动画控制器
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    
    // 创建动画曲线
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    // 初始化模拟数据
    _updateValues();
    
    // 启动动画
    _animationController.forward();
    
    // 每3秒更新一次模拟数据
    Future.delayed(const Duration(seconds: 3), () {
      _startPeriodicUpdates();
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  // 模拟数据定期更新
  void _startPeriodicUpdates() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return false;
      
      setState(() {
        _updateValues();
      });
      
      _animationController.reset();
      _animationController.forward();
      
      return true;
    });
  }
  
  // 更新模拟数据
  void _updateValues() {
    _power = _random.nextDouble() * 20.0;  // 0-20kW
    _speed = _random.nextDouble() * 120.0; // 0-120km/h
    _batteryCapacity = 30.0 + _random.nextDouble() * 70.0; // 30-100%
    _controllerTemp = 30.0 + _random.nextDouble() * 70.0; // 30-100°C
    _motorTemp = 30.0 + _random.nextDouble() * 70.0; // 30-100°C
    _lineVoltage = 100.0 + _random.nextDouble() * 44.0; // 100-144V
    _current = _random.nextDouble() * 100.0; // 0-100A
    _throttle = _random.nextDouble() * 100.0; // 0-100%
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildStatusBar(),
            
            Expanded(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  // 平滑动画过渡到新值
                  final powerValue = _power * _animation.value;
                  final speedValue = _speed * _animation.value;
                  final batteryValue = _batteryCapacity;
                  final ctrlTempValue = _controllerTemp * _animation.value;
                  final motorTempValue = _motorTemp * _animation.value;
                  final voltageValue = _lineVoltage * _animation.value;
                  final currentValue = _current * _animation.value;
                  final throttleValue = _throttle * _animation.value;
                
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 主仪表盘
                        Row(
                          children: [
                            Expanded(
                              child: _buildGauge(
                                "功率", 
                                powerValue.round().toString(), 
                                "kW",
                                powerValue / 20, 
                                Colors.blue,
                                icon: Icons.bolt,
                              ),
                            ),
                            Expanded(
                              child: _buildGauge(
                                "速度", 
                                speedValue.round().toString(), 
                                "km/h",
                                speedValue / 120, 
                                Colors.green,
                                icon: Icons.speed,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // 电池和温度仪表
                        Row(
                          children: [
                            Expanded(
                              child: _buildLinearGauge(
                                "电池容量", 
                                batteryValue.round().toString(), 
                                "%",
                                batteryValue / 100, 
                                _getBatteryColor(batteryValue),
                                icon: Icons.battery_charging_full,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // 温度仪表
                        Row(
                          children: [
                            Expanded(
                              child: _buildLinearGauge(
                                "控制器温度", 
                                ctrlTempValue.round().toString(), 
                                "°C",
                                ctrlTempValue / 100, 
                                _getTemperatureColor(ctrlTempValue),
                                icon: Icons.thermostat,
                              ),
                            ),
                            Expanded(
                              child: _buildLinearGauge(
                                "电机温度", 
                                motorTempValue.round().toString(), 
                                "°C",
                                motorTempValue / 100, 
                                _getTemperatureColor(motorTempValue),
                                icon: Icons.whatshot,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // 参数标题
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.dashboard_customize, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                "实时参数",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.red, width: 1),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.warning_amber, size: 14, color: Colors.red),
                                    SizedBox(width: 4),
                                    Text(
                                      "未连接",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // 参数列表
                        _buildParameterTile("线电压", "${voltageValue.toStringAsFixed(1)}V", Icons.electrical_services),
                        _buildParameterTile("电流", "${currentValue.toStringAsFixed(1)}A", Icons.bolt),
                        _buildParameterTile("油门开度", "${throttleValue.toStringAsFixed(1)}%", Icons.speed),
                        _buildParameterTile("A相电流", "0A", Icons.sync_alt),
                        _buildParameterTile("C相电流", "0A", Icons.sync_alt),
                        
                        const SizedBox(height: 24),
                        
                        // 底部按钮区域
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildActionButton("退出跟随", Icons.exit_to_app),
                            _buildActionButton("测试角度", Icons.architecture),
                            _buildActionButton("自动学习", Icons.auto_awesome),
                            _buildActionButton("退出学习", Icons.logout),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // 底部信息
                        Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Text(
                            'RcvFrames:0',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 构建状态栏
  Widget _buildStatusBar() {
    return Consumer<VehicleProvider>(
      builder: (context, provider, child) {
        final vehicle = provider.selectedVehicle;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                "控制器状态: ${vehicle != null ? vehicle.status : "未知"}",
                style: const TextStyle(fontSize: 14),
              ),
              const Spacer(),
              Text(
                "最后更新: ${vehicle != null ? vehicle.lastUsedFriendly : "未知"}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // 构建圆形仪表盘
  Widget _buildGauge(String title, String value, String unit, double progress, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                child: CustomPaint(
                  painter: GaugePainter(
                    progress: progress,
                    color: color,
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
              ),
              Column(
                children: [
                  if (icon != null) Icon(icon, color: color.withOpacity(0.8)),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    unit,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 构建线性仪表盘
  Widget _buildLinearGauge(String title, String value, String unit, double progress, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                "$value$unit",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.grey.shade200,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: (progress * 100).round(),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: color,
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.7),
                          color,
                        ],
                      ),
                    ),
                  ),
                ),
                if (progress < 1)
                  Expanded(
                    flex: ((1 - progress) * 100).round(),
                    child: const SizedBox(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建参数项
  Widget _buildParameterTile(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建操作按钮
  Widget _buildActionButton(String title, IconData icon) {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title 功能尚未实现'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade300,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
  
  // 获取电池颜色
  Color _getBatteryColor(double value) {
    if (value < 20) {
      return Colors.red;
    } else if (value < 40) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
  
  // 获取温度颜色
  Color _getTemperatureColor(double value) {
    if (value > 80) {
      return Colors.red;
    } else if (value > 60) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}

// 仪表盘绘制器
class GaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  
  GaugePainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
      
    final foregroundPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    
    // 绘制背景圆弧
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 8),
      pi * 0.75,
      pi * 1.5,
      false,
      backgroundPaint,
    );
    
    // 绘制前景圆弧
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 8),
      pi * 0.75,
      pi * 1.5 * progress,
      false,
      foregroundPaint,
    );
    
    // 绘制刻度
    final tickPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
      
    for (int i = 0; i <= 10; i++) {
      final angle = pi * 0.75 + (pi * 1.5 / 10 * i);
      final outerPoint = Offset(
        center.dx + (radius - 2) * cos(angle),
        center.dy + (radius - 2) * sin(angle),
      );
      final innerPoint = Offset(
        center.dx + (radius - 14) * cos(angle),
        center.dy + (radius - 14) * sin(angle),
      );
      
      canvas.drawLine(innerPoint, outerPoint, tickPaint);
    }
  }
  
  @override
  bool shouldRepaint(covariant GaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.color != color ||
           oldDelegate.backgroundColor != backgroundColor;
  }
} 