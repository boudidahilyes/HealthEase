enum MedicineStatus { active, inactive }

class Medicine {
  final int? id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final int dosePerDay;
  final int mgPerDose;
  final int remaining;
  final int prescriptionId;
  final MedicineStatus status;

  Medicine({
    this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.dosePerDay,
    required this.mgPerDose,
    required this.remaining,
    required this.prescriptionId,
    this.status = MedicineStatus.active,
  });

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'] as int?,
      name: map['name'] as String,
      startDate: DateTime.tryParse(map['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(map['end_date'] ?? '') ?? DateTime.now(),
      dosePerDay: map['dose_per_day'] as int,
      mgPerDose: map['mg_per_dose'] as int,
      remaining: map['remaining'] as int,
      prescriptionId: map['prescription_id'] as int,
      status: (map['is_active'] == 1)
          ? MedicineStatus.active
          : MedicineStatus.inactive,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'dose_per_day': dosePerDay,
      'mg_per_dose': mgPerDose,
      'remaining': remaining,
      'prescription_id': prescriptionId,
      'is_active': status == MedicineStatus.active ? 1 : 0,
    };

    if (id != null) map['id'] = id;
    return map;
  }

  @override
  String toString() {
    return 'Medicine(id: $id, name: $name, startDate: $startDate, endDate: $endDate, '
        'dosePerDay: $dosePerDay, mgPerDose: $mgPerDose, remaining: $remaining, '
        'prescriptionId: $prescriptionId, status: $status)';
  }
}
