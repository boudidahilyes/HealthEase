class Appointment {
  final String id;
  final String doctorId;
  final String patientId;
  final String speciality;
  final DateTime appointmentDate;
  final String appointmentTime;
  final String status;
  final String? notes;

  const Appointment({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.speciality,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    this.notes,
  });

  factory Appointment.empty() {
    return Appointment(
      id: '',
      doctorId: '',
      patientId: '',
      speciality: '',
      appointmentDate: DateTime.now(),
      appointmentTime: '',
      status: 'pending',
      notes: null,
    );
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      doctorId: json['doctorId'] as String,
      patientId: json['patientId'] as String,
      speciality: json['speciality'] as String,
      appointmentDate: DateTime.parse(json['appointmentDate'] as String),
      appointmentTime: json['appointmentTime'] as String,
      status: json['status'] as String,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'patientId': patientId,
      'speciality': speciality,
      'appointmentDate': appointmentDate.toIso8601String(),
      'appointmentTime': appointmentTime,
      'status': status,
      'notes': notes,
    };
  }
}