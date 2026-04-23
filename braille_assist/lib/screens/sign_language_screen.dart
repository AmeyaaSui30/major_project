import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

import '../services/classifier.dart';
import '../services/hand_landmark_service.dart';

class SignLanguageScreen extends StatefulWidget {
  const SignLanguageScreen({super.key});

  @override
  State<SignLanguageScreen> createState() => _SignLanguageScreenState();
}

class _SignLanguageScreenState extends State<SignLanguageScreen> {
  CameraController? _cameraController;
  final ISLClassifier _classifier = ISLClassifier();
  final HandLandmarkService _landmarkService = HandLandmarkService();

  String _detectedLetter = '';
  String _sentence = '';
  String _lastLetter = '';
  bool _isProcessing = false;
  int _stableFrameCount = 0;
  static const int _stableThreshold = 15; // frames before confirming letter

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _classifier.loadModel();
    final cameras = await availableCameras();

    CameraDescription? targetCamera;

    // Attempt to select the front camera natively
    try {
      targetCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );
    } catch (e) {
      if (cameras.isNotEmpty) {
        targetCamera = cameras.first;
      }
    }

    if (targetCamera != null) {
      _cameraController = CameraController(
        targetCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      try {
        await _cameraController!.initialize();
        if (mounted) {
          _cameraController!.startImageStream(_processFrame);
          setState(() {});
        }
      } catch (e) {
        print('Camera error: $e');
      }
    }
  }

  void _processFrame(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final rotation = _cameraController!.description.sensorOrientation;
      final landmarks =
          await _landmarkService.extractLandmarks(image, rotation);

      if (landmarks != null) {
        final letter = _classifier.predict(landmarks);

        if (letter.isNotEmpty) {
          if (letter == _lastLetter) {
            _stableFrameCount++;
            if (_stableFrameCount == _stableThreshold) {
              // Confirmed letter — add to sentence
              if (mounted) {
                setState(() {
                  _detectedLetter = letter;
                  _sentence += letter;
                });
              }
            }
          } else {
            _stableFrameCount = 0;
            _lastLetter = letter;
            if (mounted) {
              setState(() => _detectedLetter = letter);
            }
          }
        } else {
          if (mounted) setState(() => _detectedLetter = '');
          _stableFrameCount = 0;
        }
      } else {
        if (mounted) setState(() => _detectedLetter = '');
      }
    } finally {
      if (mounted) _isProcessing = false;
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _classifier.dispose();
    _landmarkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151521), // App theme background
      appBar: AppBar(
        title: Text('ISL \u2192 Text',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Camera Preview
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: const Color(0xFF1E1E2C), // Surface color
                border: Border.all(
                    color: const Color(0xFF4C4DDC).withOpacity(0.3), width: 1),
              ),
              child: _cameraController?.value.isInitialized == true
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        CameraPreview(_cameraController!),
                        // Live letter overlay
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4C4DDC).withOpacity(0.85),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _detectedLetter.isEmpty ? '?' : _detectedLetter,
                              style: const TextStyle(
                                fontSize: 48,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF4C4DDC)),
                    ),
            ),
          ),

          // Sentence Builder
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E2C),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sentence:',
                    style: GoogleFonts.outfit(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _sentence.isEmpty ? 'Start signing...' : _sentence,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight:
                          _sentence.isEmpty ? FontWeight.w300 : FontWeight.w500,
                      fontStyle: _sentence.isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => setState(() => _sentence =
                            _sentence.isEmpty
                                ? ''
                                : _sentence.substring(0, _sentence.length - 1)),
                        icon: const Icon(Icons.backspace,
                            color: Colors.orangeAccent),
                        label: const Text('Delete',
                            style: TextStyle(color: Colors.orangeAccent)),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => setState(() => _sentence += ' '),
                        icon: const Icon(Icons.space_bar,
                            color: Colors.lightBlue),
                        label: const Text('Space',
                            style: TextStyle(color: Colors.lightBlue)),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => setState(() => _sentence = ''),
                        icon: const Icon(Icons.clear, color: Colors.redAccent),
                        label: const Text('Clear',
                            style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
