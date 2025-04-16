import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class BatteryCard extends StatelessWidget {
  final int batteryLevel;

  const BatteryCard({
    super.key,
    required this.batteryLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.battery_charging_full,
                  color: _getBatteryColor(),
                ),
                const SizedBox(width: 8),
                Text(
                  '电池状态',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: CircularPercentIndicator(
                radius: 50.0,
                lineWidth: 10.0,
                percent: batteryLevel / 100,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$batteryLevel%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: _getBatteryColor(),
                      ),
                    ),
                    const Text(
                      '电量',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.grey.shade200,
                progressColor: _getBatteryColor(),
                circularStrokeCap: CircularStrokeCap.round,
                animation: true,
                animationDuration: 1000,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('状态'),
                Text(
                  _getBatteryStatus(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getBatteryColor(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('估计充电时间'),
                Text(
                  batteryLevel > 90 ? '已充满' : '约${(100 - batteryLevel) ~/ 10}小时',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('电压'),
                const Text('48.2V'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getBatteryColor() {
    if (batteryLevel <= 20) {
      return Colors.red;
    } else if (batteryLevel <= 50) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  String _getBatteryStatus() {
    if (batteryLevel <= 10) {
      return '严重不足';
    } else if (batteryLevel <= 20) {
      return '不足';
    } else if (batteryLevel <= 50) {
      return '一般';
    } else if (batteryLevel <= 80) {
      return '良好';
    } else {
      return '优秀';
    }
  }
} 