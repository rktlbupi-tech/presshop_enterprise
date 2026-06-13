import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../content/presentation/screens/evidence_screen.dart';
import '../../../tasks/presentation/screens/task_schedule_screen.dart';
import '../../../camera/presentation/screens/employee_camera_screen.dart';
import '../../../map/presentation/screens/team_map_screen.dart';
import '../../../menu/presentation/screens/menu_screen.dart';

/// Employee dashboard shell — 1:1 with the old app's bottom navigation:
/// Evidence · Task · Camera (center, enlarged) · Team · Menu, blue selected,
/// Camera as the default landing tab.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Old app defaults to the Camera tab (index 2).
  int _currentIndex = 2;

  late final List<Widget> _screens = [
    const EvidenceScreen(hideLeading: true),
    const TaskScheduleScreen(hideLeading: true),
    const EmployeeCameraScreen(),
    const TeamMapScreen(),
    const MenuScreen(),
  ];

  static const String _iconsPath = 'assets/icons/';

  @override
  Widget build(BuildContext context) {
    final iconSize = 24.sp;
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.surface,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.surface,
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        elevation: 0,
        iconSize: iconSize,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.black,
        selectedFontSize: 11.sp,
        unselectedFontSize: 11.sp,
        selectedLabelStyle: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins'),
        items: [
          _navItem('${_iconsPath}ic_content1.png', 'Evidence', 0, iconSize),
          _navItem('${_iconsPath}ic_task1.png', 'Task', 1, iconSize),
          _navItem('${_iconsPath}ic_camera1.png', 'Camera', 2, iconSize,
              scale: 1.3),
          _navItem('${_iconsPath}ic_teams2.png', 'Team', 3, iconSize),
          _navItem('${_iconsPath}menu3.png', 'Menu', 4, iconSize, scale: 1.2),
        ],
      ),
    );
  }

  BottomNavigationBarItem _navItem(
    String asset,
    String label,
    int index,
    double iconSize, {
    double scale = 1.0,
  }) {
    final selected = _currentIndex == index;
    final color = selected ? AppColors.primary : Colors.black;
    return BottomNavigationBarItem(
      label: label,
      icon: Transform.scale(
        scale: scale,
        child: ImageIcon(AssetImage(asset), color: color, size: iconSize),
      ),
    );
  }
}
