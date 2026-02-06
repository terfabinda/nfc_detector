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

enum NFCState { checking, supported, unsupported }

class NFCDashboard extends StatefulWidget {
  const NFCDashboard({super.key});

  @override
  State<NFCDashboard> createState() => _NFCDashboardState();
}

class _NFCDashboardState extends State<NFCDashboard>
    with SingleTickerProviderStateMixin {
  NFCState _state = NFCState.checking;
  bool _isTagDetected = false;
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
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
    // Add a slight delay so the user sees the "Scanning for Hardware" animation
    await Future.delayed(const Duration(seconds: 2));

    try {
      bool isAvailable = await NfcManager.instance.isAvailable();
      if (mounted) {
        setState(() {
          _state = isAvailable ? NFCState.supported : NFCState.unsupported;
        });
      }
      if (isAvailable) _startScanning();
    } catch (e) {
      if (mounted) setState(() => _state = NFCState.unsupported);
    }
  }

  void _startScanning() {
    NfcManager.instance.startSession(
      pollingOptions: {NfcPollingOption.iso14443, NfcPollingOption.iso15693},
      onDiscovered: (NfcTag tag) async {
        HapticFeedback.vibrate();
        setState(() => _isTagDetected = true);
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
          // Background Gradient
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
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 800),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: animation,
                              child: child,
                            ),
                          );
                        },
                    child: _buildMainContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    // Use KeyedSubtree or Keys so AnimatedSwitcher knows when to swap
    switch (_state) {
      case NFCState.checking:
        return _buildStatusView(
          key: const ValueKey('checking'),
          icon: Icons.search_rounded,
          title: "INITIALIZING",
          subtitle: "Checking hardware communication links...",
          color: Colors.cyanAccent,
          showRadar: true,
        );
      case NFCState.unsupported:
        return _buildStatusView(
          key: const ValueKey('unsupported'),
          icon: Icons.portable_wifi_off_rounded,
          title: "HARDWARE FAILURE",
          subtitle: "This device does not support NFC or it is disabled.",
          color: Colors.redAccent,
          showRadar: false,
        );
      case NFCState.supported:
        return _buildScannerView(key: const ValueKey('active'));
    }
  }

  Widget _buildStatusView({
    required Key key,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool showRadar,
  }) {
    return Column(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (showRadar)
              AnimatedBuilder(
                animation: _radarController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: RadarPainter(_radarController.value, color),
                    size: const Size(300, 300),
                  );
                },
              ),
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Icon(icon, size: 60, color: color),
            ),
          ],
        ),
        const SizedBox(height: 50),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            color: color,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildScannerView({required Key key}) {
    return Column(
      key: key,
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
                    painter: RadarPainter(
                      _radarController.value,
                      Colors.cyanAccent,
                    ),
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
          _isTagDetected ? "IDENTITY VERIFIED" : "SCANNING SIGNAL",
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
                : "Hold your device near a compatible NFC tag.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    bool isActive = _state == NFCState.supported;
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.greenAccent.withOpacity(0.1)
                  : Colors.redAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive ? Colors.greenAccent : Colors.redAccent,
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 4,
                  backgroundColor: isActive
                      ? Colors.greenAccent
                      : Colors.redAccent,
                ),
                const SizedBox(width: 8),
                Text(
                  isActive ? "ACTIVE" : "INACTIVE",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.greenAccent : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RadarPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  RadarPainter(this.animationValue, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 0; i < 3; i++) {
      double value = (animationValue + (i / 3)) % 1.0;
      final paint = Paint()
        ..color = color.withOpacity(1.0 - value)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(center, size.width / 2 * value, paint);
    }
  }

  @override
  bool shouldRepaint(RadarPainter oldDelegate) => true;
}
