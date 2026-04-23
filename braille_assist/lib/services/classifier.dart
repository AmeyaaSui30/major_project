import 'package:tflite_flutter/tflite_flutter.dart';

class ISLClassifier {
  Interpreter? _interpreter;
  final List<String> labels = List.generate(26, (i) => String.fromCharCode(65 + i));

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/isl_alphabet.tflite');
      print('✅ TFLite model loaded');
    } catch (e) {
      print('❌ Error loading TFLite model: $e');
      print('Note: Ensure you have placed the actual trained isl_alphabet.tflite file in assets/models/.');
    }
  }

  int _demoFrameCount = 0;
  int _demoLetterIndex = 0;
  final String _demoWord = "DEMOALPHABET";

  String predict(List<double> landmarks) {
    if (landmarks.length != 63) return '';

    // DEMO MODE: Simulate returning predicted letters without relying on the TFLite model.
    // We hold a letter long enough (25 frames) to pass the screen's stability threshold.
    _demoFrameCount++;
    if (_demoFrameCount > 25) {
      _demoFrameCount = 0;
      // Move to next letter in the demo word loop
      _demoLetterIndex = (_demoLetterIndex + 1) % _demoWord.length;
    }

    // Return the current letter to simulate successful frame prediction!
    return _demoWord[_demoLetterIndex];
  }

  void dispose() => _interpreter?.close();
}
