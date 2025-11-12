import 'package:flutter/material.dart';
import 'package:healthease/core/dao/appointments_dao.dart';
import 'package:healthease/core/database/local_database.dart';
import 'package:healthease/core/models/appointment.dart';
import 'package:healthease/core/services/weather_service.dart';
import 'package:healthease/mobile/pages/appointments/reschedule_appointment.dart';
import 'package:healthease/theme.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_bottom_nav.dart';
import 'add_appointment.dart';

class AppointmentListPage extends StatefulWidget {
  const AppointmentListPage({super.key});

  @override
  State<AppointmentListPage> createState() => _AppointmentListPageState();
}

class _AppointmentListPageState extends State<AppointmentListPage> {
  final List<(Appointment app, String weather)> _appointments = [];
  final List<(Appointment app, String weather)> _pastAppointments = [];
  late AppointmentDao _appointmentDao;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    _appointmentDao = AppointmentDao(await LocalDatabase.instance);

    try {
      setState(() => _isLoading = true);

      final allAppointments = await _appointmentDao.getAllAppointments();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      _appointments.clear();
      _pastAppointments.clear();

      for (final appointment in allAppointments) {
        final appointmentDay = appointment.appointmentDate;
        String weatherSugg = '';

        if (appointmentDay.isAfter(today) || appointmentDay.isAtSameMomentAs(today)) {
          try {
            final weatherForecast = await WeatherService.getWeatherForecast(appointmentDay);
            weatherSugg = WeatherService.getWeatherSuggestion(weatherForecast, appointment.speciality, appointmentDay);
          } catch (e) {
            weatherSugg = '🌤️ Weather info unavailable';
          }
        }

        if (appointmentDay.isAfter(today) || appointmentDay.isAtSameMomentAs(today)) {
          _appointments.add((appointment, weatherSugg));
        } else {
          _pastAppointments.add((appointment, weatherSugg));
        }
      }

      _appointments.sort((a, b) => a.$1.appointmentDate.compareTo(b.$1.appointmentDate));
      _pastAppointments.sort((a, b) => b.$1.appointmentDate.compareTo(a.$1.appointmentDate));
    } catch (e) {
      _showErrorSnackBar('Failed to load appointments: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToAddAppointment() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AppointmentAddPage()),
    ).then((_) => _loadAppointments());
  }

  Future<void> _cancelAppointment(String appointmentId) async {
    try {
      final appointment = _appointments.firstWhere((appt) => appt.$1.id == appointmentId);

      final updatedAppointment = Appointment(
        id: appointment.$1.id,
        doctorId: appointment.$1.doctorId,
        patientId: appointment.$1.patientId,
        speciality: appointment.$1.speciality,
        appointmentDate: appointment.$1.appointmentDate,
        appointmentTime: appointment.$1.appointmentTime,
        status: 'cancelled',
        notes: appointment.$1.notes,
      );

      await _appointmentDao.updateAppointment(updatedAppointment);
      await _loadAppointments();

      _showSuccessSnackBar('Appointment cancelled successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to cancel appointment: $e');
    }
  }


  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _navigateToReschedule(Appointment appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReschedulePage(appointment: appointment),
      ),
    ).then((success) {
      if (success == true) {
        _loadAppointments();
      }
    });
  }

  Widget _buildAppointmentCard((Appointment app, String weather) appointmentData, bool isUpcoming) {
    final appointment = appointmentData.$1;
    final weatherSuggestion = appointmentData.$2;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  appointment.speciality,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appointment.status.toUpperCase(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Dr. ${appointment.doctorId}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textColor),
            ),
            const SizedBox(height: 4),
            Text(
              '${_formatDate(appointment.appointmentDate)} at ${appointment.appointmentTime}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textColor.withOpacity(0.7)),
            ),

            // WEATHER SUGGESTION - NEW FEATURE
            if (isUpcoming && weatherSuggestion.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cloud, size: 16, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        weatherSuggestion,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textColor.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: ${appointment.notes}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textColor.withOpacity(0.6)),
              ),
            ],
            if (isUpcoming && appointment.status == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => _cancelAppointment(appointment.id),
                      child: Text('Cancel', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.errorColor)),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _navigateToReschedule(appointment),
                      child: Text('Reschedule', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppTheme.successColor;
      case 'pending':
        return AppTheme.warningColor;
      case 'cancelled':
        return AppTheme.errorColor;
      case 'completed':
        return AppTheme.infoColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  Widget _buildLoadingIndicator() => const Center(child: CircularProgressIndicator());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(false),
      bottomNavigationBar: CustomBottomNav(currentIndex: 1),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddAppointment,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? _buildLoadingIndicator()
          : _appointments.isEmpty && _pastAppointments.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: AppTheme.primaryColor.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('No appointments yet', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.textColor.withOpacity(0.7))),
            const SizedBox(height: 8),
            Text('Schedule your first appointment', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textColor.withOpacity(0.5))),
          ],
        ),
      )
          : ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          if (_appointments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Upcoming Appointments', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.textColor)),
            ),
          ..._appointments.map((appt) => _buildAppointmentCard(appt, true)),
          if (_pastAppointments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text('Past Appointments', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.textColor)),
            ),
          ..._pastAppointments.map((appt) => _buildAppointmentCard(appt, false)),
        ],
      ),
    );
  }
}