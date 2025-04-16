import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../constants.dart';
import '../providers/controller_provider.dart';

class ParamsScreen extends StatefulWidget {
  const ParamsScreen({super.key});

  @override
  State<ParamsScreen> createState() => _ParamsScreenState();
}

class _ParamsScreenState extends State<ParamsScreen> {
  // 轮播控制
  late PageController _bannerController;
  int _currentBannerPage = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _bannerController = PageController(initialPage: 0, viewportFraction: 1.0);
    _startBannerTimer();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  // 启动轮播定时器
  void _startBannerTimer() {
    _bannerTimer?.cancel();
    // 设置3秒自动切换一次
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_bannerController.hasClients) {
        final bannerItemsCount = 3; // 轮播项数量
        if (_currentBannerPage < bannerItemsCount - 1) {
          _currentBannerPage++;
        } else {
          _currentBannerPage = 0;
        }
        _bannerController.animateToPage(
          _currentBannerPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ControllerProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // 滚动内容区域
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // 控制器信息头部
                        _buildControllerInfoHeader(),
                        
                        // DateTime区域
                        Container(
                          color: Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          width: double.infinity,
                          child: const Center(
                            child: Text(
                              '- DateTime',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        
                        // 日期时间行
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              const Expanded(
                                flex: 1,
                                child: Text('Date'),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  DateTime.now().toString().split(' ')[0],
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // 基本参数区块
                        _buildParameterSection(
                          "Base Paramteters",
                          Colors.lightBlue.shade100,
                          [
                            _buildSwitchParameter(
                              "Motor Reverse Direction", 
                              "Reverse Motor Roll Direction",
                              provider.controller.motorReverseDirection,
                              (value) => provider.updateMotorReverseDirection(value),
                            ),
                            _buildSelectParameter(
                              "RatedVoltage", 
                              "Battary Rated Voltage",
                              "",
                            ),
                            _buildSelectParameter(
                              "Low Power Control Mode", 
                              "Control mode when low power: 0-Vol2V",
                              "",
                            ),
                            _buildSelectParameter(
                              "Energy feedback", 
                              "Suitable follow mode",
                              "",
                            ),
                          ],
                        ),
                        
                        // 三速参数区块
                        _buildParameterSection(
                          "Three speed parameters",
                          Colors.lightBlue.shade100,
                          [
                            _buildSelectParameter(
                              "GearHigh Power Output 100%", 
                              "",
                              "",
                              showIndicator: true,
                            ),
                            _buildSelectParameter(
                              "GearMiddle Power Output 0%", 
                              "",
                              "",
                              showIndicator: true,
                            ),
                            _buildSelectParameter(
                              "GearLow Power Output 0%", 
                              "",
                              "",
                              showIndicator: true,
                            ),
                            _buildSelectParameter(
                              "GearHigh Speed 0%", 
                              "",
                              "",
                              showIndicator: true,
                            ),
                            _buildSelectParameter(
                              "GearMiddle Speed 0%", 
                              "",
                              "",
                              showIndicator: true,
                            ),
                            _buildSelectParameter(
                              "GearLow Speed 0%", 
                              "",
                              "",
                              showIndicator: true,
                            ),
                          ],
                        ),
                        
                        // 功能区块
                        _buildParameterSection(
                          "Functions",
                          Colors.lightBlue.shade100,
                          [
                            _buildSwitchParameter(
                              "Cruise Function", 
                              "Cruise Function Enable",
                              provider.controller.cruiseFunction,
                              (value) => provider.updateCruiseFunction(value),
                            ),
                            _buildSwitchParameter(
                              "P Function", 
                              "P Function Enable",
                              provider.controller.pFunction,
                              (value) => provider.updatePFunction(value),
                            ),
                            _buildSwitchParameter(
                              "Auto return to P Function", 
                              "Auto Return to Gear P Function",
                              provider.controller.autoReturnToPFunction,
                              (value) => provider.updateAutoReturnToPFunction(value),
                            ),
                          ],
                        ),
                        
                        // 右下角信息 - 还是放在滚动区域内
                        Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16, bottom: 8),
                          child: const Text(
                            'RcvFrames0',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        
                        // 底部填充区域，为固定按钮腾出空间
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                
                // 固定在底部的按钮区域
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          provider.resetController();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                        ),
                        child: const Text('Restor'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          provider.saveController();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('参数已保存'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                        ),
                        child: const Text('Save'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('此功能在专业版中可用'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                        ),
                        child: const Text('Open Pro'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 构建控制器信息头部
  Widget _buildControllerInfoHeader() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // 顶部轮播Banner
          _buildTopBanner(),
          
          // 型号标识
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            child: const Text(
              'ModelType',
              style: TextStyle(
                color: Colors.brown,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          
          // FarDriver标题行
          Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            child: const Row(
              children: [
                Text(
                  'FarDriver',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Motor FOC Controller',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // 产品参数
          _buildInfoRow('ModelType', 'ModelType'),
          _buildInfoRow('Voltage/Power', '144V20000W'),
          _buildInfoRow('LineCurr/PhaseCurr', '999A/9999A'),
          
          // 产品代码
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            child: Row(
              children: [
                const Text(
                  'ProductCode:',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                Text(
                  'C...2019...0001',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 100,
                  height: 100,
                  child: QrImageView(
                    data: 'https://fardriver.com/C...2019...0001',
                    version: QrVersions.auto,
                    size: 100.0,
                  ),
                ),
              ],
            ),
          ),
          
          // 自定义代码
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            child: Row(
              children: [
                const Text(
                  'CostumCode:',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                  ),
                ),
                const Text(
                  'YQ',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                const Text(
                  '000000',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建顶部轮播Banner
  Widget _buildTopBanner() {
    // 示例图片列表，实际应用中可以从网络加载或使用本地图片
    final List<Widget> bannerItems = [
      _buildBannerItem('assets/images/banner1.jpg', '控制器产品展示1', Colors.blue.shade200),
      _buildBannerItem('assets/images/banner2.jpg', '控制器产品展示2', Colors.green.shade200),
      _buildBannerItem('assets/images/banner3.jpg', '控制器产品展示3', Colors.orange.shade200),
    ];

    return Container(
      height: 160,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: bannerItems.length,
              controller: _bannerController,
              itemBuilder: (context, index) {
                return bannerItems[index];
              },
              onPageChanged: (index) {
                setState(() {
                  _currentBannerPage = index;
                });
              },
            ),
          ),
          // 添加指示器
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                bannerItems.length,
                (index) => Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentBannerPage == index
                        ? Colors.blue
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建单个Banner项目
  Widget _buildBannerItem(String imageUrl, String title, Color fallbackColor) {
    return Container(
      width: double.infinity,
      child: ClipRRect(
        child: Stack(
          children: [
            // 图片展示，如果加载失败则显示替代颜色
            Positioned.fill(
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: fallbackColor,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            'https://placeholder.co/150x80',
                            width: 150,
                            height: 80,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.image, size: 80, color: Colors.white);
                            },
                          ),
                          SizedBox(width: 20),
                          Image.network(
                            'https://placeholder.co/150x80',
                            width: 150,
                            height: 80,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.settings_input_component, size: 80, color: Colors.white);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // 可选：在图片上添加标题或渐变效果
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  // 构建参数区域
  Widget _buildParameterSection(String title, Color titleColor, List<Widget> parameters) {
    return Column(
      children: [
        // 区块标题
        Container(
          width: double.infinity,
          color: titleColor,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        
        // 参数列表
        ...parameters,
      ],
    );
  }

  // 构建开关类型参数
  Widget _buildSwitchParameter(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 0.5,
          ),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          child: const Icon(
            Icons.info_outline,
            color: Colors.black54,
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }

  // 构建选择类型参数
  Widget _buildSelectParameter(String title, String subtitle, String value, {bool showIndicator = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 0.5,
          ),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          child: const Icon(
            Icons.info_outline,
            color: Colors.black54,
          ),
        ),
        title: Text(title),
        subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIndicator) ...[
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Text('>'),
          ],
        ),
      ),
    );
  }
} 