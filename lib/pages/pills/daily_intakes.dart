import 'package:flutter/material.dart';
import 'package:healthease/core/dao/medicine_dao.dart';
import 'package:healthease/core/database/local_database.dart';
import 'package:healthease/core/models/medicine.dart';
import 'package:healthease/theme.dart';
import 'package:healthease/widgets/common/custom_app_bar.dart';
import 'package:intl/intl.dart';

class DailyIntakePage extends StatefulWidget {
  const DailyIntakePage({super.key});

  @override
  State<DailyIntakePage> createState() => _DailyIntakePageState();
}

class _DailyIntakePageState extends State<DailyIntakePage> {
  final db = LocalDatabase.instance;
  late DateTime today;
  late List<DateTime> weekDays;
  int selectedIndex = 0;
  late List<Medicine> medicines;
  int inTakes = 0;
  @override
  void initState() {
    init();
    super.initState();

  }
  init() async {
    today = DateTime.now();
    final monday = today.subtract(Duration(days: today.weekday - 1));
    weekDays = List.generate(7, (i) => monday.add(Duration(days: i)));
    print(weekDays);
    print(today);
    selectedIndex = today.weekday - 1;
    print(selectedIndex);
    final meds = await MedicineDao(await db).getActiveMedicinesForPatientOnDate(1, today);
    setState(() {
      medicines = meds;
    });
    for(var med in medicines){
      inTakes+= med.dosePerDay;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final selectedDate = weekDays[selectedIndex];

    return Scaffold(
      appBar: const CustomAppBar(true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              selectedIndex == today.weekday - 1
                  ? 'Today'
                  : DateFormat('EEEE').format(selectedDate),
              style: textTheme.headlineMedium?.copyWith(
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: weekDays.length,
                itemBuilder: (context, index) {
                  final date = weekDays[index];
                  final dayNum = DateFormat('d').format(date);
                  final label = DateFormat('E').format(date).toUpperCase();
                  final isSelected = index == selectedIndex;
                  return GestureDetector(
                    onTap: () async {
                      inTakes = 0;
                      setState(() => selectedIndex = index);
                      List<Medicine> meds=await MedicineDao(await db).getActiveMedicinesForPatientOnDate(1, date);
                      setState(() {
                        medicines = meds;
                      });
                      for(var med in medicines){
                        inTakes+= med.dosePerDay;
                      }
                      print(inTakes);
                    },
                    child: Container(
                      width: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor.withValues(alpha: 0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dayNum,
                            style: textTheme.titleMedium?.copyWith(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : AppTheme.textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            label,
                            style: textTheme.bodyMedium?.copyWith(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Intakes',
              style: textTheme.headlineMedium?.copyWith(
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha:0.08),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.medication_rounded,
                    size: 36,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      text: '0',
                      style: textTheme.headlineLarge?.copyWith(
                        color: AppTheme.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: '/${inTakes}',
                          style: textTheme.headlineMedium?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    selectedIndex == today.weekday - 1
                        ? 'Today'
                        : DateFormat('EEEE').format(selectedDate),
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            for (var medicine in medicines)
              for(int i=0;i<medicine.dosePerDay;i++)
                _buildIntakeCard(
                  context,
                  title:medicine.name,
                  subtitle: '${medicine.mgPerDose}mg',
                  time: null,
                ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildIntakeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
        String? time,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withValues(alpha:0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppTheme.infoColor,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppTheme.textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(8),
            ),

            child: time!=null?Text(
              time,
              style: textTheme.bodyMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ):Text(''),
          ),
        ],
      ),
    );
  }
}
