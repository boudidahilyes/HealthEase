class PrescriptionDto {
  final int? id;
  final int patientId;
  final int doctorId;
  final DateTime createdAt;
  final String description;
  final List<Medicine> medicines;

  PrescriptionDto({
    this.id,
    required this.patientId,
    required this.doctorId,
    required this.createdAt,
    required this.description,
    required this.medicines,
  });

  factory PrescriptionDto.fromMap(Map<String, dynamic> json) {
    return PrescriptionDto(
      id: json['id'],
      patientId: json['patientId'],
      doctorId: json['doctorId'],
      createdAt: DateTime.parse(json['createdAt']),
      description: json['description'],
      medicines: (json['medicines'] as List)
          .map((medicine) => Medicine.fromMap(medicine))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'createdAt': createdAt.toIso8601String(),
      'description': description,
      'medicines': medicines.map((medicine) => medicine.toMap()).toList(),
    };
  }
  @override
  String toString() {
    return '{"id": $id, "patientId": $patientId, "doctorId": $doctorId, "createdAt": "$createdAt", "description": $description, "medicines": $medicines}';
  }

}

class Medicine {
  final int? id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final int dosePerDay;
  final int mgPerDose;
  final int remaining;
  final int? prescriptionId;
  final bool isActive;

  Medicine({
    this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.dosePerDay,
    required this.mgPerDose,
    required this.remaining,
    this.prescriptionId,
    required this.isActive,
  });

  factory Medicine.fromMap(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'],
      name: json['name'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      dosePerDay: json['dosePerDay'],
      mgPerDose: json['mgPerDose'],
      remaining: json['remaining'],
      prescriptionId: json['prescriptionId'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'startDate': _formatDateForApi(startDate),
      'endDate': _formatDateForApi(endDate),
      'dosePerDay': dosePerDay,
      'mgPerDose': mgPerDose,
      'remaining': remaining,
      'prescriptionId': prescriptionId,
      'isActive': isActive,
    };
  }

  String get duration {
    final difference = endDate.difference(startDate).inDays;
    return '$difference days';
  }

  String get dosage {
    return '$mgPerDose mg, $dosePerDay time(s) per day';
  }

  String _formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return '{"id": $id, "name": "$name", "startDate": "$startDate", "endDate": $endDate, "dosePerDay": "$dosePerDay", "mgPerDose": $mgPerDose, "remaining": $remaining, "prescriptionId": $prescriptionId, "isActive": $isActive}';
  }
}