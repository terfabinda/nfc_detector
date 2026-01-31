/**
 * Project: NexusPay NFC Terminal
 * Description: A high-tech hardware diagnostic tool for NFC capability.
 * Developer: Terfa Binda
 * License: MIT
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const NexusPayApp());
}

class NexusPayApp extends StatelessWidget {
  const NexusPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexusPay Terminal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyanAccent,
          brightness: Brightness.dark,
        ),
      ),
      home: const NFCDashboard(),
    );
  }
}

class NFCDashboard extends StatefulWidget {
  const NFCDashboard({super.key});

  @override
  State<NFCDashboard> createState() => _NFCDashboardState();
}

class _NFCDashboardState extends State<NFCDashboard>
    with SingleTickerProviderStateMixin {
  bool _isChecking = true;
  bool _isNFCSupported = false;
  bool _isTagDetected = false;
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _initNFC();
  }

  @override
  void dispose() {
    _radarController.dispose();
    NfcManager.instance.stopSession();
    super.dispose();
  }

  Future<void> _initNFC() async {
    try {
      bool isAvailable = await NfcManager.instance.isAvailable();
      setState(() {
        _isNFCSupported = isAvailable;
        _isChecking = false;
      });
      if (isAvailable) _startScanning();
    } catch (e) {
      setState(() {
        _isNFCSupported = false;
        _isChecking = false;
      });
    }
  }

  void _startScanning() {
    NfcManager.instance.startSession(
      pollingOptions: {NfcPollingOption.iso14443, NfcPollingOption.iso15693},
      onDiscovered: (NfcTag tag) async {
        HapticFeedback.vibrate();
        setState(() => _isTagDetected = true);

        await Future.delayed(const Duration(milliseconds: 200));
        HapticFeedback.lightImpact();

        await Future.delayed(const Duration(seconds: 3));
        if (mounted) setState(() => _isTagDetected = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: _isChecking
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.cyanAccent,
                          ),
                        )
                      : !_isNFCSupported
                      ? _buildNoNFCView()
                      : _buildScannerView(),
                ),
                _buildDeveloperFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "NEXUS",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  color: Colors.cyanAccent,
                ),
              ),
              Text(
                "TERMINAL",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isNFCSupported
                  ? Colors.greenAccent.withOpacity(0.1)
                  : Colors.redAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isNFCSupported ? Colors.greenAccent : Colors.redAccent,
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 4,
                  backgroundColor: _isNFCSupported
                      ? Colors.greenAccent
                      : Colors.redAccent,
                ),
                const SizedBox(width: 8),
                Text(
                  _isNFCSupported ? "NFC ACTIVE" : "NFC OFF",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _isNFCSupported
                        ? Colors.greenAccent
                        : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (!_isTagDetected)
              AnimatedBuilder(
                animation: _radarController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: RadarPainter(_radarController.value),
                    size: const Size(300, 300),
                  );
                },
              ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isTagDetected
                    ? Colors.greenAccent
                    : Colors.cyanAccent.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color: _isTagDetected
                        ? Colors.greenAccent.withOpacity(0.5)
                        : Colors.cyanAccent.withOpacity(0.2),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                _isTagDetected ? Icons.check_rounded : Icons.nfc_rounded,
                size: 80,
                color: _isTagDetected ? Colors.white : Colors.cyanAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 60),
        Text(
          _isTagDetected ? "IDENTITY VERIFIED" : "SCANNING FOR SIGNAL",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            _isTagDetected
                ? "NFC Data packet captured successfully."
                : "Place your device near a card, tag, or another NFC phone.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoNFCView() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(30),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 60,
              color: Colors.orangeAccent,
            ),
            const SizedBox(height: 20),
            const Text(
              "HARDWARE MISMATCH",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "NFC controller not found. This variant of the device may not support NFC hardware.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperFooter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Text(
            "DEVELOPED BY",
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 2,
              color: Colors.white.withOpacity(0.3),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "TERFA BINDA",
            style: TextStyle(
              fontSize: 14,
              letterSpacing: 4,
              color: Colors.cyanAccent.withOpacity(0.7),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class RadarPainter extends CustomPainter {
  final double animationValue;
  RadarPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.cyanAccent.withOpacity(1.0 - animationValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 3; i++) {
      double value = (animationValue + (i / 3)) % 1.0;
      canvas.drawCircle(center, size.width / 2 * value, paint);
    }
  }

  @override
  bool shouldRepaint(RadarPainter oldDelegate) => true;
}
