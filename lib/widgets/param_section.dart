import 'package:flutter/material.dart';

typedef SwitchChangedCallback = void Function(int index, bool value);
typedef SelectChangedCallback = void Function(int index, String value);

class ParamSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> params;
  final SwitchChangedCallback? onSwitchChanged;
  final SelectChangedCallback? onSelectChanged;

  const ParamSection({
    super.key,
    required this.title,
    required this.params,
    this.onSwitchChanged,
    this.onSelectChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 区块标题
        Container(
          width: double.infinity,
          color: Colors.lightBlue.shade100,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        
        // 参数列表
        ...List.generate(params.length, (index) {
          final param = params[index];
          return _buildParamItem(context, index, param);
        }),
      ],
    );
  }

  Widget _buildParamItem(BuildContext context, int index, Map<String, dynamic> param) {
    final title = param['title'] as String;
    final subtitle = param['subtitle'] as String?;
    final type = param['type'] as String;
    final dynamic value = param['value'];
    final bool hasIndicator = param['indicator'] as bool? ?? false;

    return Container(
      decoration: BoxDecoration(
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
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: _buildTrailing(context, index, type, value, hasIndicator),
      ),
    );
  }

  Widget _buildTrailing(
    BuildContext context,
    int index,
    String type,
    dynamic value,
    bool hasIndicator,
  ) {
    if (type == 'switch') {
      return Switch(
        value: value as bool? ?? false,
        onChanged: (newValue) {
          if (onSwitchChanged != null) {
            onSwitchChanged!(index, newValue);
          }
        },
      );
    } else if (type == 'select') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasIndicator) ...[
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
          const Icon(Icons.navigate_next),
        ],
      );
    }
    
    return const SizedBox.shrink();
  }
} 