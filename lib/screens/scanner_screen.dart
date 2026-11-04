import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';

import '../app.dart';
import 'result_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late final MobileScannerController _controller;
  bool _isNavigating = false;
  bool _torchEnabled = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      autoStart: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isNavigating) return;

    String? content;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue?.trim();
      if (value != null && value.isNotEmpty && !_hasControlCharacters(value)) {
        content = value;
        break;
      }
    }
    if (content == null) return;

    _isNavigating = true;
    try {
      await _controller.stop();
    } catch (_) {
      // Continue to the result even if the camera could not be paused.
    }
    if (!mounted) return;

    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ResultScreen(decodedContent: content!),
      ),
    );

    if (!mounted) return;
    _isNavigating = false;
    try {
      await _controller.start();
    } catch (_) {
      // The camera error builder below presents initialization failures.
    }
  }

  bool _hasControlCharacters(String value) {
    return value.codeUnits.any((unit) => unit < 0x20 && unit != 0x09);
  }

  Future<void> _scanFromGallery() async {
    if (_isNavigating) return;
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null || !mounted) return;
      final capture = await _controller.analyzeImage(image.path);
      if (!mounted) return;
      String? content;
      for (final barcode in capture?.barcodes ?? const <Barcode>[]) {
        final value = barcode.rawValue?.trim();
        if (value != null && value.isNotEmpty && !_hasControlCharacters(value)) {
          content = value;
          break;
        }
      }
      if (content == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No readable QR code found in this image. Try a clearer image.')),
        );
        return;
      }
      _isNavigating = true;
      await Navigator.of(context).push<void>(
        MaterialPageRoute(builder: (_) => ResultScreen(decodedContent: content!)),
      );
      if (mounted) _isNavigating = false;
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not scan this image. Please try another image.')),
      );
    }
  }

  Future<void> _toggleTorch() async {
    try {
      await _controller.toggleTorch();
      if (mounted) setState(() => _torchEnabled = !_torchEnabled);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The flashlight is not available.')),
      );
    }
  }

  Future<void> _retryCamera() async {
    try {
      await _controller.start();
    } catch (_) {
      // MobileScanner's errorBuilder remains visible if startup fails.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: QRGuardTheme.navy,
        leading: IconButton(
          tooltip: 'Go back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Scan QR from gallery',
            icon: const Icon(Icons.photo_library_outlined),
            onPressed: _scanFromGallery,
          ),
          IconButton(
            tooltip: _torchEnabled ? 'Turn flashlight off' : 'Turn flashlight on',
            icon: Icon(
              _torchEnabled ? Icons.flashlight_off_rounded : Icons.flashlight_on_rounded,
            ),
            onPressed: _toggleTorch,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) {
              final errorText = error.toString().toLowerCase();
              final permissionDenied = errorText.contains('permission') ||
                  errorText.contains('denied');
              return _CameraErrorView(
                permissionDenied: permissionDenied,
                onRetry: _retryCamera,
              );
            },
          ),
          IgnorePointer(
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 264,
                  height: 264,
                  decoration: BoxDecoration(
                    border: Border.all(color: QRGuardTheme.teal, width: 3),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(color: Colors.black38, blurRadius: 24),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: QRGuardTheme.navy.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(QRGuardTheme.radiusMd),
                  ),
                  child: Text(
                    'Place a QR code inside the frame to scan it.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: QRGuardTheme.textPrimary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraErrorView extends StatelessWidget {
  const _CameraErrorView({
    required this.permissionDenied,
    required this.onRetry,
  });

  final bool permissionDenied;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: QRGuardTheme.navy,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                permissionDenied ? Icons.no_photography_rounded : Icons.camera_alt_rounded,
                size: 56,
                color: QRGuardTheme.teal,
              ),
              const SizedBox(height: 20),
              Text(
                permissionDenied ? 'Camera permission needed' : 'Camera unavailable',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                permissionDenied
                    ? 'Allow camera access in your device settings to scan QR codes.'
                    : 'QRGuard could not start the camera. Check that no other app is using it, then retry.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: QRGuardTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry camera'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
