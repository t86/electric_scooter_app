import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'providers/controller_provider.dart';
import 'shared/providers/vehicle_provider.dart';
import 'screens/home_screen.dart';
import 'services/ble_service_provider.dart';

void main() {
  // 初始化BLE服务提供者，默认使用模拟服务
  BleServiceProvider().initialize(type: BleServiceType.mock);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ControllerProvider()),
        ChangeNotifierProvider(create: (context) => VehicleProvider()),
      ],
      child: MaterialApp(
        title: 'FarDriver FOC Controller',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
      ),
    );
  }
}
