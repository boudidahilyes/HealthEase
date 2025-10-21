import 'package:sqflite/sqflite.dart';

class PrescriptionDao {
  final Database db;

  PrescriptionDao(this.db);

  Future<int> getDoctorIdByPrescriptionId(int prescriptionId) async {
    final List<Map<String, dynamic>> result = await db.query(
      'prescription',
      where: 'id = ?',
      whereArgs: [prescriptionId],
      limit: 1,
    );
    return result[0]['doctor_id'];
  }
}
