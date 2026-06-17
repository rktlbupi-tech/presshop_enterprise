import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:presshop_enterprise/features/dashboard/presentation/screens/home_screen_v3.dart';
import 'package:presshop_enterprise/features/profile/presentation/bloc/profile_bloc.dart';
import '../../../attendance/presentation/bloc/attendance_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../content/presentation/screens/evidence_screen.dart';
import '../../../tasks/presentation/screens/task_schedule_screen.dart';
import '../../../map/presentation/screens/team_map_screen.dart';
import '../../../map/presentation/bloc/map_cubit.dart';
import '../../../map/presentation/bloc/employee_map_cubit.dart';
import '../../../menu/presentation/screens/menu_screen.dart';
import '../../../../config/di/injection.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 2;

  static const String _iconsPath = 'assets/icons/';

  late final AttendanceBloc _attendanceBloc;
  late final ProfileBloc _profileBloc;
  late final MapCubit _mapCubit;
  late final EmployeeMapCubit _employeeMapCubit;

  // Invariant screens created once — never recreated on tab changes.
  late final Widget _evidenceScreen;
  late final Widget _taskScreen;
  late final Widget _homeScreen;
  late final Widget _menuScreen;

  @override
  void initState() {
    super.initState();
    _attendanceBloc = getIt<AttendanceBloc>()..add(const FetchAttendanceLog());
    _profileBloc = getIt<ProfileBloc>()..add(const FetchProfile());
    _mapCubit = MapCubit();
    _employeeMapCubit = EmployeeMapCubit();
    _evidenceScreen = const EvidenceScreen(hideLeading: true);
    _taskScreen = const TaskScheduleScreen(hideLeading: true);
    _homeScreen = BlocProvider.value(
      value: _attendanceBloc,
      child: const HomeScreen3(),
    );
    _menuScreen = const MenuScreen();
  }

  @override
  void dispose() {
    _mapCubit.close();
    _employeeMapCubit.close();
    super.dispose();
  }

  void changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = 24.sp;
    // Only TeamMapScreen needs isScreenActive updated dynamically.
    final screens = [
      _evidenceScreen,
      _taskScreen,
      _homeScreen,
      MultiBlocProvider(
        key: const ValueKey('team_map_bloc_provider'),
        providers: [
          BlocProvider.value(value: _mapCubit),
          BlocProvider.value(value: _employeeMapCubit),
        ],
        child: TeamMapScreen(
          key: const ValueKey('team_map_screen'),
          isScreenActive: _currentIndex == 3,
        ),
      ),
      _menuScreen,
    ];

    return BlocProvider.value(
      value: _profileBloc,
      child: Scaffold(
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
