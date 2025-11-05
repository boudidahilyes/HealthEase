class MedicineIntake {
  int? id;
  int medicineId;
  DateTime date;
  int doseIndex;

  MedicineIntake({
    this.id,
    required this.medicineId,
    required this.date,
    required this.doseIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicine_id': medicineId,
      'date': date.toIso8601String(),
      'dose_index': doseIndex,
    };
  }

  factory MedicineIntake.fromMap(Map<String, dynamic> map) {
    return MedicineIntake(
      id: map['id'],
      medicineId: map['medicine_id'],
      date: DateTime.parse(map['date']),
      doseIndex: map['dose_index'],
    );
  }
}
