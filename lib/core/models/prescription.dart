class Prescription {
  final int? id;
  final int patientId;
  final int doctorId;
  final String prescription;
  final DateTime createdAt;

  Prescription({
    this.id,
    required this.patientId,
    required this.doctorId,
    required this.prescription,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Prescription.fromMap(Map<String, dynamic> map) {
    return Prescription(
      id: map['id'] as int?,
      patientId: map['patient_id'] as int,
      doctorId: map['doctor_id'] as int,
      prescription: map['prescription'] as String,
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'patient_id': patientId,
      'doctor_id': doctorId,
      'prescription': prescription,
      'created_at': createdAt.toIso8601String(),
    };

    if (id != null) map['id'] = id;

    return map;
  }

  @override
  String toString() {
    return 'Prescription(id: $id, patientId: $patientId, doctorId: $doctorId, prescription: $prescription, createdAt: $createdAt)';
  }
}
