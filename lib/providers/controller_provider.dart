import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/controller_model.dart';

class ControllerProvider extends ChangeNotifier {
  ControllerModel _controller = ControllerModel();
  bool _isLoading = false;
  String? _error;

  // Getters
  ControllerModel get controller => _controller;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 构造函数 - 加载保存的数据
  ControllerProvider() {
    loadController();
  }

  // 从SharedPreferences加载控制器数据
  Future<void> loadController() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final String? controllerJson = prefs.getString('controller_data');

      if (controllerJson != null) {
        final Map<String, dynamic> controllerMap = json.decode(controllerJson);
        _controller = ControllerModel.fromJson(controllerMap);
      }

      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = '加载数据失败: $e';
      notifyListeners();
    }
  }

  // 保存控制器数据到SharedPreferences
  Future<void> saveController() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String controllerJson = json.encode(_controller.toJson());
      await prefs.setString('controller_data', controllerJson);
    } catch (e) {
      _error = '保存数据失败: $e';
      notifyListeners();
    }
  }

  // 更新控制器属性
  void updateController(ControllerModel controller) {
    _controller = controller;
    saveController();
    notifyListeners();
  }

  // 更新单个属性
  void updateMotorReverseDirection(bool value) {
    _controller = _controller.copyWith(motorReverseDirection: value);
    saveController();
    notifyListeners();
  }

  void updateRatedVoltage(String value) {
    _controller = _controller.copyWith(ratedVoltage: value);
    saveController();
    notifyListeners();
  }

  void updateLowPowerControlMode(String value) {
    _controller = _controller.copyWith(lowPowerControlMode: value);
    saveController();
    notifyListeners();
  }

  void updateEnergyFeedback(String value) {
    _controller = _controller.copyWith(energyFeedback: value);
    saveController();
    notifyListeners();
  }

  void updateGearHighPowerOutput(int value) {
    _controller = _controller.copyWith(gearHighPowerOutput: value);
    saveController();
    notifyListeners();
  }

  void updateGearMiddlePowerOutput(int value) {
    _controller = _controller.copyWith(gearMiddlePowerOutput: value);
    saveController();
    notifyListeners();
  }

  void updateGearLowPowerOutput(int value) {
    _controller = _controller.copyWith(gearLowPowerOutput: value);
    saveController();
    notifyListeners();
  }

  void updateGearHighSpeed(int value) {
    _controller = _controller.copyWith(gearHighSpeed: value);
    saveController();
    notifyListeners();
  }

  void updateGearMiddleSpeed(int value) {
    _controller = _controller.copyWith(gearMiddleSpeed: value);
    saveController();
    notifyListeners();
  }

  void updateGearLowSpeed(int value) {
    _controller = _controller.copyWith(gearLowSpeed: value);
    saveController();
    notifyListeners();
  }

  void updateCruiseFunction(bool value) {
    _controller = _controller.copyWith(cruiseFunction: value);
    saveController();
    notifyListeners();
  }

  void updatePFunction(bool value) {
    _controller = _controller.copyWith(pFunction: value);
    saveController();
    notifyListeners();
  }

  void updateAutoReturnToPFunction(bool value) {
    _controller = _controller.copyWith(autoReturnToPFunction: value);
    saveController();
    notifyListeners();
  }

  // 重置所有设置
  void resetController() {
    _controller = ControllerModel();
    saveController();
    notifyListeners();
  }
} 