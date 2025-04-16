import 'ble_service.dart';
import 'mock_ble_service.dart';
import 'ble_service_interface.dart';

/// BLE服务类型
enum BleServiceType {
  /// 真实的蓝牙服务
  real,
  
  /// 模拟的蓝牙服务
  mock,
}

/// BLE服务提供者，用于管理和切换不同的BLE服务实现
class BleServiceProvider {
  static final BleServiceProvider _instance = BleServiceProvider._internal();
  factory BleServiceProvider() => _instance;
  BleServiceProvider._internal();
  
  /// 当前使用的服务类型
  BleServiceType _currentType = BleServiceType.mock;
  
  /// 服务实例
  late BleServiceInterface _service;
  
  /// 获取服务实例
  BleServiceInterface get service => _service;
  
  /// 获取当前服务类型
  BleServiceType get serviceType => _currentType;
  
  /// 初始化服务
  void initialize({BleServiceType type = BleServiceType.mock}) {
    _currentType = type;
    _service = _createService(type);
    print('初始化 ${type == BleServiceType.real ? "真实" : "模拟"} 蓝牙服务');
  }
  
  /// 切换服务类型
  void switchServiceType(BleServiceType type) {
    if (_currentType != type) {
      // 如果当前有连接，先断开
      if (_service.isConnected) {
        _service.disconnect();
      }
      
      // 切换服务类型
      _currentType = type;
      _service = _createService(type);
      
      print('切换到 ${type == BleServiceType.real ? "真实" : "模拟"} 蓝牙服务');
    }
  }
  
  /// 创建服务实例
  BleServiceInterface _createService(BleServiceType type) {
    switch (type) {
      case BleServiceType.real:
        return BleService();
      case BleServiceType.mock:
        return MockBleService();
    }
  }
  
  /// 获取模拟服务实例(用于调用模拟专有方法)
  MockBleService? getMockService() {
    if (_currentType == BleServiceType.mock) {
      return _service as MockBleService;
    }
    return null;
  }
} 