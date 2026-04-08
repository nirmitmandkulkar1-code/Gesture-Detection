import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../data/mock_signs.dart';
import '../theme/app_theme.dart';
import '../widgets/live_monitor_card.dart';
import '../widgets/section_header.dart';
import '../widgets/sign_card.dart';
import '../widgets/speech_output_card.dart';
import 'package:flutter_tts/flutter_tts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Bluetooth State Variables
  BluetoothConnection? connection;
  bool isConnecting = false;
  bool arduinoConnected = false;
  String buffer = ""; // To store partial data chunks
  
  // App Logic State
  int selectedSignIndex = 0;
  int currentSensorValue = 0;

  @override
  void dispose() {
    connection?.dispose();
    super.dispose();
  }

  // --- Bluetooth Logic ---

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
      // Logic: Get bonded devices and find one named "HC-05" or "HC-06"
      List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      BluetoothDevice? server = devices.firstWhere(
        (d) => d.name == "HC-05" || d.name == "HC-06",
        orElse: () => devices.first, 
      );

      connection = await BluetoothConnection.toAddress(server.address);
      setState(() {
        arduinoConnected = true;
        isConnecting = false;
      });

      // Listen for incoming data stream
      connection!.input!.listen(_onDataReceived).onDone(() {
        setState(() => arduinoConnected = false);
      });

    } catch (e) {
      debugPrint('Connection failed: $e');
      setState(() => isConnecting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not connect to Arduino Bluetooth")),
      );
    }
  }

  void _onDataReceived(Uint8List data) {
    // Bluetooth sends data in chunks. We buffer it until we find a newline.
    buffer += utf8.decode(data);
    
    if (buffer.contains('\n')) {
      String completeLine = buffer.split('\n').first.trim();
      _processArduinoCommand(completeLine);
      buffer = ""; // Reset buffer
    }
  }

 void _processArduinoCommand(String command) {
  // Parsing the string "S1:XXX,S2:YYY,S3:ZZZ,S4:AAA"
  try {
    // Split by comma to get individual sensor blocks
    List<String> parts = command.split(',');
    Map<String, int> sensors = {};

    for (var part in parts) {
      List<String> kv = part.split(':');
      if (kv.length == 2) {
        sensors[kv[0]] = int.tryParse(kv[1]) ?? 0;
      }
    }

int newIndex = selectedSignIndex;
  if (sensors['S1']! > 310) newIndex = 0;
  else if (sensors['S2']! > 309) newIndex = 1;
  else if (sensors['S3']! > 250) newIndex = 2;
  else if (sensors['S4']! > 300) newIndex = 3;

   if (newIndex != selectedSignIndex) {
    setState(() {
      selectedSignIndex = newIndex;
      // Trigger voice only when the sign actually changes
      _playVoiceOutput(medicalSigns[newIndex].phrase); 
    });
  }
} 
catch (e) {
    debugPrint("Parsing error: $e");
  }
}

final FlutterTts flutterTts = FlutterTts();

Future<void> _playVoiceOutput(String text) async {
  await flutterTts.setLanguage("en-US");
  await flutterTts.setPitch(1.0);
  await flutterTts.speak(text);
}
  // --- UI Build ---

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
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopBanner(arduinoConnected: arduinoConnected),
                const SizedBox(height: 20),
                SectionHeader(
                  title: 'Hospital Gesture Commands',
                  subtitle: '${medicalSigns.length} medical signs mapped to voice',
                  trailing: TextButton.icon(
                    onPressed: isConnecting ? null : _toggleBluetooth,
                    icon: Icon(
                      isConnecting 
                        ? Icons.hourglass_empty
                        : (arduinoConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled),
                    ),
                    label: Text(isConnecting ? 'Connecting...' : (arduinoConnected ? 'Disconnect' : 'Connect')),
                  ),
                ),
                const SizedBox(height: 14),
                GridView.builder(
                  itemCount: medicalSigns.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.05,
                  ),
                  itemBuilder: (context, index) {
                    final sign = medicalSigns[index];
                    return SignCard(
                      sign: sign,
                      isSelected: selectedSignIndex == index,
                      onTap: () => setState(() => selectedSignIndex = index),
                    );
                  },
                ),
                const SizedBox(height: 20),
                SectionHeader(
                  title: 'Live Recognition Monitor',
                  subtitle: 'Arduino data: $currentSensorValue units',
                ),
                const SizedBox(height: 10),
                LiveMonitorCard(
                  sign: selectedSign,
                  arduinoConnected: arduinoConnected,
                  currentAngle: currentSensorValue ~/ 4, // Mapping raw bits to 0-100%ish
                ),
                const SizedBox(height: 14),
                SectionHeader(
                  title: 'Speech Synthesis Output',
                  subtitle: 'Sentence for nurse station',
                ),
                const SizedBox(height: 10),
                SpeechOutputCard(sign: selectedSign),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Keep your _TopBanner and _Badge classes here as they were before...
