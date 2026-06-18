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
  final int initialIndex;
  const DashboardScreen({super.key, this.initialIndex = 2});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  late int _currentIndex;

  // One-shot intents to deep-link the Team map into SOS / Share Alert
  // (used by the Menu tab — mirrors the old app's openSos / openShareAlert).
  bool _mapOpenSos = false;
  bool _mapOpenShareAlert = false;

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
    _currentIndex = widget.initialIndex;
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

  /// Switches to the Team map tab and opens the SOS or Share Alert panel
  /// (matches the old app's menu behaviour).
  void openTeamMap({bool sos = false, bool shareAlert = false}) {
    setState(() {
      _currentIndex = 3;
      _mapOpenSos = sos;
      _mapOpenShareAlert = shareAlert;
    });
    // Reset the one-shot flags so a later tap can re-trigger them.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && (_mapOpenSos || _mapOpenShareAlert)) {
        setState(() {
          _mapOpenSos = false;
          _mapOpenShareAlert = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = 22.sp;
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
          openSosDirectly: _mapOpenSos,
          openShareAlertDirectly: _mapOpenShareAlert,
        ),
      ),
      _menuScreen,
    ];

    return BlocProvider.value(
      value: _profileBloc,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: IndexedStack(index: _currentIndex, children: screens),
        bottomNavigationBar: Container(
          height: MediaQuery.of(context).padding.bottom + 68.h,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 4.h,
            top: 6.h,
            left: 8.w,
            right: 8.w,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: const Color(0xFFEFF1F5), width: 1.w),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCustomNavItem(
                '${_iconsPath}ic_content1.png',
                'Evidence',
                0,
                iconSize,
              ),
              _buildCustomNavItem(
                '${_iconsPath}ic_task1.png',
                'Tasks',
                1,
                iconSize,
              ),
              _buildCustomNavItem(
                '${_iconsPath}ic_home.svg',
                'Home',
                2,
                iconSize,
              ),
              _buildCustomNavItem(
                '${_iconsPath}ic_teams2.png',
                'Team',
                3,
                iconSize,
              ),
              _buildCustomNavItem(
                '${_iconsPath}menu3.png',
                'Menu',
                4,
                iconSize,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomNavItem(
    dynamic iconSource,
    String label,
    int index,
    double iconSize, {
    double scale = 1.0,
  }) {
    final selected = _currentIndex == index;
    final color = selected ? Colors.white : Colors.black87;

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

    return GestureDetector(
      onTap: () => changeTab(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 58.w,
        height: 58.w,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.scale(scale: scale, child: iconWidget),
            SizedBox(height: 3.h),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11.sp,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontFamily: 'AirbnbCereal',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
