import 'package:flutter/material.dart';
import 'package:healthease/theme.dart';

class Sidebar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(2, 0),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Image.asset(
              "assets/images/health_ease_logo.png",
              width: 250)
          ),

          const SizedBox(height: 32),

          // Menu items
          _buildMenuItem(
            index: 0,
            icon: Icons.home_outlined,
            title: "Home",
          ),
          _buildMenuItem(
            index: 1,
            icon: Icons.calendar_month,
            title: "Appointments",
          ),
          _buildMenuItem(
            index: 2,
            icon: Icons.description_outlined,
            title: "Prescriptions",
          ),
          _buildMenuItem(
            index: 3,
            icon: Icons.group_outlined,
            title: "Patients",
          ),

          const Spacer(),

          _buildMenuItem(
            index: 99,
            icon: Icons.logout,
            title: "Logout",
            isLogout: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required int index,
    required IconData icon,
    required String title,
    bool isLogout = false,
  }) {
    final bool isSelected = widget.selectedIndex == index;

    return InkWell(
      onTap: () => widget.onItemSelected(index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          border: isSelected
              ? Border(
            left: BorderSide(
              color: AppTheme.primaryColor,
              width: 4,
            ),
          )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textColor.withOpacity(0.7),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryColor : AppTheme.textColor.withOpacity(0.8),
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
