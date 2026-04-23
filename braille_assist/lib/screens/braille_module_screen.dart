import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class BrailleModuleScreen extends StatefulWidget {
  const BrailleModuleScreen({super.key});

  @override
  State<BrailleModuleScreen> createState() => _BrailleModuleScreenState();
}

class _BrailleModuleScreenState extends State<BrailleModuleScreen>
    with SingleTickerProviderStateMixin {
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

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        _processInputForBraille(image.path, 'Camera Image');
      }
    } catch (e) {
      debugPrint("Camera error: $e");
    }
  }

  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.single.path != null) {
        _processInputForBraille(result.files.single.path!, 'PDF Document');
      }
    } catch (e) {
      debugPrint("File picker error: $e");
    }
  }

  void _processInputForBraille(String filePath, String source) {
    setState(() {
      _isProcessing = true;
      _status = 'Reading $source...';
      _currentText = 'File: ${filePath.split("/").last}';
      _progress = 0.3;
    });

    // TODO(USER): IMPLEMENT AIML TO IOT BACKEND HERE
    // This is the placeholder where you should send `filePath`
    // to your ML backend and trigger your IoT logic.

    Timer(const Duration(seconds: 3), () {
      setState(() {
        _status = 'Transmitting to IoT Device (AIML)...';
        _progress = 0.8;
      });

      Timer(const Duration(seconds: 2), () {
        if (!mounted) return;
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
                Text('Transmission to IoT device simulated.'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'TriConnect',
          style: TextStyle(
            color: Color(0xFFB19CD9),
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 20, color: Color(0xFF2D2D2D)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Module Title
              Text(
                'Touch Output',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Convert documents to tactile signals',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),

              // Hardware UI representation
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFF0E8FF), width: 2),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [const Color(0xFFF9F6FF), Colors.white],
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
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: const Color(0xFF2D2D2D)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nexus Braille Display v1.0',
                        style: GoogleFonts.outfit(
                            color: Colors.grey.shade600, fontSize: 12),
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
                  style: GoogleFonts.outfit(
                      color: const Color(0xFF2D2D2D),
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFF0E8FF),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFFB19CD9)),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Current Text View
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Extracted Text (To Braille)',
                      style: GoogleFonts.outfit(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _currentText,
                      style: GoogleFonts.outfit(
                          color: const Color(0xFF2D2D2D),
                          fontSize: 18,
                          height: 1.5),
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
                      color: const Color(0xFFB19CD9),
                      onPressed: _isProcessing ? null : _pickImage,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionButton(
                      icon: FontAwesomeIcons.solidFilePdf,
                      label: 'Upload PDF',
                      color: const Color(0xFFD4C4FB),
                      textColor: const Color(0xFF2D2D2D),
                      onPressed: _isProcessing ? null : _pickPDF,
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
    Color textColor = Colors.white,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: color.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
      child: Column(
        children: [
          Icon(icon, color: textColor, size: 28),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.outfit(
                color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
