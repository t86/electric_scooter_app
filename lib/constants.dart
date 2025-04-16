class Constants {
  // 应用信息
  static const String appTitle = "FarDriver";
  static const String motorType = "Motor FOC Controller";
  
  // 控制器信息
  static const String modelType = "144V20000W";
  static const String lineCurrPhaseValue = "999A/9999A";
  static const String productCode = "C...2019...0001";
  static const String customCode = "YQ";
  static const String customValue = "000000";
  
  // 底部导航标签
  static const List<String> bottomNavItems = [
    "参数", 
    "图表", 
    "VCU", 
    "曲线", 
    "通信"
  ];
  
  // 参数设置标签
  static const List<String> paramSections = [
    "Base Parameters",
    "Three speed parameters",
    "Functions"
  ];
  
  // 基本参数列表
  static const List<Map<String, dynamic>> baseParams = [
    {
      "title": "Motor Reverse Direction",
      "subtitle": "Reverse Motor Roll Direction",
      "type": "switch",
      "value": false,
    },
    {
      "title": "RatedVoltage",
      "subtitle": "Battery Rated Voltage",
      "type": "select",
      "value": "",
    },
    {
      "title": "Low Power Control Mode",
      "subtitle": "Control mode when low power: 0-Vol2V",
      "type": "select",
      "value": "",
    },
    {
      "title": "Energy feedback",
      "subtitle": "Suitable follow mode",
      "type": "select",
      "value": "",
    },
  ];
  
  // 三速参数列表
  static const List<Map<String, dynamic>> speedParams = [
    {
      "title": "GearHigh Power Output 100%",
      "type": "select",
      "value": "",
      "indicator": true,
    },
    {
      "title": "GearMiddle Power Output 0%",
      "type": "select",
      "value": "",
      "indicator": true,
    },
    {
      "title": "GearLow Power Output 0%",
      "type": "select",
      "value": "",
      "indicator": true,
    },
    {
      "title": "GearHigh Speed 0%",
      "type": "select",
      "value": "",
      "indicator": true,
    },
    {
      "title": "GearMiddle Speed 0%",
      "type": "select",
      "value": "",
      "indicator": true,
    },
    {
      "title": "GearLow Speed 0%",
      "type": "select",
      "value": "",
      "indicator": true,
    },
  ];
  
  // 功能参数列表
  static const List<Map<String, dynamic>> functionParams = [
    {
      "title": "Cruise Function",
      "subtitle": "Cruise Function Enable",
      "type": "switch",
      "value": false,
    },
    {
      "title": "P Function",
      "subtitle": "P Function Enable",
      "type": "switch",
      "value": false,
    },
    {
      "title": "Auto return to P Function",
      "subtitle": "Auto Return to Gear P Function",
      "type": "switch",
      "value": false,
    },
  ];
} 