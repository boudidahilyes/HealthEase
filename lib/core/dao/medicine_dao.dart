import 'package:sqflite/sqflite.dart';
import '../models/medicine.dart';

class MedicineDao {
  final Database db;

  MedicineDao(this.db);

  Future<List<Medicine>> getAllMedicinesForUser(int userId) async {
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT m.*
      FROM medicine AS m
      INNER JOIN prescription AS p ON m.prescription_id = p.id
      WHERE p.patient_id = ? AND is_active = 1
      ORDER BY m.start_date DESC
    ''', [userId]);

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

}
