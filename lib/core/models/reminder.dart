class Reminder {
  final int? id;
  final int medicineId;
  final String time;
  final bool isActive;

  Reminder({
    this.id,
    required this.medicineId,
    required this.time,
    this.isActive = true,
  });

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as int?,
      medicineId: map['medicine_id'] as int,
      time: map['time'] as String,
      isActive: map['is_active'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'medicine_id': medicineId,
      'time': time,
      'is_active': isActive ? 1 : 0,
    };

    if (id != null) map['id'] = id;

    return map;
  }

  @override
  String toString() {
    return 'Reminder(id: $id, medicineId: $medicineId, time: $time, isActive: $isActive)';
  }
}
