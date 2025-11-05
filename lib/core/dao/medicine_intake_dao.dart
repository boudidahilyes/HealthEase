import 'package:healthease/core/models/medicine_intake.dart';
import 'package:sqflite/sqflite.dart';

class MedicineIntakeDao {
  final Database db;

  MedicineIntakeDao(this.db);

  Future<int> insert(MedicineIntake medicineIntake) async {
    return await db.insert('medicine_intake', medicineIntake.toMap());
  }

  Future<int> getIntakeCountOnDate(DateTime date) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'medicine_intake',
      where: 'date = ?',
      whereArgs: [date.toIso8601String()],
    );
    return maps.length;
  }

  Future<bool> getIntakeDoseIndexOnDate(DateTime date, int doseIndex,int medicineId) async {
    final result = await db.query(
      'medicine_intake',
      where: 'date = ? AND dose_index = ? AND medicine_id = ?',
      whereArgs: [date.toIso8601String(), doseIndex,medicineId],
    );

    return result.isNotEmpty;
  }
}
