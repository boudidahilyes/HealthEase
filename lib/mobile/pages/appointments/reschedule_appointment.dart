import 'package:flutter/material.dart';
import 'package:healthease/core/dao/appointments_dao.dart';
import 'package:healthease/core/database/local_database.dart';
import 'package:healthease/core/models/appointment.dart';
import 'package:healthease/theme.dart';
import '../../../core/services/appointment_service.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_bottom_nav.dart';

class ReschedulePage extends StatefulWidget {
  final Appointment appointment;

  const ReschedulePage({super.key, required this.appointment});

  @override
  State<ReschedulePage> createState() => _ReschedulePageState();
}

class _ReschedulePageState extends State<ReschedulePage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  late AppointmentDao _appointmentDao;
  bool _isSubmitting = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _initializeDao();
    _notesController.text = widget.appointment.notes ?? '';
  }

  Future<void> _initializeDao() async {
    _appointmentDao = AppointmentDao(await LocalDatabase.instance);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.appointment.appointmentDate.add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.textColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.textColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _rescheduleAppointment() async {
    final appointmentService = AppointmentService(_appointmentDao);

    if (!_formKey.currentState!.validate()) return;

    final newDate = _selectedDate ?? widget.appointment.appointmentDate;
    final newTime = _selectedTime?.format(context) ?? widget.appointment.appointmentTime;

    final dateChanged = _selectedDate != null;
    final timeChanged = _selectedTime != null;

    if (dateChanged || timeChanged) {
      final availability = await appointmentService.checkDoctorAppointmentAvailability(
        widget.appointment.doctorId,
        newDate,
        newTime,
        excludeAppointmentId: widget.appointment.id,
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
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final rescheduledAppointment = Appointment(
        id: widget.appointment.id,
        doctorId: widget.appointment.doctorId,
        patientId: widget.appointment.patientId,
        speciality: widget.appointment.speciality,
        appointmentDate: newDate,
        appointmentTime: newTime,
        status: 'pending',
        notes: _notesController.text.isNotEmpty ? _notesController.text : widget.appointment.notes,
      );

      await _appointmentDao.updateAppointment(rescheduledAppointment);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Appointment rescheduled successfully',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to reschedule appointment: $e',
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

  String? _validateDate(DateTime? value) {
    if (value == null) {
      return null;
    }
    if (value.isBefore(DateTime.now())) {
      return 'Appointment date cannot be in the past';
    }
    return null;
  }

  String? _validateTime(TimeOfDay? value) {
    if (value == null) {
      return null;
    }
    return null;
  }

  Widget _buildCurrentAppointmentInfo() {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Appointment',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.medical_services, size: 16, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  widget.appointment.speciality,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Dr. ${widget.appointment.doctorId}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  '${_formatDate(widget.appointment.appointmentDate)} at ${widget.appointment.appointmentTime}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reschedule Appointment',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select new date and time for your appointment',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildCurrentAppointmentInfo(),

              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          'New Appointment Details',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Leave fields empty to keep current date/time',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textColor.withOpacity(0.5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: _selectedDate != null
                                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                : 'Keep current date (${_formatDate(widget.appointment.appointmentDate)})',
                          ),
                          decoration: InputDecoration(
                            labelText: 'New Date (Optional)',
                            hintText: 'Select new appointment date',
                            suffixIcon: Icon(
                              Icons.calendar_today,
                              color: AppTheme.primaryColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                            text: _selectedTime != null
                                ? _selectedTime!.format(context)
                                : 'Keep current time (${widget.appointment.appointmentTime})',
                          ),
                          decoration: InputDecoration(
                            labelText: 'New Time (Optional)',
                            hintText: 'Select new appointment time',
                            suffixIcon: Icon(
                              Icons.access_time,
                              color: AppTheme.primaryColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                            labelText: 'Update Notes (Optional)',
                            hintText: 'Add reason for rescheduling or additional notes...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          maxLines: 3,
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),

              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _rescheduleAppointment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                        'Reschedule Appointment',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: TextButton(
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textColor.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(currentIndex: 4),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}