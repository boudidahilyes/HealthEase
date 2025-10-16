import 'package:flutter/material.dart';
import 'package:healthease/theme.dart';
import 'package:healthease/widgets/common/custom_app_bar.dart';
import 'package:healthease/widgets/common/custom_bottom_nav.dart';

class PillsPage extends StatefulWidget {
  const PillsPage({super.key});

  @override
  State<PillsPage> createState() => _PillsPageState();
}

class _PillsPageState extends State<PillsPage> {
  final List<Map<String, dynamic>> _medications = [
    {
      'name': 'Amoxicillin',
      'dosage': '500mg',
      'schedule': '3 times daily',
      'remaining': 12,
    },
    {
      'name': 'Ciprofloxacin',
      'dosage': '250mg',
      'schedule': '2 times daily',
      'remaining': 8,
    },
    {
      'name': 'Doxycycline',
      'dosage': '100mg',
      'schedule': 'Once daily',
      'remaining': 5,
    },
    {
      'name': 'Doxycycline',
      'dosage': '100mg',
      'schedule': 'Once daily',
      'remaining': 5,
    },
  ];

  void _removeMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Medication removed',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(false),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'Your Medications',
              style: AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Manage your prescriptions and reminders',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textColor.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/in-takes');
                    },
                    icon: Icon(
                      Icons.calendar_month,
                      size: 24,
                      color: AppTheme.primaryColor.withValues(alpha: 0.7),
                    ),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _medications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.medication_outlined,
                            size: 64,
                            color: AppTheme.primaryColor.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No medications',
                            style: AppTheme.lightTheme.textTheme.headlineMedium
                                ?.copyWith(
                                  color: AppTheme.textColor.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add medications to see them here',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppTheme.textColor.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: _medications.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final medication = _medications[index];
                        return _MedicationCard(
                          name: medication['name'] as String,
                          dosage: medication['dosage'] as String,
                          schedule: medication['schedule'] as String,
                          remaining: medication['remaining'] as int,
                          onRemove: () => _removeMedication(index),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(currentIndex: 2),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  final String name;
  final String dosage;
  final String schedule;
  final int remaining;
  final VoidCallback onRemove;

  const _MedicationCard({
    required this.name,
    required this.dosage,
    required this.schedule,
    required this.remaining,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/pill-details');
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.medication_outlined,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTheme.lightTheme.textTheme.headlineMedium
                          ?.copyWith(color: AppTheme.textColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$dosage • $schedule',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textColor.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$remaining pills remaining',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: Icon(
                  Icons.delete_outline,
                  color: AppTheme.errorColor,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
