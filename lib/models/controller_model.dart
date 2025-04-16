class ControllerModel {
  String modelType;
  String voltageAndPower;
  String lineCurrPhaseValue;
  String productCode;
  String customCode;
  String customValue;
  bool motorReverseDirection;
  String ratedVoltage;
  String lowPowerControlMode;
  String energyFeedback;
  int gearHighPowerOutput;
  int gearMiddlePowerOutput;
  int gearLowPowerOutput;
  int gearHighSpeed;
  int gearMiddleSpeed;
  int gearLowSpeed;
  bool cruiseFunction;
  bool pFunction;
  bool autoReturnToPFunction;

  ControllerModel({
    this.modelType = "ModelType",
    this.voltageAndPower = "144V20000W",
    this.lineCurrPhaseValue = "999A/9999A",
    this.productCode = "C...2019...0001",
    this.customCode = "YQ",
    this.customValue = "000000",
    this.motorReverseDirection = false,
    this.ratedVoltage = "",
    this.lowPowerControlMode = "",
    this.energyFeedback = "",
    this.gearHighPowerOutput = 100,
    this.gearMiddlePowerOutput = 0,
    this.gearLowPowerOutput = 0,
    this.gearHighSpeed = 0,
    this.gearMiddleSpeed = 0,
    this.gearLowSpeed = 0,
    this.cruiseFunction = false,
    this.pFunction = false,
    this.autoReturnToPFunction = false,
  });

  // 从JSON创建实例
  factory ControllerModel.fromJson(Map<String, dynamic> json) {
    return ControllerModel(
      modelType: json['modelType'] ?? "ModelType",
      voltageAndPower: json['voltageAndPower'] ?? "144V20000W",
      lineCurrPhaseValue: json['lineCurrPhaseValue'] ?? "999A/9999A",
      productCode: json['productCode'] ?? "C...2019...0001",
      customCode: json['customCode'] ?? "YQ",
      customValue: json['customValue'] ?? "000000",
      motorReverseDirection: json['motorReverseDirection'] ?? false,
      ratedVoltage: json['ratedVoltage'] ?? "",
      lowPowerControlMode: json['lowPowerControlMode'] ?? "",
      energyFeedback: json['energyFeedback'] ?? "",
      gearHighPowerOutput: json['gearHighPowerOutput'] ?? 100,
      gearMiddlePowerOutput: json['gearMiddlePowerOutput'] ?? 0,
      gearLowPowerOutput: json['gearLowPowerOutput'] ?? 0,
      gearHighSpeed: json['gearHighSpeed'] ?? 0,
      gearMiddleSpeed: json['gearMiddleSpeed'] ?? 0,
      gearLowSpeed: json['gearLowSpeed'] ?? 0,
      cruiseFunction: json['cruiseFunction'] ?? false,
      pFunction: json['pFunction'] ?? false,
      autoReturnToPFunction: json['autoReturnToPFunction'] ?? false,
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'modelType': modelType,
      'voltageAndPower': voltageAndPower,
      'lineCurrPhaseValue': lineCurrPhaseValue,
      'productCode': productCode,
      'customCode': customCode,
      'customValue': customValue,
      'motorReverseDirection': motorReverseDirection,
      'ratedVoltage': ratedVoltage,
      'lowPowerControlMode': lowPowerControlMode,
      'energyFeedback': energyFeedback,
      'gearHighPowerOutput': gearHighPowerOutput,
      'gearMiddlePowerOutput': gearMiddlePowerOutput,
      'gearLowPowerOutput': gearLowPowerOutput,
      'gearHighSpeed': gearHighSpeed,
      'gearMiddleSpeed': gearMiddleSpeed,
      'gearLowSpeed': gearLowSpeed,
      'cruiseFunction': cruiseFunction,
      'pFunction': pFunction,
      'autoReturnToPFunction': autoReturnToPFunction,
    };
  }

  // 复制实例并更新部分属性
  ControllerModel copyWith({
    String? modelType,
    String? voltageAndPower,
    String? lineCurrPhaseValue,
    String? productCode,
    String? customCode,
    String? customValue,
    bool? motorReverseDirection,
    String? ratedVoltage,
    String? lowPowerControlMode,
    String? energyFeedback,
    int? gearHighPowerOutput,
    int? gearMiddlePowerOutput,
    int? gearLowPowerOutput,
    int? gearHighSpeed,
    int? gearMiddleSpeed,
    int? gearLowSpeed,
    bool? cruiseFunction,
    bool? pFunction,
    bool? autoReturnToPFunction,
  }) {
    return ControllerModel(
      modelType: modelType ?? this.modelType,
      voltageAndPower: voltageAndPower ?? this.voltageAndPower,
      lineCurrPhaseValue: lineCurrPhaseValue ?? this.lineCurrPhaseValue,
      productCode: productCode ?? this.productCode,
      customCode: customCode ?? this.customCode,
      customValue: customValue ?? this.customValue,
      motorReverseDirection: motorReverseDirection ?? this.motorReverseDirection,
      ratedVoltage: ratedVoltage ?? this.ratedVoltage,
      lowPowerControlMode: lowPowerControlMode ?? this.lowPowerControlMode,
      energyFeedback: energyFeedback ?? this.energyFeedback,
      gearHighPowerOutput: gearHighPowerOutput ?? this.gearHighPowerOutput,
      gearMiddlePowerOutput: gearMiddlePowerOutput ?? this.gearMiddlePowerOutput,
      gearLowPowerOutput: gearLowPowerOutput ?? this.gearLowPowerOutput,
      gearHighSpeed: gearHighSpeed ?? this.gearHighSpeed,
      gearMiddleSpeed: gearMiddleSpeed ?? this.gearMiddleSpeed,
      gearLowSpeed: gearLowSpeed ?? this.gearLowSpeed,
      cruiseFunction: cruiseFunction ?? this.cruiseFunction,
      pFunction: pFunction ?? this.pFunction,
      autoReturnToPFunction: autoReturnToPFunction ?? this.autoReturnToPFunction,
    );
  }
} 