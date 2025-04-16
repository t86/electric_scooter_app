import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/controller_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ControllerProvider>(
      builder: (context, provider, child) {
        return ListView(
          children: [
            const _SettingHeader(title: '通用设置'),
            _SettingTile(
              icon: Icons.language,
              title: '语言',
              subtitle: '简体中文',
              onTap: () {
                _showNotImplementedSnackBar(context);
              },
            ),
            _SettingTile(
              icon: Icons.brightness_4,
              title: '外观',
              subtitle: '跟随系统',
              onTap: () {
                _showNotImplementedSnackBar(context);
              },
            ),
            _SettingTile(
              icon: Icons.notifications,
              title: '通知',
              hasSwitch: true,
              switchValue: true,
              onSwitchChanged: (value) {
                _showNotImplementedSnackBar(context);
              },
            ),
            
            const _SettingHeader(title: '连接设置'),
            _SettingTile(
              icon: Icons.bluetooth,
              title: '蓝牙设置',
              onTap: () {
                _showNotImplementedSnackBar(context);
              },
            ),
            _SettingTile(
              icon: Icons.wifi,
              title: 'Wi-Fi连接',
              switchValue: false,
              hasSwitch: true,
              onSwitchChanged: (value) {
                _showNotImplementedSnackBar(context);
              },
            ),
            
            const _SettingHeader(title: '数据和存储'),
            _SettingTile(
              icon: Icons.storage,
              title: '缓存管理',
              subtitle: '0.0MB',
              onTap: () {
                _showNotImplementedSnackBar(context);
              },
            ),
            _SettingTile(
              icon: Icons.download,
              title: '导出配置',
              onTap: () {
                _showNotImplementedSnackBar(context);
              },
            ),
            _SettingTile(
              icon: Icons.upload,
              title: '导入配置',
              onTap: () {
                _showNotImplementedSnackBar(context);
              },
            ),
            
            const _SettingHeader(title: '关于'),
            _SettingTile(
              icon: Icons.info,
              title: '应用信息',
              subtitle: 'FarDriver v1.0.0',
              onTap: () {
                _showNotImplementedSnackBar(context);
              },
            ),
            _SettingTile(
              icon: Icons.update,
              title: '检查更新',
              onTap: () {
                _showNotImplementedSnackBar(context);
              },
            ),
            _SettingTile(
              icon: Icons.help,
              title: '帮助和反馈',
              onTap: () {
                _showNotImplementedSnackBar(context);
              },
            ),
            _SettingTile(
              icon: Icons.policy,
              title: '隐私政策',
              onTap: () {
                _showNotImplementedSnackBar(context);
              },
            ),
            
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  provider.resetController();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('已恢复默认设置'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade100,
                  foregroundColor: Colors.red.shade900,
                ),
                child: const Text('恢复默认设置'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showNotImplementedSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('此功能正在开发中'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

class _SettingHeader extends StatelessWidget {
  final String title;

  const _SettingHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      alignment: Alignment.bottomLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool hasSwitch;
  final bool switchValue;
  final ValueChanged<bool>? onSwitchChanged;

  const _SettingTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.hasSwitch = false,
    this.switchValue = false,
    this.onSwitchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: hasSwitch
          ? Switch(
              value: switchValue,
              onChanged: onSwitchChanged,
            )
          : const Icon(Icons.chevron_right),
      onTap: hasSwitch ? null : onTap,
    );
  }
} 