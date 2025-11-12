import 'package:flutter/material.dart';
import 'package:healthease/core/dao/appointments_dao.dart';
import 'package:healthease/core/database/local_database.dart';
import 'package:healthease/core/models/appointment.dart';
import 'package:healthease/theme.dart';
import '../../../core/services/appointment_service.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_bottom_nav.dart';

class AppointmentAddPage extends StatefulWidget {
  const AppointmentAddPage({super.key});

  @override
  State<AppointmentAddPage> createState() => _AppointmentAddPageState();
}

class _AppointmentAddPageState extends State<AppointmentAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  bool _isSubmitting = false;
  String? _selectedDoctor;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final List<Map<String, String>> _doctors = [
    {'id': '1', 'name': 'Dr. Sarah Smith', 'speciality': 'Cardiology'},
    {'id': '2', 'name': 'Dr. Michael Johnson', 'speciality': 'Dermatology'},
    {'id': '3', 'name': 'Dr. Emily Williams', 'speciality': 'General Medicine'},
    {'id': '4', 'name': 'Dr. James Brown', 'speciality': 'Pediatrics'},
    {'id': '5', 'name': 'Dr. Lisa Davis', 'speciality': 'Orthopedics'},
    {'id': '6', 'name': 'Dr. Robert Wilson', 'speciality': 'Neurology'},
  ];

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppTheme.primaryColor,
            onPrimary: Colors.white,
            onSurface: AppTheme.textColor,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppTheme.primaryColor,
            onPrimary: Colors.white,
            onSurface: AppTheme.textColor,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  // In your AppointmentAddPage, update _scheduleAppointment method:
  Future<void> _scheduleAppointment() async {
    final appointmentDao = AppointmentDao(await LocalDatabase.instance);
    final appointmentService = AppointmentService(appointmentDao);

    if (!_formKey.currentState!.validate()) return;

    final selectedDoctor = _doctors.firstWhere(
          (doctor) => doctor['id'] == _selectedDoctor,
    );

    // Check for time slot availability for this specific doctor
    final selectedTime = _selectedTime!.format(context);
    final availability = await appointmentService.checkDoctorAppointmentAvailability(
      selectedDoctor['id']!,
      _selectedDate!,
      selectedTime,
    );

    if (!availability.$1) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Time Slot Unavailable'),
          content: Text(availability.$2!),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final appointment = Appointment(
        id: '',
        doctorId: '2',
        patientId: '1',
        speciality: selectedDoctor['speciality']!,
        appointmentDate: _selectedDate!,
        appointmentTime: selectedTime,
        status: 'pending',
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      await appointmentDao.insertAppointment(appointment);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Appointment scheduled successfully',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to schedule appointment: $e',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String? _validateRequiredField(String? value, String fieldName) {
    if (value == null || value.isEmpty) return 'Please select $fieldName';
    return null;
  }

  String? _validateDate(DateTime? value) {
    if (value == null) return 'Please select appointment date';
    if (value.isBefore(DateTime.now())) return 'Appointment date cannot be in the past';
    return null;
  }

  String? _validateTime(TimeOfDay? value) {
    if (value == null) return 'Please select appointment time';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(true),
      bottomNavigationBar: CustomBottomNav(currentIndex: 4),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Schedule New Appointment',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fill in the details to book your appointment',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                value: _selectedDoctor,
                                decoration: InputDecoration(
                                  labelText: 'Select Doctor',
                                  hintText: 'Choose a doctor',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                items: _doctors.map((doctor) {
                                  return DropdownMenuItem(
                                    value: doctor['id'],
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          doctor['name']!,
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          doctor['speciality']!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(color: AppTheme.textColor.withOpacity(0.6)),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) => setState(() => _selectedDoctor = value),
                                validator: (value) => _validateRequiredField(value, 'a doctor'),
                                selectedItemBuilder: (context) {
                                  return _doctors.map((doctor) {
                                    return Text(
                                      doctor['name']!,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                    );
                                  }).toList();
                                },
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                readOnly: true,
                                controller: TextEditingController(
                                  text: _selectedDate != null
                                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                      : '',
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Appointment Date',
                                  hintText: 'Select appointment date',
                                  suffixIcon: Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                onTap: _selectDate,
                                validator: (value) => _validateDate(_selectedDate),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                readOnly: true,
                                controller: TextEditingController(
                                  text: _selectedTime != null ? _selectedTime!.format(context) : '',
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Appointment Time',
                                  hintText: 'Select appointment time',
                                  suffixIcon: Icon(Icons.access_time, color: AppTheme.primaryColor),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                onTap: _selectTime,
                                validator: (value) => _validateTime(_selectedTime),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _notesController,
                                decoration: InputDecoration(
                                  labelText: 'Notes (Optional)',
                                  hintText: 'Any symptoms, concerns, or special requests...',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                maxLines: 4,
                                textInputAction: TextInputAction.done,
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Submit Button
            Container(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _scheduleAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text(
                    'Schedule Appointment',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
