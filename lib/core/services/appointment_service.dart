// lib/core/services/appointment_service.dart
import '../models/appointment.dart';
import '../dao/appointments_dao.dart';

class AppointmentService {
  final AppointmentDao _appointmentDao;

  AppointmentService(this._appointmentDao);

  Future<bool> isTimeSlotAvailableForDoctor(
      String doctorId,
      DateTime date,
      String time,
      {String? excludeAppointmentId}
      ) async {
    final allAppointments = await _appointmentDao.getAllAppointments();

    return !allAppointments.any((appointment) {
      if (excludeAppointmentId != null && appointment.id == excludeAppointmentId) {
        return false;
      }
      final isSameDoctor = appointment.doctorId == doctorId;
      final isSameDate = appointment.appointmentDate.year == date.year &&
          appointment.appointmentDate.month == date.month &&
          appointment.appointmentDate.day == date.day;
      final isSameTime = appointment.appointmentTime == time;

      final isActive = appointment.status == 'pending' || appointment.status == 'confirmed';

      return isSameDoctor && isSameDate && isSameTime && isActive;
    });
  }

  Future<(bool, String?)> checkDoctorAppointmentAvailability(
      String doctorId,
      DateTime date,
      String time,
      {String? excludeAppointmentId}
      ) async {
    final isAvailable = await isTimeSlotAvailableForDoctor(
        doctorId, date, time, excludeAppointmentId: excludeAppointmentId
    );

    if (!isAvailable) {
      final allAppointments = await _appointmentDao.getAllAppointments();
      final conflict = allAppointments.firstWhere((appt) {
        final isSameDoctor = appt.doctorId == doctorId;
        final isSameDate = appt.appointmentDate.year == date.year &&
            appt.appointmentDate.month == date.month &&
            appt.appointmentDate.day == date.day;
        final isSameTime = appt.appointmentTime == time;
        final isActive = appt.status == 'pending' || appt.status == 'confirmed';
        return isSameDoctor && isSameDate && isSameTime && isActive && appt.id != excludeAppointmentId;
      });

      final conflictDetails = 'Dr. ${conflict.doctorId} is already booked for ${date.day}-${date.month}-${date.year} $time';
      return (false, conflictDetails);
    }

    return (true, null);
  }

}