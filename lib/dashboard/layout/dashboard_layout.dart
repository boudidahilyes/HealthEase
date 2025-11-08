import 'package:flutter/material.dart';
import 'package:healthease/dashboard/pages/prescription/prescription_list.dart';
import 'package:healthease/dashboard/widgets/common/sidebar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Row(
        children: [
          Sidebar(
            selectedIndex: selectedIndex,
            onItemSelected: (index) {
              setState(() => selectedIndex = index);
            },
          ),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: _buildPage(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage() {
    switch (selectedIndex) {
      case 0:
        return const Text("Home", style: TextStyle(fontSize: 22));
      case 1:
        return const Text("Appointments", style: TextStyle(fontSize: 22));
      case 2:
        return PrescriptionListPage();
      case 3:
        return const Text("Patients", style: TextStyle(fontSize: 22));
      default:
        return const Text("Unknown Page");
    }
  }
}
