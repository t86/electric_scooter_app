import 'dart:typed_data';

class BleProtocol {
  static const int HEADER = 0x5AA5;
  static const int FOOTER = 0x3C;
  
  // 命令类型
  static const int CMD_READ = 0x01;
  static const int CMD_WRITE = 0x02;
  static const int CMD_READ_SUCCESS = 0x11;
  static const int CMD_WRITE_SUCCESS = 0x12;
  static const int CMD_READ_FAIL = 0x21;
  static const int CMD_WRITE_FAIL = 0x22;
  static const int CMD_ERROR = 0xFF;

  // 参数地址
  static const int PARAM_00 = 0x00;
  static const int PARAM_01 = 0x01;
  static const int PARAM_LOG = 0xFF;

  // 构建数据帧
  static Uint8List buildFrame({
    required int command,
    required int commandType,
    required int dataLength,
    required List<int> data,
    int sequence = 0x01, // 序号，默认为1
  }) {
    // 确保数据长度匹配
    dataLength = data.length;
    
    // 构建帧: 帧头(2) + 长度(1) + 命令(1) + 类型(1) + 序号(1) + 数据(n) + 帧尾(1) + CRC(2)
    final buffer = ByteData(6 + dataLength);
    
    // 帧头
    buffer.setUint16(0, HEADER, Endian.big);
    // 数据长度
    buffer.setUint8(2, dataLength);
    // 命令
    buffer.setUint8(3, command);
    // 命令类型
    buffer.setUint8(4, commandType);
    // 序号
    buffer.setUint8(5, sequence);
    
    // 数据 - 确保不超出范围
    for (var i = 0; i < dataLength; i++) {
      if (i < data.length) {
        buffer.setUint8(6 + i, data[i]);
      } else {
        buffer.setUint8(6 + i, 0); // 填充0
      }
    }
    
    // 帧尾
    buffer.setUint8(6 + dataLength, FOOTER);
    
    // 计算CRC
    final crc = calculateModbusCRC(buffer.buffer.asUint8List().sublist(0, 7 + dataLength));
    final result = Uint8List(9 + dataLength);
    result.setAll(0, buffer.buffer.asUint8List());
    result.setAll(7 + dataLength, [crc >> 8, crc & 0xFF]);
    
    return result;
  }

  // MODBUS CRC计算
  static int calculateModbusCRC(Uint8List data) {
    int crc = 0xFFFF;
    
    for (final byte in data) {
      crc ^= byte;
      for (var j = 0; j < 8; j++) {
        if ((crc & 0x0001) != 0) {
          crc = (crc >> 1) ^ 0xA001;
        } else {
          crc = crc >> 1;
        }
      }
    }
    
    return crc;
  }

  // 解析数据帧
  static Map<String, dynamic>? parseFrame(Uint8List data) {
    if (data.length < 9) return null;
    
    final header = (data[0] << 8) | data[1];
    if (header != HEADER) return null;
    
    final dataLength = data[2];
    if (data.length != dataLength + 9) return null;
    
    final command = data[3];
    final commandType = data[4];
    final sequence = data[5];
    final payload = data.sublist(6, 6 + dataLength);
    final footer = data[6 + dataLength];
    
    if (footer != FOOTER) return null;
    
    final receivedCRC = (data[7 + dataLength] << 8) | data[8 + dataLength];
    final calculatedCRC = calculateModbusCRC(data.sublist(0, 7 + dataLength));
    
    if (receivedCRC != calculatedCRC) return null;
    
    return {
      'command': command,
      'commandType': commandType,
      'sequence': sequence,
      'data': payload,
      'dataLength': dataLength,
    };
  }
  
  // 将数据帧转换为十六进制字符串(用于显示)
  static String frameToHexString(Uint8List data) {
    return data.map((byte) => '0x${byte.toRadixString(16).padLeft(2, '0').toUpperCase()}').join(' ');
  }
  
  // 将解析后的帧转换为可读字符串(用于UI显示)
  static String parsedFrameToString(Map<String, dynamic> frame) {
    final commandStr = '0x${frame['command'].toRadixString(16).padLeft(2, '0').toUpperCase()}';
    final typeStr = '0x${frame['commandType'].toRadixString(16).padLeft(2, '0').toUpperCase()}';
    final sequenceStr = '0x${frame['sequence'].toRadixString(16).padLeft(2, '0').toUpperCase()}';
    final dataStr = frame['data'].map((byte) => 
        '0x${byte.toRadixString(16).padLeft(2, '0').toUpperCase()}').join(' ');
    
    String typeName = '';
    switch (frame['commandType']) {
      case CMD_READ: typeName = '读'; break;
      case CMD_WRITE: typeName = '写'; break;
      case CMD_READ_SUCCESS: typeName = '读成功'; break;
      case CMD_WRITE_SUCCESS: typeName = '写成功'; break;
      case CMD_READ_FAIL: typeName = '读失败'; break;
      case CMD_WRITE_FAIL: typeName = '写失败'; break;
      case CMD_ERROR: typeName = '错误'; break;
      default: typeName = '未知';
    }
    
    return '命令: $commandStr, 类型: $typeStr($typeName), 序号: $sequenceStr, 数据: $dataStr';
  }
  
  // 根据命令和参数创建完整帧
  static Uint8List createCommandFrame({
    required int command,
    required int commandType,
    required List<int> data,
    int sequence = 0x01,
  }) {
    return buildFrame(
      command: command,
      commandType: commandType,
      dataLength: data.length,
      data: data,
      sequence: sequence,
    );
  }
  
  // 创建读取参数命令
  static Uint8List createReadCommand(int paramAddress, {int sequence = 0x01}) {
    return createCommandFrame(
      command: paramAddress,
      commandType: CMD_READ,
      data: [0x00],
      sequence: sequence,
    );
  }
  
  // 创建写入参数命令
  static Uint8List createWriteCommand(int paramAddress, List<int> data, {int sequence = 0x01}) {
    return createCommandFrame(
      command: paramAddress,
      commandType: CMD_WRITE,
      data: data,
      sequence: sequence,
    );
  }
  
  // 创建读取参数响应
  static Uint8List createReadResponse(int paramAddress, List<int> data, bool success, {int sequence = 0x01}) {
    return createCommandFrame(
      command: paramAddress,
      commandType: success ? CMD_READ_SUCCESS : CMD_READ_FAIL,
      data: data,
      sequence: sequence,
    );
  }
  
  // 创建写入参数响应
  static Uint8List createWriteResponse(int paramAddress, List<int> data, bool success, {int sequence = 0x01}) {
    return createCommandFrame(
      command: paramAddress,
      commandType: success ? CMD_WRITE_SUCCESS : CMD_WRITE_FAIL,
      data: data,
      sequence: sequence,
    );
  }
  
  // 将文本消息转换为数据帧
  static Uint8List textToFrame(String text, {int command = PARAM_LOG, int sequence = 0x01}) {
    final data = text.codeUnits;
    return createCommandFrame(
      command: command,
      commandType: CMD_WRITE,
      data: data,
      sequence: sequence,
    );
  }
  
  // 从数据帧中提取文本消息
  static String? frameToText(Uint8List frame) {
    final parsed = parseFrame(frame);
    if (parsed == null) return null;
    
    try {
      return String.fromCharCodes(parsed['data']);
    } catch (e) {
      return null;
    }
  }
} 