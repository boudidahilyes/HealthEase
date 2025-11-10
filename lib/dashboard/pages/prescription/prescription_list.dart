import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:healthease/core/dto/prescription_dto.dart';
import 'package:healthease/core/services/prescription_service.dart';
import 'package:healthease/dashboard/pages/prescription/prescription_detail.dart';
import 'package:healthease/theme.dart';

class PrescriptionListPage extends StatefulWidget {
  const PrescriptionListPage({super.key});

  @override
  State<PrescriptionListPage> createState() => _PrescriptionListPageState();
}

class _PrescriptionListPageState extends State<PrescriptionListPage> {
  final ScrollController _horizontalController = ScrollController();
  final PrescriptionService _prescriptionService = PrescriptionService();

  List<PrescriptionDto> _prescriptions = [];

  String searchQuery = "";
  String filter = "All";

  final TextEditingController _descriptionController = TextEditingController();

  final List<Map<String, dynamic>> _medicines = [];

  final List<Map<String, dynamic>> _users = [
    {'id': 1, 'name': 'John Doe'},
    {'id': 2, 'name': 'Jane Smith'},
    {'id': 3, 'name': 'Alice Johnson'},
  ];

  int? _selectedPatientId;

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadPrescriptions() async {
    final doctorId = 2;
    final prescriptions = await _prescriptionService.getPrescriptionsByDoctor(doctorId);
    setState(() {
      _prescriptions = prescriptions;
    });
  }

  void _showAddPrescriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.add_circle, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  const Text('Add New Prescription'),
                ],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Patient Information'),
                      DropdownButtonFormField<int>(
                        initialValue: _selectedPatientId,
                        decoration: const InputDecoration(
                          labelText: 'Select Patient',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        items: _users.map((user) {
                          return DropdownMenuItem<int>(
                            value: user['id'],
                            child: Text('${user['name']}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPatientId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Enter prescription description...',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),

                      const SizedBox(height: 24),

                      _buildSectionHeader('Medicines'),
                      if (_medicines.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'At least one medicine is required',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 1),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _medicines.add({
                                  'name': '',
                                  'dosePerDay': 0,
                                  'mgPerDose': 0,
                                  'remaining': 0,
                                  'startDate': DateTime.now(),
                                  'endDate': DateTime.now().add(const Duration(days: 30)),
                                  'isActive': true,
                                });
                              });
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Medicine'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Column(
                        children: _medicines.asMap().entries.map((entry) {
                          final index = entry.key;
                          final medicine = entry.value;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Medicine ${index + 1}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            _medicines.removeAt(index);
                                          });
                                        },
                                      )
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  TextFormField(
                                    initialValue: medicine['name'],
                                    decoration: const InputDecoration(
                                      labelText: 'Medicine Name*',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) => medicine['name'] = value,
                                  ),

                                  const SizedBox(height: 12),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          initialValue: medicine['dosePerDay'] == 0 ? '' : medicine['dosePerDay'].toString(),
                                          decoration: const InputDecoration(
                                            labelText: 'Dose per Day*',
                                            border: OutlineInputBorder(),
                                          ),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          onChanged: (value) => medicine['dosePerDay'] = int.tryParse(value) ?? 0,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextFormField(
                                          initialValue: medicine['mgPerDose'] == 0 ? '' : medicine['mgPerDose'].toString(),
                                          decoration: const InputDecoration(
                                            labelText: 'mg per Dose*',
                                            border: OutlineInputBorder(),
                                          ),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          onChanged: (value) =>
                                          medicine['mgPerDose'] = int.tryParse(value) ?? 0,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: ListTile(
                                          title: Text(
                                              "Start: ${_formatDate(medicine['startDate'])}"),
                                          trailing: const Icon(Icons.calendar_today),
                                          onTap: () async {
                                            final picked = await showDatePicker(
                                              context: context,
                                              initialDate: medicine['startDate'],
                                              firstDate: DateTime.now(),
                                              lastDate: DateTime(2030),
                                            );
                                            if (picked != null) {
                                              setState(() => medicine['startDate'] = picked);
                                            }
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: ListTile(
                                          title:
                                          Text("End: ${_formatDate(medicine['endDate'])}"),
                                          trailing: const Icon(Icons.calendar_today),
                                          onTap: () async {
                                            final picked = await showDatePicker(
                                              context: context,
                                              initialDate: medicine['endDate'],
                                              firstDate: DateTime.now(),
                                              lastDate: DateTime(2030),
                                            );
                                            if (picked != null) {
                                              setState(() => medicine['endDate'] = picked);
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _clearForm();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _submitPrescription(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text('Save Prescription'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  void _clearForm() {
    setState(() {
      _descriptionController.clear();
      _medicines.clear();
    });

  }


  Future<void> _submitPrescription(BuildContext context) async {
    if (_selectedPatientId==null ||
        _descriptionController.text.isEmpty) {
      _showErrorDialog('Validation Error', 'Please fill all required fields');
      return;
    }

    if (_medicines.isEmpty) {
      _showErrorDialog('Validation Error', 'Please add at least one medicine');
      return;
    }

    for (var i = 0; i < _medicines.length; i++) {
      final medicine = _medicines[i];
      if (medicine['name'].isEmpty ||
          medicine['dosePerDay'] == 0 ||
          medicine['mgPerDose'] == 0) {
        _showErrorDialog('Validation Error', 'Please fill all required fields for Medicine ${i + 1}');
        return;
      }
    }

    try {
      final prescription = PrescriptionDto(
        id:0,
        patientId: _selectedPatientId!,
        doctorId: 2,
        createdAt: DateTime.now(),
        description: _descriptionController.text,
        medicines: _medicines.map((med) => Medicine(
          id: 0,
          name: med['name'],
          dosePerDay: med['dosePerDay'],
          mgPerDose: med['mgPerDose'],
          remaining: med['remaining'],
          startDate: med['startDate'],
          endDate: med['endDate'],
          prescriptionId: 0,
          isActive: med['isActive'] ?? true,
        )).toList(),
      );
      print(prescription);
      await _prescriptionService.createPrescription(prescription);

      _showSuccessDialog('Success', 'Prescription created successfully!');

      _loadPrescriptions();



    } catch (e) {
      _showErrorDialog('Error', 'Failed to create prescription: $e');
    }
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.successColor),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _prescriptions.where((p) {
      final patientName = _users
          .firstWhere(
            (user) => user['id'] == p.patientId,
        orElse: () => {'name': 'Unknown'},
      )['name']
          .toString()
          .toLowerCase();

      final matchSearch = patientName.contains(searchQuery.toLowerCase());

      if (filter == "All") return matchSearch;
      if (filter == "0-2 meds") return matchSearch && p.medicines.length <= 2;
      if (filter == "3+ meds") return matchSearch && p.medicines.length >= 3;
      return matchSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Prescription List"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showAddPrescriptionDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text("Add Prescription"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: "Search by patient name...",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) =>
                            setState(() => searchQuery = value),
                      ),
                    ),
                    const SizedBox(width: 20),
                    DropdownButton<String>(
                      value: filter,
                      items: const [
                        DropdownMenuItem(value: "All", child: Text("All")),
                        DropdownMenuItem(
                          value: "0-2 meds",
                          child: Text("0-2 meds"),
                        ),
                        DropdownMenuItem(
                          value: "3+ meds",
                          child: Text("3+ meds"),
                        ),
                      ],
                      onChanged: (value) => setState(() => filter = value!),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: _horizontalController,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: _horizontalController,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: constraints.maxWidth,
                          ),
                          child: DataTable(
                            columnSpacing: 20,
                            columns: const [
                              DataColumn(label: Text("Patient Name")),
                              DataColumn(label: Text("Created Date")),
                              DataColumn(label: Text("Medicines")),
                              DataColumn(label: Text("Actions")),
                            ],
                            rows: filtered.map((p) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(
                                    _users.firstWhere(
                                          (user) => user['id'] == p.patientId,
                                      orElse: () => {'name': 'Unknown'},
                                    )['name'],
                                  )),
                                  DataCell(Text(_formatDate(p.createdAt))),
                                  DataCell(Text(p.medicines.length.toString())),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.visibility),
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) => PrescriptionDetailPage(
                                                  prescription: p,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () async {
                                            await PrescriptionService().deletePrescription(p.id!);
                                            _loadPrescriptions();
                                            },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}