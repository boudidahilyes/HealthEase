import 'package:sqflite/sqflite.dart';
import '../models/medicine.dart';

class MedicineDao {
  final Database db;

  MedicineDao(this.db);

  Future<List<Medicine>> getAllMedicinesForUser(int userId) async {
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT m.*
      FROM medicine AS m
      INNER JOIN prescription AS p ON m.prescription_id = p.id
      WHERE p.patient_id = ? AND is_active = 1
      ORDER BY m.start_date DESC
    ''',
      [userId],
    );

    return result.map((row) => Medicine.fromMap(row)).toList();
  }

  Future<Medicine?> getMedicineById(int medicineId) async {
    final List<Map<String, dynamic>> result = await db.query(
      'medicine',
      where: 'id = ?',
      whereArgs: [medicineId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Medicine.fromMap(result.first);
  }

  Future<List<Medicine>> getActiveMedicinesForPatientOnDate(
    int patientId,
    DateTime targetDate,
  ) async {
    final formattedDate = targetDate.toIso8601String();

    try {
      final List<Map<String, dynamic>> result = await db.rawQuery(
        '''
       SELECT m.*
       FROM medicine m
       INNER JOIN prescription p ON m.prescription_id = p.id
       WHERE p.patient_id = ?
         AND (date(?) BETWEEN date(m.start_date) AND date(m.end_date)) AND m.is_active = 1
     ''',
        [patientId, formattedDate],
      );

      return result.map((row) => Medicine.fromMap(row)).toList();
    } catch (e) {
      print('Error fetching active medicines for patient $patientId: $e');
      rethrow;
    }
  }

  Future<void> decrementRemainingQuantity(int medicineId) async {
      await db.rawUpdate(
        '''
      UPDATE medicine
      SET remaining = remaining - 1
      WHERE id = ? AND remaining > 0
      ''',
        [medicineId],
      );
  }
}
