import 'package:sqflite/sqflite.dart';
import '../models/appointment.dart';

class AppointmentDao {
  final Database db;

  AppointmentDao(this.db);

  static const String tableName = 'appointments';

  Future<int> insertAppointment(Appointment appointment) async {
    try {
      final id = await db.insert(
        tableName,
        _toMap(appointment),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id;
    } catch (e) {
      throw Exception('Failed to insert appointment: $e');
    }
  }

  Future<int> updateAppointment(Appointment appointment) async {
    try {
      final count = await db.update(
        tableName,
        _toMap(appointment),
        where: 'id = ?',
        whereArgs: [appointment.id],
      );
      return count;
    } catch (e) {
      throw Exception('Failed to update appointment: $e');
    }
  }

  Future<int> deleteAppointment(int id) async {
    try {
      final count = await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      return count;
    } catch (e) {
      throw Exception('Failed to delete appointment: $e');
    }
  }

  Future<Appointment?> getAppointmentById(int id) async {
    try {
      final maps = await db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return _fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get appointment by id: $e');
    }
  }

  Future<List<Appointment>> getAllAppointments() async {
    try {
      final maps = await db.query(
        tableName,
        orderBy: 'appointment_date DESC, appointment_time DESC',
      );
      return maps.map((map) => _fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to get all appointments: $e');
    }
  }

  Future<List<Appointment>> getAppointmentsByDoctor(int doctorId) async {
    try {
      final maps = await db.query(
        tableName,
        where: 'doctor_id = ?',
        whereArgs: [doctorId],
        orderBy: 'appointment_date DESC, appointment_time DESC',
      );
      return maps.map((map) => _fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to get appointments by doctor: $e');
    }
  }

  Future<List<Appointment>> getAppointmentsByPatient(int patientId) async {
    try {
      final maps = await db.query(
        tableName,
        where: 'patient_id = ?',
        whereArgs: [patientId],
        orderBy: 'appointment_date DESC, appointment_time DESC',
      );
      return maps.map((map) => _fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to get appointments by patient: $e');
    }
  }

  Map<String, dynamic> _toMap(Appointment appointment) {
    return {
      'id': appointment.id.isEmpty ? null : int.parse(appointment.id),
      'doctor_id': int.parse(appointment.doctorId),
      'patient_id': int.parse(appointment.patientId),
      'speciality': appointment.speciality,
      'appointment_date': _formatDate(appointment.appointmentDate),
      'appointment_time': appointment.appointmentTime,
      'status': appointment.status,
      'notes': appointment.notes,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Appointment _fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'].toString(),
      doctorId: map['doctor_id'].toString(),
      patientId: map['patient_id'].toString(),
      speciality: map['speciality'] as String,
      appointmentDate: DateTime.parse(map['appointment_date'] as String),
      appointmentTime: map['appointment_time'] as String,
      status: map['status'] as String,
      notes: map['notes'] as String?,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}