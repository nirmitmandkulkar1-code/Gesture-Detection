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

  // FIX #3: buffer is now drained properly in _onDataReceived
  String _buffer = '';

  int selectedSignIndex = 0;
  int currentSensorValue = 0;
  final FlutterTts flutterTts = FlutterTts();

  // ── Arduino thresholds ──────────────────────────────────────────────────────
  // FIX #2: Match the exact values used in the Arduino sketch
  static const int _t1 = 910;
  static const int _t2 = 940;
  static const int _t3 = 865;
  static const int _t4 = 914;

  @override
  void dispose() {
    connection?.dispose();
    flutterTts.stop();
    super.dispose();
  }

  // ── Bluetooth ───────────────────────────────────────────────────────────────

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
      final devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      BluetoothDevice? server;
      try {
        server = devices.firstWhere(
          (d) =>
              d.name?.contains('HC-05') == true ||
              d.name?.contains('HC-06') == true,
        );
      } catch (_) {
        server = null;
      }

      if (server == null) throw Exception('HC-05/HC-06 not paired.');

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection failed: $e')),
        );
      }
    }
  }

  // ── Data parsing ─────────────────────────────────────────────────────────────

  // FIX #3: Properly drain the buffer so no lines are lost when two arrive
  // together in a single Bluetooth chunk.
  void _onDataReceived(Uint8List data) {
    _buffer += utf8.decode(data);
    while (_buffer.contains('\n')) {
      final idx = _buffer.indexOf('\n');
      final line = _buffer.substring(0, idx).trim();
      _buffer = _buffer.substring(idx + 1); // keep remainder, don't discard
      if (line.isNotEmpty) _processArduinoCommand(line);
    }
  }

  // FIX #1: Arduino sends  "S1: 910 | S2: 940 | S3: 865 | S4: 914"
  //   • parts are separated by " | "
  //   • key and value are separated by ": " (colon + space)
  // FIX #2: Thresholds now match the Arduino sketch values exactly.
  // FIX #4: currentSensorValue now tracks whichever sensor actually fired,
  //         not always S1.
  // FIX #5: _playVoiceOutput() is called AFTER setState, not inside it.
  void _processArduinoCommand(String command) {
    try {
      // Split on " | " to get ["S1: 910", "S2: 940", ...]
      final parts = command.split(' | ');
      final sensors = <String, int>{};

      for (final part in parts) {
        // Split on ': ' (colon + space)
        final kv = part.split(': ');
        if (kv.length == 2) {
          final key = kv[0].trim();       // "S1"
          final val = int.tryParse(kv[1].trim()) ?? 0;
          sensors[key] = val;
        }
      }

      int newIndex = selectedSignIndex;
      int triggeredValue = currentSensorValue;

      if ((sensors['S1'] ?? 0) > _t1) {
        newIndex = 0;
        triggeredValue = sensors['S1']!;
      } else if ((sensors['S2'] ?? 0) > _t2) {
        newIndex = 1;
        triggeredValue = sensors['S2']!;
      } else if ((sensors['S3'] ?? 0) > _t3) {
        newIndex = 2;
        triggeredValue = sensors['S3']!;
      } else if ((sensors['S4'] ?? 0) > _t4) {
        newIndex = 3;
        triggeredValue = sensors['S4']!;
      }

      if (newIndex != selectedSignIndex) {
        // FIX #5: setState only contains synchronous state updates
        setState(() {
          selectedSignIndex = newIndex;
          currentSensorValue = triggeredValue;
        });
        // Async TTS call lives outside setState
        _playVoiceOutput(medicalSigns[newIndex].phrase);
      }
    } catch (e) {
      debugPrint('Parsing error: $e');
    }
  }

  Future<void> _playVoiceOutput(String text) async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.speak(text);
  }

  // ── Build ────────────────────────────────────────────────────────────────────

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
                      icon: Icon(
                        isConnecting
                            ? Icons.sync
                            : (arduinoConnected
                                ? Icons.bluetooth_connected
                                : Icons.bluetooth_disabled),
                      ),
                      label: Text(
                        isConnecting
                            ? '...'
                            : (arduinoConnected ? 'Off' : 'Connect'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  GridView.builder(
                    itemCount: medicalSigns.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemBuilder: (context, index) {
                      return SignCard(
                        sign: medicalSigns[index],
                        isSelected: selectedSignIndex == index,
                        onTap: () =>
                            setState(() => selectedSignIndex = index),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const SectionHeader(
                    title: 'Live Recognition Monitor',
                    subtitle: 'Hardware stream analysis',
                  ),
                  const SizedBox(height: 10),
                  LiveMonitorCard(
                    sign: selectedSign,
                    arduinoConnected: arduinoConnected,
                    // Raw sensor value passed directly; LiveMonitorCard clamps
                    // it to the 0-1023 analog range for its progress bar.
                    currentAngle: currentSensorValue,
                  ),
                  const SizedBox(height: 14),
                  // FIX #6: onPlay callback wired to TTS
                  SpeechOutputCard(
                    sign: selectedSign,
                    onPlay: () => _playVoiceOutput(selectedSign.phrase),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widgets local to this file ──────────────────────────────────────────────

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
        gradient: const LinearGradient(
          colors: [AppTheme.clinicalBlue, AppTheme.calmCyan],
        ),
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
              _Badge(
                text: arduinoConnected ? 'Online' : 'Offline',
                icon: arduinoConnected ? Icons.check : Icons.close,
              ),
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
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
