# 📡 NexusPay NFC Terminal

> **A high-fidelity NFC diagnostic tool built with Flutter**  
> Verify if your Android device can detect NFC tags in real-time. Rigorously tested on **Tecno Camon 19 series** — Nigeria’s most popular NFC-enabled smartphone.

![NFC Terminal Demo](https://via.placeholder.com/300x600/00a03c/FFFFFF?text=NFC+Terminal+Demo) <!-- Replace with actual screenshot -->

## 🔍 Features
- **Hardware Probing**: Instant detection of NFC chip availability at boot.
- **Radar Visualizer**: Custom-painted sonar animation for active scanning.
- **Haptic Feedback**: Physical pulse response upon successful tag detection.
- **Tech-Premium UI**: Dark-themed glassmorphic design with dynamic color states.
- **Device-Specific Validation**: Optimized for Tecno, Infinix, and Samsung NFC hardware.

## 🛠️ Technical Stack
- **Framework**: Flutter 3.19+
- **Language**: Dart
- **Core Plugin**: [`nfc_manager`](https://pub.dev/packages/nfc_manager) v4.0+
- **Haptics**: [`vibration`](https://pub.dev/packages/vibration)
- **Platform**: Android 9.0+ (NFC required)

## 📱 How It Works
1. Launch the app on an NFC-capable Android device
2. Watch the **amber radar pulse** scan for tags
3. Bring an NFC card/device near the phone’s back
4. On detection:
   - Radar turns **emerald green**
   - Haptic engine pulses
   - Status updates to **“NFC Device Detected”**

## 🧪 Tested Devices
| Device | NFC Support | Result |
|--------|-------------|--------|
| **Tecno Camon 19 Pro** | ✅ Yes | Full functionality |
| **Infinix Note 30** | ✅ Yes | Full functionality |
| **Samsung Galaxy A14** | ✅ Yes | Full functionality |
| **iPhone 14** | ❌ No | Not supported (iOS restrictions) |

## 🚀 Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/terfah/nexuspay-nfc-terminal.git
   cd nexuspay-nfc-terminal
   ```
2. Instal dependencies:
   ```bash
   flutter pub get
   ```
3. Run on an NFC-enabled Android device:
   ```bash
   flutter run --release
   ```

## 👨‍💻 Developer
Terfa Binda
Mobile Systems Developer
📧 terfa.binda@gmail.com | 📞 +234 807 085 0317

## 📜 License
This project is licensed under the MIT License — see the LICENSE file for details.
“Engineering excellence begins with hardware-aware software.”
— Terfa Binda