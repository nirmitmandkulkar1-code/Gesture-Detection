# Gesture-Detection (GestureCare Voice Console)

An assistive technology prototype designed for non-verbal patients in hospital settings. This system translates hand gestures (detected by flex sensors) into real-time speech through a mobile application via Bluetooth.

## 📂 Project Structure

- **App/**: The Flutter-based mobile dashboard.
- **Arduino/**: C++ code for sensor processing and DFPlayer Mini (hardware audio).
- **lib/services/**: Contains the Bluetooth and Logic bridge.

---

## 🛠️ Hardware Requirements

### Components
- **Arduino Uno** (Microcontroller)
- **HC-05 or HC-06** (Bluetooth Module)
- **4x Flex Sensors** (For finger/palm gesture detection)
- **DFPlayer Mini + Speaker** (For hardware-level audio feedback)
- **16x2 LCD I2C** (For local command display)
- **Resistors** (10kΩ for flex sensor voltage dividers; 1kΩ/2kΩ for HC-05 RX level shifting)

### Wiring Diagram (Reference)
| Component | Arduino Pin |
| :--- | :--- |
| **Flex Sensor 1** | A0 |
| **Flex Sensor 2** | A1 |
| **Flex Sensor 3** | A2 |
| **Flex Sensor 4** | A3 |
| **Bluetooth RX** | Pin 1 (TX) *via level shifter* |
| **Bluetooth TX** | Pin 0 (RX) |
| **DFPlayer TX/RX**| Pins 2 & 3 (SoftwareSerial) |
| **LCD I2C** | A4 (SDA) & A5 (SCL) |

---

## 🚀 How to Run the Project

### 1. Hardware Initialization (Arduino)
1. Navigate to the `Arduino/` folder.
2. Open the `.ino` file in the Arduino IDE.
3. Install dependencies:
   - `LiquidCrystal_I2C`
   - `DFRobotDFPlayerMini`
4. Connect the Arduino and **Upload** the code. 
   - *Note: Disconnect the Bluetooth module's RX/TX wires during upload to avoid serial conflicts.*
5. Open Serial Monitor at **115200 baud** to verify sensor data output (`S1:XXX, S2:YYY...`).

### 2. Mobile App Setup (Flutter)
1. Navigate to the `Frontend/` or `App/` folder in your terminal.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Ensure you have the `flutter_bluetooth_serial` and `flutter_tts packages` configured.
4. Android Permissions: Ensure the AndroidManifest.xml includes Bluetooth and Location permissions.
5. Build and Install 
    ```bash
    flutter run
    ```

---

### 3. Syncing the System
1. Pair your phone with the HC-05 module in your phone's system Bluetooth settings (Default PIN: `1234`).
2. Open the app and click "Connect".
3. Once connected, the Live Recognition Monitor will begin updating with the Arduino's raw sensor units.
4. Bending the flex sensors will highlight the corresponding Medical Sign Card and trigger the Text-to-Speech output.

---

## 📱 Features
- Real-time Recognition: Low-latency data stream from sensors.
- Smart Parsing: Buffer-based serial parsing to prevent data corruption.
- Speech Synthesis: Mobile TTS announces commands for hospital staff.
- Dual Feedback: LCD + Hardware Speaker (Arduino side) and UI + Mobile Speaker (App side).

## 🔧 Configuration & Calibration
To adjust the sensitivity of the gestures, modify the thresholds in the 
`_processArduinoCommand` function inside `lib/screens/home_screen.dart`:
```Dart
if (sensors['S1']! > 310) // Change '310' to match your sensor's flex range
```

**Author:** Nirmit Mandkulkar
**Version:** 1.0.0

---

### Quick Tip for Testing
When you first run the hardware, the numbers might fluctuate based on how tightly you've sewn or taped the flex sensors. Check the **Live Recognition Monitor** in the app to see your "Resting" value versus your "Flexed" value, then update the thresholds in the code for a perfect match!
