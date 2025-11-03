import 'package:healthease/core/dao/prescription_dao.dart';
import 'package:healthease/core/models/medicine.dart';
import 'package:healthease/core/models/reminder.dart';
import 'package:sqflite/sqflite.dart';

class ReminderDao {
  final Database db;

  ReminderDao(this.db);
  Future<List<Reminder>> getAllReminderOfMedicineForUser(
    int userId,
    int medicineId,
  ) async {
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
        SELECT r.*
        FROM reminder AS r
        INNER JOIN medicine AS m ON m.id = r.medicine_id
        INNER JOIN prescription AS p ON p.id = m.prescription_id
        WHERE m.id = ? AND p.patient_id = ?
        ORDER BY r.time ASC;
      ''',
      [medicineId, userId],
    );

    return result.map((row) => Reminder.fromMap(row)).toList();
  }

  Future<int> addReminder(Reminder reminder) async {
    return await db.insert('reminder', reminder.toMap());
  }

  Future<void> updateReminder(Reminder reminder) async {
    await db.update(
      'reminder',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  Future<void> setActiveStatusOfMedicine(Medicine medicine, bool active) async {
    final reminders = await getAllReminderOfMedicineForUser(
      await PrescriptionDao(
        db,
      ).getPatientIdByPrescriptionId(medicine.prescriptionId),
      medicine.id!,
    );
    for(var reminder in reminders)
      {
        db.rawUpdate('UPDATE reminder SET is_active=? WHERE medicine_id=?',[active,reminder.medicineId]);
      }
  }
}
