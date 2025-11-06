import 'package:flutter/material.dart';
import 'package:healthease/core/dao/medicine_dao.dart';
import 'package:healthease/core/dao/prescription_dao.dart';
import 'package:healthease/core/dao/reminder_dao.dart';
import 'package:healthease/core/dao/user_dao.dart';
import 'package:healthease/core/database/local_database.dart';
import 'package:healthease/core/helpers/notification_helper.dart';
import 'package:healthease/core/models/medicine.dart';
import 'package:healthease/core/models/reminder.dart';
import 'package:healthease/core/models/user.dart';
import 'package:healthease/mobile/widgets/common/custom_app_bar.dart';
import 'package:healthease/theme.dart';
import 'package:intl/intl.dart';

class PillDetailsPage extends StatefulWidget {
  final int medicineId;
  const PillDetailsPage({super.key, required this.medicineId});

  @override
  State<StatefulWidget> createState() => _PillDetailsPageState();
}

class _PillDetailsPageState extends State<PillDetailsPage> {
  bool _isAlarmOn = true;
  int? medicineId;
  Medicine? _medicine;
  User? _doctor;
  List<Reminder> _reminders = [];
  bool _isLoading = true;
  final db = LocalDatabase.instance;

  @override
  void initState() {
    super.initState();
    medicineId = widget.medicineId;
    _loadData(medicineId!);
  }

  Future<void> _loadData(int medicineId) async {
    final database = await db;
    final medicine = await MedicineDao(database).getMedicineById(medicineId);
    if (medicine == null) {
      return;
    }

    final doctorId = await PrescriptionDao(
      database,
    ).getDoctorIdByPrescriptionId(medicine.prescriptionId);
    User? doctor = await UserDao(database).getUserById(doctorId);
    final reminders = await ReminderDao(
      database,
    ).getAllReminderOfMedicineForUser(1, medicine.id!);
    for (var rem in reminders) {
      if (rem.isActive == false) {
        _isAlarmOn = false;
      }
    }
    setState(() {
      _medicine = medicine;
      _doctor = doctor;
      _reminders = reminders;
      _isLoading = false;
    });
    if (medicine.endDate.isBefore(DateTime.now())) {
      for (var reminder in reminders) {
        await ReminderDao(database).removeReminder(reminder);
        await NotificationHelper.cancelNotification(reminder.id!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    final textTheme = theme.textTheme;
    final colors = theme.colorScheme;
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_medicine == null) {
      return const Scaffold(body: Center(child: Text("Medicine not found")));
    }

    return Scaffold(

      appBar: const CustomAppBar(true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medicine Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_medicine!.name} ${_medicine!.mgPerDose}mg',
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppTheme.textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Prescribed by Dr. ${_doctor!.firstName} ${_doctor!.lastName}',
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Dosage Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dosage Details',
                    style: textTheme.titleMedium?.copyWith(
                      color: AppTheme.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    context,
                    icon: Icons.access_time,
                    label: 'Doses per day',
                    value: _medicine!.dosePerDay.toString(),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    icon: Icons.medication_outlined,
                    label: 'mg per dose',
                    value: _medicine!.mgPerDose.toString(),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    icon: Icons.calendar_today_outlined,
                    label: 'Duration',
                    value:
                        'From ${DateFormat('MMM dd, yyyy').format(_medicine!.startDate)} to ${DateFormat('MMM dd, yyyy').format(_medicine!.endDate)}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_medicine!.endDate.isAfter(DateTime.now())) ...[
              // Reminders Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reminders',
                      style: textTheme.titleMedium?.copyWith(
                        color: AppTheme.textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (var reminder in _reminders)
                      _buildReminderRow(context, reminder),
                    if (_reminders.length < _medicine!.dosePerDay)
                      for (
                        var i = 0;
                        i < _medicine!.dosePerDay - _reminders.length;
                        i++
                      )
                        _buildReminderRow(context, null),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Turn on Alarm',
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Switch(
                          value: _isAlarmOn,
                          onChanged: (value) async {
                            setState(() => _isAlarmOn = value);
                            if (_medicine != null && _reminders.isNotEmpty) {
                              final database = await db;
                              ReminderDao(
                                database,
                              ).setActiveStatusOfMedicine(_medicine!, value);

                              for (var reminder in _reminders) {
                                if (value) {
                                  final parts = reminder.time.split(':');
                                  final hour = int.parse(parts[0]);
                                  final minute = int.parse(parts[1]);
                                  await NotificationHelper.scheduleDailyNotification(
                                    id: reminder.id!,
                                    title: 'Time to take ${_medicine!.name}',
                                    body:
                                        '${_medicine!.mgPerDose}mg - prescribed by Dr. ${_doctor!.lastName}',
                                    hour: hour,
                                    minute: minute,
                                    startDate: _medicine!.startDate,
                                    endDate: _medicine!.endDate,
                                  );
                                } else {
                                  await NotificationHelper.cancelNotification(
                                    reminder.id!,
                                  );
                                }
                              }
                            }
                          },
                          activeThumbColor: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReminderRow(BuildContext context, Reminder? reminder) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'everyday',
                style: textTheme.bodyLarge?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              reminder != null ? reminder.time : '',
              style: textTheme.bodyLarge?.copyWith(
                color: AppTheme.textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: () async {
            if (reminder == null) {
              final picked = await _selectTime();
              Reminder rem = Reminder(
                medicineId: _medicine!.id!,
                time: _formatTimeOfDay(picked!),
                isActive: _isAlarmOn,
              );
              final database = await db;
              final newId = await ReminderDao(database).addReminder(rem);
              if (_isAlarmOn) {
                final parts = rem.time.split(':');
                final hour = int.parse(parts[0]);
                final minute = int.parse(parts[1]);
                await NotificationHelper.scheduleDailyNotification(
                  id: newId,
                  title: 'Time to take ${_medicine!.name}',
                  body:
                      '${_medicine!.mgPerDose}mg - prescribed by Dr. ${_doctor!.lastName}',
                  hour: hour,
                  minute: minute,
                  startDate: _medicine!.startDate,
                  endDate: _medicine!.endDate,
                );
              }
              setState(() {
                reminder = rem;
                _reminders.add(rem);
              });
            } else {
              List<String> parts = reminder!.time.split(':');
              final picked = await _selectTime(
                hour: int.parse(parts[0]),
                minute: int.parse(parts[1]),
              );
              Reminder rem = Reminder(
                id: reminder!.id,
                medicineId: _medicine!.id!,
                time: _formatTimeOfDay(picked!),
                isActive: _isAlarmOn,
              );
              final database = await db;
              ReminderDao(database).updateReminder(rem);
              await NotificationHelper.cancelNotification(rem.id!);
              if (_isAlarmOn) {
                final parts = rem.time.split(':');
                final hour = int.parse(parts[0]);
                final minute = int.parse(parts[1]);
                await NotificationHelper.scheduleDailyNotification(
                  id: rem.id!,
                  title: 'Time to take ${_medicine!.name}',
                  body:
                      '${_medicine!.mgPerDose}mg - prescribed by Dr. ${_doctor!.lastName}',
                  hour: hour,
                  minute: minute,
                  startDate: _medicine!.startDate,
                  endDate: _medicine!.endDate,
                );
              }

              final index = _reminders.indexWhere((r) => r.id == rem.id);
              if (index != -1) {
                _reminders[index] = rem;
                setState(() {});
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.primaryColor,
            side: const BorderSide(color: AppTheme.primaryColor),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Edit',
            style: textTheme.bodyLarge?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<TimeOfDay?> _selectTime({int hour = 9, int minute = 0}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
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
    return picked;
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> removeAllReminders() async {
    final database = await db;
    for (var reminder in _reminders) {
      await ReminderDao(database).removeReminder(reminder);
    }
  }
}
