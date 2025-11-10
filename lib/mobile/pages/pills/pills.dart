import 'dart:io';

import 'package:flutter/material.dart';
import 'package:healthease/core/dao/medicine_dao.dart';
import 'package:healthease/core/dao/medicine_intake_dao.dart';
import 'package:healthease/core/dao/prescription_dao.dart';
import 'package:healthease/core/dao/reminder_dao.dart';
import 'package:healthease/core/database/local_database.dart';
import 'package:healthease/core/helpers/notification_helper.dart';
import 'package:healthease/core/models/medicine.dart';
import 'package:healthease/core/services/medicine_describer_service.dart';
import 'package:healthease/core/services/prescription_service.dart';
import 'package:healthease/mobile/pages/pills/medicine_description.dart';
import 'package:healthease/mobile/widgets/common/custom_app_bar.dart';
import 'package:healthease/mobile/widgets/common/custom_bottom_nav.dart';
import 'package:healthease/mobile/widgets/pills/custom_camera_screen.dart';
import 'package:healthease/theme.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/mappers/prescription_mapper.dart';

class PillsPage extends StatefulWidget {
  const PillsPage({super.key});

  @override
  State<PillsPage> createState() => _PillsPageState();
}

class _PillsPageState extends State<PillsPage> {
  final List<Medicine> _medications = [];
  final db = LocalDatabase.instance;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    print("aaaaa");
    await syncFromServer(1);
    final List<Medicine> medications = await MedicineDao(
      await db,
    ).getAllMedicinesForUser(1);
    setState(() {
      _medications.addAll(medications);
    });
  }

  Future<void> _openCamera() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomCameraScreen(
          onImageCaptured: (XFile imageFile) async {
            try {
              final description = await MedicineDescriberService()
                  .describeMedicine(File(imageFile.path));
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      MedicineDescriptionPage(description: description),
                ),
              );
            } catch (e) {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Error: $e")));
            }
          },
        ),
      ),
    );
  }

  Future<void> syncFromServer(int patientId) async {
    final api = PrescriptionService();
    final database = await db;

    final dtos = await api.getPrescriptionsByPatient(patientId);
    final serverIds = dtos.map((d) => d.id!).toList();

    final localPrescriptions = await PrescriptionDao(database).getAllByPatientId(patientId);

    for (final local in localPrescriptions) {
      if (!serverIds.contains(local.id)) {
        final medicines = await MedicineDao(database).getMedicineByPrescriptionId(local.id!);
        if (medicines != null) {
          for (final med in medicines) {
            final reminders = await ReminderDao(database).getAllReminderOfMedicineForUser(patientId, med.id!);
            if (reminders != null) {
              for (final reminder in reminders) {
                await NotificationHelper.cancelNotification(reminder.id!);
              }
            }
            await ReminderDao(database).removeReminderByMedicineId(med.id!);
            await MedicineIntakeDao(database).removeMedicineInTakeByMedicineId(med.id!);
            await MedicineDao(database).removeById(med.id!);
          }
        }
        await PrescriptionDao(database).removeById(local.id!);
      }
    }

    for (final d in dtos) {
      final localPres = prescriptionDtoToLocal(d);
      final int localPresId = await PrescriptionDao(database).insertOrUpdate(localPres);

      for (final medDto in d.medicines) {
        final localMed = medicineDtoToLocal(
          medDto,
          prescriptionId: localPresId,
        );
        await MedicineDao(database).insertOrUpdate(localMed);
      }
    }

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
                            "You don't have any medications",
                            style: AppTheme.lightTheme.textTheme.headlineMedium
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
                          medicineId: medication.id!,
                          name: medication.name,
                          dosage: medication.mgPerDose,
                          schedule: medication.dosePerDay == 1
                              ? 'Once per day'
                              : '${medication.dosePerDay} times per day',
                          remaining: medication.remaining,
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openCamera();
        },
        child: Icon(Icons.camera_alt_rounded),
      ),
      bottomNavigationBar: CustomBottomNav(currentIndex: 2),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  final int medicineId;
  final String name;
  final int dosage;
  final String schedule;
  final int remaining;

  const _MedicationCard({
    required this.medicineId,
    required this.name,
    required this.dosage,
    required this.schedule,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/pill-details', arguments: medicineId);
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
                      '$dosage mg • $schedule',
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
            ],
          ),
        ),
      ),
    );
  }
}
