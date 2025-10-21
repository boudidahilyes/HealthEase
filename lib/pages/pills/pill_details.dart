import 'package:flutter/material.dart';
import 'package:healthease/core/dao/medicine_dao.dart';
import 'package:healthease/core/dao/prescription_dao.dart';
import 'package:healthease/core/dao/user_dao.dart';
import 'package:healthease/core/database/local_database.dart';
import 'package:healthease/core/models/medicine.dart';
import 'package:healthease/core/models/user.dart';
import 'package:healthease/theme.dart';
import 'package:healthease/widgets/common/custom_app_bar.dart';
import 'package:intl/intl.dart';

class PillDetailsPage extends StatefulWidget {
  final int medicineId;
  const PillDetailsPage({super.key, required this.medicineId});

  @override
  State<StatefulWidget> createState() => _PillDetailsPageState();
}

class _PillDetailsPageState extends State<PillDetailsPage> {
  int? medicineId;
  Medicine? _medicine;
  User? _doctor;
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

    final doctorId = await PrescriptionDao(database)
        .getDoctorIdByPrescriptionId(medicine.prescriptionId);
    User? doctor = await UserDao(database).getUserById(doctorId);

    setState(() {
      _medicine = medicine;
      _doctor = doctor;
      _isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    final textTheme = theme.textTheme;
    final colors = theme.colorScheme;
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_medicine == null) {
      return const Scaffold(
        body: Center(child: Text("Medicine not found")),
      );
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.1,
                              ),
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
                            '09:41',
                            style: textTheme.bodyLarge?.copyWith(
                              color: AppTheme.textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Am',
                            style: textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryColor,
                          side: const BorderSide(color: AppTheme.primaryColor),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
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
                  ),
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
                        value: true,
                        onChanged: (_) {},
                        activeThumbColor: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
}
