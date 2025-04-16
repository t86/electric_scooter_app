import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/vehicle_provider.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VehicleProvider>(
      builder: (context, vehicleProvider, child) {
        final vehicle = vehicleProvider.selectedVehicle;
        
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.map,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              const Text(
                '车辆位置',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (vehicle != null) ...[
                Text(
                  '当前位置: ${vehicle.latitude.toStringAsFixed(6)}, ${vehicle.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '上次更新: ${vehicle.lastUsedFriendly}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ] else
                const Text(
                  '没有车辆位置信息',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  if (vehicleProvider.selectedVehicle != null) {
                    vehicleProvider.refreshVehicleStatus();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('位置已刷新'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('刷新位置'),
              ),
            ],
          ),
        );
      },
    );
  }
} 