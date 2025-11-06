import 'package:flutter/material.dart';
import 'package:healthease/mobile/widgets/common/custom_app_bar.dart';

class MedicineDescriptionPage extends StatefulWidget {
  final String description;

  const MedicineDescriptionPage({super.key, required this.description});

  @override
  State<MedicineDescriptionPage> createState() =>
      _MedicineDescriptionPageState();
}

class _MedicineDescriptionPageState extends State<MedicineDescriptionPage> {
  late String description;

  @override
  void initState() {
    super.initState();
    description = widget.description;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(child: SingleChildScrollView(
          child: Text(
            description,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ),)
      ),
    );
  }
}