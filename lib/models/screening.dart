class Screening {
  final int? id;
  final int patientId;
  final int userId;
  final DateTime screeningDate;
  final int? painLevel;
  final String? stiffnessDuration;
  final bool? swelling;
  final String? pastInjury;
  final String? gaitData;
  final String? riskLevel;
  final double? confidence;
  final String? contributingFactors;
  final String? aiReasoning;
  final String? doctorRecommendations;
  final bool synced;

  Screening({
    this.id,
    required this.patientId,
    required this.userId,
    DateTime? screeningDate,
    this.painLevel,
    this.stiffnessDuration,
    this.swelling,
    this.pastInjury,
    this.gaitData,
    this.riskLevel,
    this.confidence,
    this.contributingFactors,
    this.aiReasoning,
    this.doctorRecommendations,
    this.synced = false,
  }) : screeningDate = screeningDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'user_id': userId,
      'screening_date': screeningDate.toIso8601String(),
      'pain_level': painLevel,
      'stiffness_duration': stiffnessDuration,
      'swelling': swelling == true ? 1 : 0,
      'past_injury': pastInjury,
      'gait_data': gaitData,
      'risk_level': riskLevel,
      'confidence': confidence,
      'contributing_factors': contributingFactors,
      'ai_reasoning': aiReasoning,
      'doctor_recommendations': doctorRecommendations,
      'synced': synced ? 1 : 0,
    };
  }

  factory Screening.fromMap(Map<String, dynamic> map) {
    return Screening(
      id: map['id'] as int?,
      patientId: map['patient_id'] as int,
      userId: map['user_id'] as int,
      screeningDate: DateTime.parse(map['screening_date'] as String),
      painLevel: map['pain_level'] as int?,
      stiffnessDuration: map['stiffness_duration'] as String?,
      swelling: (map['swelling'] as int?) == 1,
      pastInjury: map['past_injury'] as String?,
      gaitData: map['gait_data'] as String?,
      riskLevel: map['risk_level'] as String?,
      confidence: map['confidence'] as double?,
      contributingFactors: map['contributing_factors'] as String?,
      aiReasoning: map['ai_reasoning'] as String?,
      doctorRecommendations: map['doctor_recommendations'] as String?,
      synced: (map['synced'] as int?) == 1,
    );
  }

  Screening copyWith({
    int? id,
    int? patientId,
    int? userId,
    DateTime? screeningDate,
    int? painLevel,
    String? stiffnessDuration,
    bool? swelling,
    String? pastInjury,
    String? gaitData,
    String? riskLevel,
    double? confidence,
    String? contributingFactors,
    String? aiReasoning,
    String? doctorRecommendations,
    bool? synced,
  }) {
    return Screening(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      userId: userId ?? this.userId,
      screeningDate: screeningDate ?? this.screeningDate,
      painLevel: painLevel ?? this.painLevel,
      stiffnessDuration: stiffnessDuration ?? this.stiffnessDuration,
      swelling: swelling ?? this.swelling,
      pastInjury: pastInjury ?? this.pastInjury,
      gaitData: gaitData ?? this.gaitData,
      riskLevel: riskLevel ?? this.riskLevel,
      confidence: confidence ?? this.confidence,
      contributingFactors: contributingFactors ?? this.contributingFactors,
      aiReasoning: aiReasoning ?? this.aiReasoning,
      doctorRecommendations: doctorRecommendations ?? this.doctorRecommendations,
      synced: synced ?? this.synced,
    );
  }
}

enum RiskLevel {
  low,
  medium,
  high,
}

extension RiskLevelExtension on RiskLevel {
  String get value {
    switch (this) {
      case RiskLevel.low:
        return 'low';
      case RiskLevel.medium:
        return 'medium';
      case RiskLevel.high:
        return 'high';
    }
  }

  static RiskLevel fromString(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return RiskLevel.low;
      case 'medium':
        return RiskLevel.medium;
      case 'high':
        return RiskLevel.high;
      default:
        return RiskLevel.low;
    }
  }
}
