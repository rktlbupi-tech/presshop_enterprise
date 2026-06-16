import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:presshop_enterprise/features/dashboard/presentation/screens/home_screen_v2.dart';
import 'package:presshop_enterprise/features/profile/presentation/bloc/profile_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../content/presentation/screens/evidence_screen.dart';
import '../../../tasks/presentation/screens/task_schedule_screen.dart';
import '../../../map/presentation/screens/team_map_screen.dart';
import '../../../map/presentation/bloc/map_cubit.dart';
import '../../../map/presentation/bloc/employee_map_cubit.dart';
import '../../../menu/presentation/screens/menu_screen.dart';
import '../../../../config/di/injection.dart';
import 'home_screen.dart';

/// Employee dashboard shell — 1:1 with the old app's bottom navigation:
/// Evidence · Task · Home (center) · Team · Menu, blue selected,
/// Home as the default landing tab.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  // Defaults to the Home tab (index 2).
  int _currentIndex = 2;

  static const String _iconsPath = 'assets/icons/';

  void changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = 24.sp;
    final screens = [
      const EvidenceScreen(hideLeading: true),
      const TaskScheduleScreen(hideLeading: true),
      const HomeScreen2(),
      MultiBlocProvider(
        key: const ValueKey('team_map_bloc_provider'),
        providers: [
          BlocProvider(create: (_) => MapCubit()),
          BlocProvider(create: (_) => EmployeeMapCubit()),
        ],
        child: TeamMapScreen(
          key: const ValueKey('team_map_screen'),
          isScreenActive: _currentIndex == 3,
        ),
      ),
      const MenuScreen(),
    ];

    return BlocProvider(
      create: (_) => getIt<ProfileBloc>()..add(const FetchProfile()),
      child: Scaffold(
        extendBody: true,
        backgroundColor: AppColors.surface,
        body: IndexedStack(index: _currentIndex, children: screens),
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
            fontFamily: 'AirbnbCereal',
          ),
          unselectedLabelStyle: const TextStyle(fontFamily: 'AirbnbCereal'),
          items: [
            _navItem('${_iconsPath}ic_content1.png', 'Evidence', 0, iconSize),
            _navItem('${_iconsPath}ic_task1.png', 'Task', 1, iconSize),
            _navItem('${_iconsPath}ic_home.svg', 'Home', 2, iconSize),
            _navItem('${_iconsPath}ic_teams2.png', 'Team', 3, iconSize),
            _navItem('${_iconsPath}menu3.png', 'Menu', 4, iconSize, scale: 1.2),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _navItem(
    dynamic iconSource,
    String label,
    int index,
    double iconSize, {
    double scale = 1.0,
  }) {
    final selected = _currentIndex == index;
    final color = selected ? AppColors.primary : Colors.black;

    Widget iconWidget;
    if (iconSource is IconData) {
      iconWidget = Icon(iconSource, color: color, size: iconSize);
    } else if (iconSource is String && iconSource.endsWith('.svg')) {
      iconWidget = SvgPicture.asset(
        iconSource,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        width: iconSize,
        height: iconSize,
      );
    } else {
      iconWidget = ImageIcon(
        AssetImage(iconSource as String),
        color: color,
        size: iconSize,
      );
    }

    return BottomNavigationBarItem(
      label: label,
      icon: Transform.scale(scale: scale, child: iconWidget),
    );
  }
}
