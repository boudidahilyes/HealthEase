import 'package:healthease/core/models/prescription.dart';
import 'package:sqflite/sqflite.dart';

class PrescriptionDao {
  final Database db;

  PrescriptionDao(this.db);

  Future<List<Prescription>> getAllByPatientId(int patientId) async {
    final List<Map<String, dynamic>> result = await db.query(
      'prescription',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      limit: 1,
    );
    return result.map((map) => Prescription.fromMap(map)).toList();
  }

  Future<int> getDoctorIdByPrescriptionId(int prescriptionId) async {
    final List<Map<String, dynamic>> result = await db.query(
      'prescription',
      where: 'id = ?',
      whereArgs: [prescriptionId],
      limit: 1,
    );
    return result[0]['doctor_id'];
  }

  Future<int> getPatientIdByPrescriptionId(int prescriptionId) async {
    final List<Map<String, dynamic>> result = await db.query(
      'prescription',
      where: 'id = ?',
      whereArgs: [prescriptionId],
      limit: 1,
    );
    return result[0]['patient_id'];
  }

  Future<int> insertOrUpdate(Prescription pres) async {
    if (pres.id == null) {
      final id = await db.insert('prescription', pres.toMap());
      return id;
    } else {
      final count = await db.update('prescription', pres.toMap(), where: 'id = ?', whereArgs: [pres.id]);
      if (count == 0) {
        final id = await db.insert('prescription', pres.toMap());
        return id;
      }
      return pres.id!;
    }
  }

  Future<void> removeById(int prescriptionId) async {
    await db.delete('prescription', where: 'id = ?', whereArgs: [prescriptionId]);
  }
}
