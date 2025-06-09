import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_blue_classic/flutter_blue_classic.dart' as classic;

class RobotFunctions {
  static final RobotFunctions _instance = RobotFunctions._internal();
  classic.BluetoothConnection? _connection;

  factory RobotFunctions() {
    return _instance;
  }

  RobotFunctions._internal();

  void setConnection(classic.BluetoothConnection connection) {
    _connection = connection;
  }

  bool get isConnected => _connection != null;

  void moveForward() {
    if (isConnected) _connection?.output.add(Uint8List.fromList(utf8.encode('forward\n')));
  }

  void moveBackward() {
    if (isConnected) _connection?.output.add(Uint8List.fromList(utf8.encode('backward\n')));
  }

  void turnLeft() {
    if (isConnected) _connection?.output.add(Uint8List.fromList(utf8.encode('left\n')));
  }

  void turnRight() {
    if (isConnected) _connection?.output.add(Uint8List.fromList(utf8.encode('right\n')));
  }

  void stop() {
    if (isConnected) _connection?.output.add(Uint8List.fromList(utf8.encode('stop\n')));
  }
}
