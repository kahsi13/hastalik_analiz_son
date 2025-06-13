// lib/models/diagnosis_model.dart
class Diagnosis {
  final int? id;
  final String label;
  final double confidence;
  final String timestamp;
  final String imageBase64;

  Diagnosis({
    this.id,
    required this.label,
    required this.confidence,
    required this.timestamp,
    required this.imageBase64,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'confidence': confidence,
      'timestamp': timestamp,
      'imageBase64': imageBase64,
    };
  }

  factory Diagnosis.fromMap(Map<String, dynamic> map) {
    return Diagnosis(
      id: map['id'] as int?,
      label: map['label'] as String,
      confidence: map['confidence'] is int ? (map['confidence'] as int).toDouble() : map['confidence'],
      timestamp: map['timestamp'] as String,
      imageBase64: map['imageBase64'] as String,
    );
  }
}
