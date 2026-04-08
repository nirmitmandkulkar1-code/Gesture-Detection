import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../data/mock_signs.dart';
import '../theme/app_theme.dart';
import '../widgets/live_monitor_card.dart';
import '../widgets/section_header.dart';
import '../widgets/sign_card.dart';
import '../widgets/speech_output_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BluetoothConnection? connection;
  bool isConnecting = false;
  bool arduinoConnected = false;
  String buffer = ""; 
  int selectedSignIndex = 0;
  int currentSensorValue = 0;
  final FlutterTts flutterTts = FlutterTts();

  @override
  void dispose() {
    connection?.dispose();
    super.dispose();
  }

  void _toggleBluetooth() async {
    if (arduinoConnected) {
      await connection?.finish();
      setState(() => arduinoConnected = false);
    } else {
      _startConnection();
    }
  }

  void _startConnection() async {
    setState(() => isConnecting = true);
    try {
      List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      BluetoothDevice? server;
      try {
        server = devices.firstWhere((d) => 
          d.name?.contains("HC-05") == true || d.name?.contains("HC-06") == true
        );
      } catch (e) {
        server = null;
      }

      if (server == null) throw Exception("HC-05/HC-06 not paired.");

      connection = await BluetoothConnection.toAddress(server.address);
      setState(() {
        arduinoConnected = true;
        isConnecting = false;
      });

      connection!.input!.listen(_onDataReceived).onDone(() {
        setState(() => arduinoConnected = false);
      });
    } catch (e) {
      setState(() => isConnecting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection failed: $e")),
      );
    }
  }

  void _onDataReceived(Uint8List data) {
    buffer += utf8.decode(data);
    if (buffer.contains('\n')) {
      String completeLine = buffer.split('\n').first.trim();
      _processArduinoCommand(completeLine);
      buffer = ""; 
    }
  }

  void _processArduinoCommand(String command) {
    try {
      List<String> parts = command.split(',');
      Map<String, int> sensors = {};
      for (var part in parts) {
        List<String> kv = part.split(':');
        if (kv.length == 2) sensors[kv[0]] = int.tryParse(kv[1]) ?? 0;
      }

      int newIndex = selectedSignIndex;
      if ((sensors['S1'] ?? 0) > 310) newIndex = 0;
      else if ((sensors['S2'] ?? 0) > 309) newIndex = 1;
      else if ((sensors['S3'] ?? 0) > 250) newIndex = 2;
      else if ((sensors['S4'] ?? 0) > 300) newIndex = 3;

      if (newIndex != selectedSignIndex) {
        setState(() {
          selectedSignIndex = newIndex;
          currentSensorValue = sensors['S1'] ?? 0;
          _playVoiceOutput(medicalSigns[newIndex].phrase);
        });
      }
    } catch (e) {
      debugPrint("Parsing error: $e");
    }
  }

  Future<void> _playVoiceOutput(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final selectedSign = medicalSigns[selectedSignIndex];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEAF4FA), Color(0xFFF9FCFE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TopBanner(arduinoConnected: arduinoConnected),
                  const SizedBox(height: 20),
                  SectionHeader(
                    title: 'Hospital Gestures',
                    subtitle: 'Mapped to voice output',
                    trailing: TextButton.icon(
                      onPressed: isConnecting ? null : _toggleBluetooth,
                      icon: Icon(isConnecting ? Icons.sync : (arduinoConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled)),
                      label: Text(isConnecting ? '...' : (arduinoConnected ? 'Off' : 'Connect')),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // FIXED: Added childAspectRatio adjustment to prevent bottom overflow
                  GridView.builder(
                    itemCount: medicalSigns.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85, // Taller cards to fit text
                    ),
                    itemBuilder: (context, index) {
                      return SignCard(
                        sign: medicalSigns[index],
                        isSelected: selectedSignIndex == index,
                        onTap: () => setState(() => selectedSignIndex = index),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'Live Recognition Monitor', subtitle: 'Hardware stream analysis'),
                  const SizedBox(height: 10),
                  // The Monitor card usually has the right-overflow issue
                  LiveMonitorCard(
                    sign: selectedSign,
                    arduinoConnected: arduinoConnected,
                    currentAngle: currentSensorValue ~/ 4,
                  ),
                  const SizedBox(height: 14),
                  SpeechOutputCard(sign: selectedSign),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBanner extends StatelessWidget {
  const _TopBanner({required this.arduinoConnected});
  final bool arduinoConnected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(colors: [AppTheme.clinicalBlue, AppTheme.calmCyan]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_hospital, color: Colors.white),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'GestureCare Voice Console',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Real-time gesture interface for non-verbal patients.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Badge(text: arduinoConnected ? 'Online' : 'Offline', icon: arduinoConnected ? Icons.check : Icons.close),
              const _Badge(text: 'Ward: ICU', icon: Icons.bed),
              const _Badge(text: 'English', icon: Icons.translate),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.icon});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
