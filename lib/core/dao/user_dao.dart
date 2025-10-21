import 'package:healthease/core/models/user.dart';
import 'package:sqflite/sqflite.dart';

class UserDao {
  final Database db;

  UserDao(this.db);

  Future<User?> getUserById(int userId) async {
    final List<Map<String, dynamic>> result = await db.query(
      'user',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }
}