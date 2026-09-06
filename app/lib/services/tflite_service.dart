import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:flutter/foundation.dart';

class TFLiteService {
  static TFLiteService? _instance;
  tfl.Interpreter? _interpreter;
  bool _isModelLoaded = false;

  factory TFLiteService() {
    _instance ??= TFLiteService._internal();
    return _instance!;
  }

  TFLiteService._internal();

  bool get isModelLoaded => _isModelLoaded;

  Future<void> loadModel() async {
    if (_isModelLoaded) return;

    try {
      // Load the TFLite model
      // Note: You need to place your .tflite model in assets/models/
      // For this example, we'll use a placeholder approach
      _interpreter = await tfl.Interpreter.fromAsset('assets/models/oa_risk_model.tflite');
      _isModelLoaded = true;
      debugPrint('TFLite model loaded successfully');
    } catch (e) {
      debugPrint('Error loading TFLite model: $e');
      // For development, we'll use a fallback rule-based approach
      _isModelLoaded = false;
    }
  }

  Future<RiskPrediction> predictRisk({
    required int painLevel,
    required String stiffnessDuration,
    required bool swelling,
    required String? pastInjury,
    required List<double> gaitFeatures,
  }) async {
    try {
      if (_isModelLoaded && _interpreter != null) {
        return await _predictWithModel(
          painLevel: painLevel,
          stiffnessDuration: stiffnessDuration,
          swelling: swelling,
          pastInjury: pastInjury,
          gaitFeatures: gaitFeatures,
        );
      } else {
        // Fallback to rule-based prediction
        return _predictWithRules(
          painLevel: painLevel,
          stiffnessDuration: stiffnessDuration,
          swelling: swelling,
          pastInjury: pastInjury,
          gaitFeatures: gaitFeatures,
        );
      }
    } catch (e) {
      debugPrint('Error predicting risk: $e');
      // Return default low risk on error
      return RiskPrediction(
        riskLevel: 'low',
        confidence: 0.5,
        contributingFactors: [],
        reasoning: 'Unable to analyze due to error. Please try again.',
      );
    }
  }

  Future<RiskPrediction> _predictWithModel({
    required int painLevel,
    required String stiffnessDuration,
    required bool swelling,
    required String? pastInjury,
    required List<double> gaitFeatures,
  }) async {
    // Prepare input features
    // Normalize features based on your model's expected input
    final input = _prepareInputFeatures(
      painLevel: painLevel,
      stiffnessDuration: stiffnessDuration,
      swelling: swelling,
      pastInjury: pastInjury,
      gaitFeatures: gaitFeatures,
    );

    // Prepare output buffer
    final output = List<double>.filled(3, 0).reshape([1, 3]);

    // Run inference
    _interpreter!.run(input, output);

    // Process output
    final probabilities = output[0];
    final maxIndex = probabilities.indexOf(probabilities.reduce((a, b) => a > b ? a : b));
    
    final riskLevels = ['low', 'medium', 'high'];
    final predictedRisk = riskLevels[maxIndex];
    final confidence = probabilities[maxIndex];

    final contributingFactors = _identifyContributingFactors(
      painLevel: painLevel,
      stiffnessDuration: stiffnessDuration,
      swelling: swelling,
      pastInjury: pastInjury,
      gaitFeatures: gaitFeatures,
    );

    return RiskPrediction(
      riskLevel: predictedRisk,
      confidence: confidence,
      contributingFactors: contributingFactors,
      reasoning: _generateReasoning(predictedRisk, contributingFactors, confidence),
    );
  }

  RiskPrediction _predictWithRules({
    required int painLevel,
    required String stiffnessDuration,
    required bool swelling,
    required String? pastInjury,
    required List<double> gaitFeatures,
  }) {
    // Rule-based prediction as fallback
    double riskScore = 0;
    List<String> factors = [];

    // Pain level contribution (0-10)
    riskScore += painLevel * 0.3;
    if (painLevel >= 7) {
      factors.add('High pain level');
    } else if (painLevel >= 4) factors.add('Moderate pain level');

    // Stiffness duration contribution
    final stiffnessMinutes = _parseStiffnessDuration(stiffnessDuration);
    if (stiffnessMinutes > 30) {
      riskScore += 2.0;
      factors.add('Prolonged morning stiffness');
    } else if (stiffnessMinutes > 15) {
      riskScore += 1.0;
      factors.add('Morning stiffness');
    }

    // Swelling contribution
    if (swelling) {
      riskScore += 1.5;
      factors.add('Joint swelling');
    }

    // Past injury contribution
    if (pastInjury != null && pastInjury.isNotEmpty) {
      riskScore += 1.0;
      factors.add('History of joint injury');
    }

    // Gait analysis contribution (if available)
    if (gaitFeatures.isNotEmpty) {
      final gaitScore = _analyzeGaitFeatures(gaitFeatures);
      riskScore += gaitScore;
      if (gaitScore > 1.0) factors.add('Abnormal gait pattern detected');
    }

    // Determine risk level based on score
    String riskLevel;
    double confidence;
    
    if (riskScore >= 5.0) {
      riskLevel = 'high';
      confidence = 0.85;
    } else if (riskScore >= 3.0) {
      riskLevel = 'medium';
      confidence = 0.75;
    } else {
      riskLevel = 'low';
      confidence = 0.70;
    }

    return RiskPrediction(
      riskLevel: riskLevel,
      confidence: confidence,
      contributingFactors: factors,
      reasoning: _generateReasoning(riskLevel, factors, confidence),
    );
  }

  List<List<double>> _prepareInputFeatures({
    required int painLevel,
    required String stiffnessDuration,
    required bool swelling,
    required String? pastInjury,
    required List<double> gaitFeatures,
  }) {
    // Normalize and prepare input features for the model
    // This is a placeholder - adjust based on your actual model's input requirements
    final stiffnessMinutes = _parseStiffnessDuration(stiffnessDuration);
    final hasPastInjury = pastInjury != null && pastInjury.isNotEmpty ? 1.0 : 0.0;
    
    // Normalize pain level to 0-1
    final normalizedPain = painLevel / 10.0;
    
    // Normalize stiffness to 0-1 (assuming max 60 minutes)
    final normalizedStiffness = (stiffnessMinutes / 60.0).clamp(0.0, 1.0);
    
    // Combine features
    final features = [
      normalizedPain,
      normalizedStiffness,
      swelling ? 1.0 : 0.0,
      hasPastInjury,
      ...gaitFeatures.take(10), // Take first 10 gait features
    ];
    
    // Pad or truncate to match model input size
    const inputSize = 20;
    while (features.length < inputSize) {
      features.add(0.0);
    }
    
    // Create 2D list for model input
    return [features.take(inputSize).toList()];
  }

  int _parseStiffnessDuration(String duration) {
    // Parse stiffness duration string to minutes
    // Expected format: "30 minutes" or just "30"
    final regex = RegExp(r'\d+');
    final match = regex.firstMatch(duration);
    if (match != null) {
      return int.parse(match.group(0)!);
    }
    return 0;
  }

  double _analyzeGaitFeatures(List<double> gaitFeatures) {
    // Analyze gait features and return a risk contribution score
    if (gaitFeatures.isEmpty) return 0.0;
    
    // Calculate variance in accelerometer data
    final mean = gaitFeatures.reduce((a, b) => a + b) / gaitFeatures.length;
    final variance = gaitFeatures.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) / gaitFeatures.length;
    
    // High variance might indicate irregular gait
    if (variance > 0.5) return 1.5;
    if (variance > 0.3) return 1.0;
    return 0.5;
  }

  List<String> _identifyContributingFactors({
    required int painLevel,
    required String stiffnessDuration,
    required bool swelling,
    required String? pastInjury,
    required List<double> gaitFeatures,
  }) {
    final factors = <String>[];
    
    if (painLevel >= 7) factors.add('Severe pain symptoms');
    if (painLevel >= 4 && painLevel < 7) factors.add('Moderate pain symptoms');
    
    final stiffnessMinutes = _parseStiffnessDuration(stiffnessDuration);
    if (stiffnessMinutes > 30) factors.add('Extended morning stiffness');
    if (stiffnessMinutes > 15) factors.add('Morning stiffness present');
    
    if (swelling) factors.add('Joint swelling observed');
    
    if (pastInjury != null && pastInjury.isNotEmpty) {
      factors.add('Previous joint injury history');
    }
    
    if (gaitFeatures.isNotEmpty) {
      final gaitScore = _analyzeGaitFeatures(gaitFeatures);
      if (gaitScore > 1.0) factors.add('Gait irregularities detected');
    }
    
    return factors;
  }

  String _generateReasoning(String riskLevel, List<String> factors, double confidence) {
    final buffer = StringBuffer();
    
    buffer.writeln('Based on the analysis of symptoms and gait patterns:');
    buffer.writeln();
    
    if (factors.isNotEmpty) {
      buffer.writeln('Key contributing factors:');
      for (final factor in factors) {
        buffer.writeln('• $factor');
      }
      buffer.writeln();
    }
    
    switch (riskLevel) {
      case 'high':
        buffer.writeln('The patient shows strong indicators of osteoarthritis risk.');
        buffer.writeln('Immediate medical consultation is recommended.');
        buffer.writeln('Consider referral to a specialist for further evaluation.');
        break;
      case 'medium':
        buffer.writeln('The patient shows moderate indicators of osteoarthritis risk.');
        buffer.writeln('Regular monitoring and preventive measures are advised.');
        buffer.writeln('Lifestyle modifications may help slow progression.');
        break;
      case 'low':
        buffer.writeln('The patient shows minimal indicators of osteoarthritis risk.');
        buffer.writeln('Continue regular health monitoring.');
        buffer.writeln('Maintain healthy lifestyle practices for joint health.');
        break;
    }
    
    buffer.writeln();
    buffer.writeln('Analysis confidence: ${(confidence * 100).toStringAsFixed(1)}%');
    
    return buffer.toString();
  }

  void dispose() {
    _interpreter?.close();
    _isModelLoaded = false;
  }
}

class RiskPrediction {
  final String riskLevel;
  final double confidence;
  final List<String> contributingFactors;
  final String reasoning;

  RiskPrediction({
    required this.riskLevel,
    required this.confidence,
    required this.contributingFactors,
    required this.reasoning,
  });

  Map<String, dynamic> toJson() {
    return {
      'risk_level': riskLevel,
      'confidence': confidence,
      'contributing_factors': contributingFactors,
      'reasoning': reasoning,
    };
  }

  factory RiskPrediction.fromJson(Map<String, dynamic> json) {
    return RiskPrediction(
      riskLevel: json['risk_level'] as String,
      confidence: json['confidence'] as double,
      contributingFactors: List<String>.from(json['contributing_factors'] as List),
      reasoning: json['reasoning'] as String,
    );
  }
}
