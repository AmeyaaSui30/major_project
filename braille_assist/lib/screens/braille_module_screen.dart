import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';

class BrailleModuleScreen extends StatefulWidget {
  const BrailleModuleScreen({super.key});

  @override
  State<BrailleModuleScreen> createState() => _BrailleModuleScreenState();
}

class _BrailleModuleScreenState extends State<BrailleModuleScreen> with SingleTickerProviderStateMixin {
  String _status = 'Hardware Connected';
  String _currentText = 'Awaiting input document...';
  bool _isProcessing = false;
  double _progress = 0.0;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _simulateProcessing(String source) {
    setState(() {
      _isProcessing = true;
      _status = 'Reading $source (OCR)...';
      _currentText = 'Extracting...';
      _progress = 0.2;
    });

    Timer(const Duration(seconds: 2), () {
      setState(() {
        _status = 'Mapping text to Braille Engine...';
        _progress = 0.5;
        _currentText = 'The quick brown fox jumps over the lazy dog.';
      });

      Timer(const Duration(seconds: 2), () {
        setState(() {
          _status = 'Transmitting to IoT Device (Bluetooth)...';
          _progress = 0.8;
        });

        Timer(const Duration(seconds: 2), () {
          setState(() {
            _status = 'Tactile Output Actuated';
            _isProcessing = false;
            _progress = 1.0;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Braille pins updated successfully!'),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Visually Impaired Module', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hardware UI representation
              Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                     BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                  image: const DecorationImage(
                    image: AssetImage('assets/images/hardware_braille.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          FadeTransition(
                            opacity: _pulseController,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Colors.greenAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _status,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nexus Braille Display v1.0',
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
              
              // Progress Section
              if (_isProcessing) ...[
                Text(
                  'Processing Document...',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4C4DDC)),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Current Text View
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Extracted Text (To Braille)',
                      style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _currentText,
                      style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: FontAwesomeIcons.camera,
                      label: 'Use Camera',
                      color: const Color(0xFF4C4DDC),
                      onPressed: _isProcessing ? null : () => _simulateProcessing('Camera Image'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionButton(
                      icon: FontAwesomeIcons.solidFilePdf,
                      label: 'Upload PDF',
                      color: const Color(0xFF00C48C),
                      onPressed: _isProcessing ? null : () => _simulateProcessing('PDF Document'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: color.withOpacity(0.3),
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        shadowColor: color.withOpacity(0.4),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
