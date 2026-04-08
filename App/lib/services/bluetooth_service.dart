import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothBackend {
  BluetoothConnection? connection;
  bool get isConnected => connection?.isConnected ?? false;

  // Connect to the HC-05/06 by address
  Future<bool> connect(String address) async {
    try {
      connection = await BluetoothConnection.toAddress(address);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Listen for sensor data from Arduino
  void listenToArduino(Function(String) onDataReceived) {
    connection?.input?.listen((Uint8List data) {
      String message = utf8.decode(data);
      onDataReceived(message);
    });
  }

  void disconnect() {
    connection?.dispose();
  }
}
