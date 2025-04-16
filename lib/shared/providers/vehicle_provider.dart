import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vehicle_model.dart';

class VehicleProvider extends ChangeNotifier {
  VehicleModel? _selectedVehicle;
  List<VehicleModel> _vehicles = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  VehicleModel? get selectedVehicle => _selectedVehicle;
  List<VehicleModel> get vehicles => _vehicles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 构造函数 - 加载保存的数据
  VehicleProvider() {
    _loadVehicles();
  }

  // 从SharedPreferences加载车辆列表
  Future<void> _loadVehicles() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final String? vehiclesJson = prefs.getString('vehicles_data');

      if (vehiclesJson != null) {
        final List<dynamic> vehiclesList = json.decode(vehiclesJson);
        _vehicles = vehiclesList
            .map((json) => VehicleModel.fromJson(json))
            .toList();
        
        final String? selectedVehicleId = prefs.getString('selected_vehicle_id');
        if (selectedVehicleId != null) {
          _selectedVehicle = _vehicles.firstWhere(
            (vehicle) => vehicle.id == selectedVehicleId,
            orElse: () => _createDemoVehicle(),
          );
        } else if (_vehicles.isNotEmpty) {
          _selectedVehicle = _vehicles.first;
        } else {
          _selectedVehicle = _createDemoVehicle();
          _vehicles.add(_selectedVehicle!);
        }
      } else {
        // 创建演示数据
        _selectedVehicle = _createDemoVehicle();
        _vehicles = [_selectedVehicle!];
      }

      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = '加载车辆数据失败: $e';
      notifyListeners();
    }
  }

  // 保存车辆列表到SharedPreferences
  Future<void> _saveVehicles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String vehiclesJson = json.encode(_vehicles.map((v) => v.toJson()).toList());
      await prefs.setString('vehicles_data', vehiclesJson);
      
      if (_selectedVehicle != null) {
        await prefs.setString('selected_vehicle_id', _selectedVehicle!.id);
      }
    } catch (e) {
      _error = '保存车辆数据失败: $e';
      notifyListeners();
    }
  }

  // 选择车辆
  void selectVehicle(String vehicleId) {
    final vehicle = _vehicles.firstWhere(
      (v) => v.id == vehicleId,
      orElse: () => throw Exception('未找到车辆: $vehicleId'),
    );
    _selectedVehicle = vehicle;
    _saveVehicles();
    notifyListeners();
  }

  // 添加车辆
  void addVehicle(VehicleModel vehicle) {
    _vehicles.add(vehicle);
    if (_selectedVehicle == null) {
      _selectedVehicle = vehicle;
    }
    _saveVehicles();
    notifyListeners();
  }

  // 更新车辆
  void updateVehicle(VehicleModel updatedVehicle) {
    final index = _vehicles.indexWhere((v) => v.id == updatedVehicle.id);
    if (index != -1) {
      _vehicles[index] = updatedVehicle;
      if (_selectedVehicle?.id == updatedVehicle.id) {
        _selectedVehicle = updatedVehicle;
      }
      _saveVehicles();
      notifyListeners();
    }
  }

  // 删除车辆
  void deleteVehicle(String vehicleId) {
    _vehicles.removeWhere((v) => v.id == vehicleId);
    if (_selectedVehicle?.id == vehicleId) {
      _selectedVehicle = _vehicles.isNotEmpty ? _vehicles.first : null;
    }
    _saveVehicles();
    notifyListeners();
  }

  // 刷新车辆状态
  Future<void> refreshVehicleStatus() async {
    try {
      _isLoading = true;
      notifyListeners();

      // 模拟网络请求延迟
      await Future.delayed(const Duration(seconds: 1));

      // 在真实应用中，这里应该从API获取最新状态
      if (_selectedVehicle != null) {
        final now = DateTime.now().toIso8601String();
        final updatedVehicle = _selectedVehicle!.copyWith(
          batteryLevel: _selectedVehicle!.batteryLevel > 0 
              ? _selectedVehicle!.batteryLevel - 1 
              : 80,
          lastUsed: now,
        );
        
        updateVehicle(updatedVehicle);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = '刷新车辆状态失败: $e';
      notifyListeners();
    }
  }

  // 创建演示车辆数据
  VehicleModel _createDemoVehicle() {
    return VehicleModel(
      id: 'demo-vehicle-1',
      name: 'FarDriver控制器',
      latitude: 31.298886,
      longitude: 120.585316,
      batteryLevel: 78,
      remainingRange: 45,
      lastUsed: DateTime.now().toIso8601String(),
      status: 'idle',
    );
  }
} 