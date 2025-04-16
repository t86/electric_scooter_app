import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants.dart';
import '../screens/params_screen.dart';
import '../screens/graph_screen.dart';
import '../screens/vcu_screen.dart';
import '../pages/communication_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // 设置透明状态栏
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  // 页面列表
  final List<Widget> _screens = [
    const ParamsScreen(),
    const GraphScreen(),
    const VcuScreen(),
    const GraphScreen(), // 曲线页面，暂时使用GraphScreen
    const CommunicationPage(),
  ];

  // 底部导航栏项目
  List<BottomNavigationBarItem> _bottomNavItems() {
    return [
      const BottomNavigationBarItem(
        icon: Icon(Icons.tune),
        label: '参数',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.show_chart),
        label: '图表',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.dashboard),
        label: 'VCU',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.timeline),
        label: '曲线',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.bluetooth),
        label: '通信',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // 确保内容延伸到顶部
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0, // 设置为0以完全隐藏AppBar
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // 确保所有项目显示
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _bottomNavItems(),
      ),
    );
  }
} 