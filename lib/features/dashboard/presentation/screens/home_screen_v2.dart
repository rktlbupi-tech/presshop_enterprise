import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:presshop_enterprise/common/widgets/employee_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../config/di/injection.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../attendance/presentation/screens/check_in_out_screen.dart';
import '../../../attendance/presentation/bloc/attendance_bloc.dart';
import '../../../mileage/presentation/screens/track_mileage_screen.dart';
import '../../../mileage/presentation/screens/claim_expenses_screen.dart';
import '../../../sos/presentation/widgets/sos_dialog.dart';
import '../../../../common/widgets/coming_soon_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen2 extends StatefulWidget {
  const HomeScreen2({super.key});

  @override
  State<HomeScreen2> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen2> {
  void _navigateToTab(int index) {
    context.findAncestorStateOfType<DashboardScreenState>()?.changeTab(index);
  }

  @override
  Widget build(BuildContext context) {
    final prefs = getIt<SharedPreferences>();
    final onDuty = prefs.getBool('on_duty') ?? false;
    final currentDateString = DateFormat(
      'EEEE, dd MMM yyyy',
    ).format(DateTime.now());

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final profile = state is ProfileLoaded ? state.profile : null;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6FB),
          appBar: EmployeeAppBar(
            isOnline: onDuty,
            firstNameOverride: profile?.firstName,
            lastNameOverride: profile?.lastName,
            companyNameOverride: profile?.companyName,
            avatarOverride: profile?.profileImage,
            companyLogoOverride: profile?.companyLogo,
            onProfileTap: () {
              context
                  .findAncestorStateOfType<DashboardScreenState>()
                  ?.changeTab(4);
            },
          ),
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context.read<ProfileBloc>().add(const FetchProfile());
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.only(
                  left: 16.w,
                  right: 16.w,
                  top: 12.h,
                  bottom: 88.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTaskBanner(currentDateString),
                    SizedBox(height: 20.h),

                    _buildSectionHeader(
                      title: 'Upcoming Task',
                      actionText: 'View All',
                      onActionTap: () => _navigateToTab(1),
                    ),
                    SizedBox(height: 10.h),
                    _buildUpcomingTaskCard(),
                    SizedBox(height: 20.h),

                    _buildSectionHeader(
                      title: 'Quick Actions',
                      actionText: 'View All',
                      onActionTap: () => _navigateToTab(4),
                    ),
                    SizedBox(height: 12.h),
                    _buildQuickActions(context),
                    SizedBox(height: 20.h),

                    _buildSectionHeader(
                      title: 'Leave Balance',
                      actionText: 'View Details',
                      onActionTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ComingSoonScreen(
                              title: 'Leave Balance',
                              icon: Icons.calendar_month_outlined,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 10.h),
                    _buildLeaveBalance(),
                    SizedBox(height: 20.h),

                    _buildSectionHeader(
                      title: 'Announcements',
                      actionText: 'View All',
                      onActionTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ComingSoonScreen(
                              title: 'Announcements',
                              icon: Icons.campaign_outlined,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 10.h),
                    _buildAnnouncementsCard(context),
                    SizedBox(height: 20.h),

                    _buildSectionHeader(
                      title: 'Recent Messages',
                      actionText: 'View All',
                      onActionTap: () => _navigateToTab(3),
                    ),
                    SizedBox(height: 10.h),
                    _buildRecentMessages(context),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskBanner(String currentDate) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1877F2), Color(0xFF0C4EC4)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1877F2).withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentDate,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11.sp,
                    fontFamily: 'AirbnbCereal',
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'You have 2 tasks\ndue today',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontFamily: 'AirbnbCereal',
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 18.h),
                GestureDetector(
                  onTap: () => _navigateToTab(1),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 9.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.28),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View My Tasks',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontFamily: 'AirbnbCereal',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 14.sp,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '2',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.sp,
                    fontFamily: 'AirbnbCereal',
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'tasks',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 10.sp,
                    fontFamily: 'AirbnbCereal',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String actionText,
    required VoidCallback onActionTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: const Color(0xFF0F172A),
            fontSize: 15.sp,
            fontFamily: 'AirbnbCereal',
            fontWeight: FontWeight.w700,
          ),
        ),
        GestureDetector(
          onTap: onActionTap,
          child: Text(
            actionText,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12.sp,
              fontFamily: 'AirbnbCereal',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingTaskCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(9.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.task_alt_rounded,
              color: const Color(0xFF64748B),
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Site Inspection – Building A',
                  style: TextStyle(
                    color: const Color(0xFF0F172A),
                    fontSize: 13.sp,
                    fontFamily: 'AirbnbCereal',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      color: const Color(0xFFCBD5E1),
                      size: 11.sp,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'Today, 10:00 AM',
                      style: TextStyle(
                        color: const Color(0xFF94A3B8),
                        fontSize: 11.sp,
                        fontFamily: 'AirbnbCereal',
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Icon(
                      Icons.location_on_outlined,
                      color: const Color(0xFFCBD5E1),
                      size: 11.sp,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'Building A',
                        style: TextStyle(
                          color: const Color(0xFF94A3B8),
                          fontSize: 11.sp,
                          fontFamily: 'AirbnbCereal',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'In Progress',
              style: TextStyle(
                color: const Color(0xFF475569),
                fontSize: 10.sp,
                fontFamily: 'AirbnbCereal',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _ActionItem(
        label: 'Check In',
        icon: Icons.login_rounded,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CheckInOutScreen(attendanceBloc: getIt<AttendanceBloc>()),
            ),
          );
        },
      ),
      _ActionItem(
        label: 'Expenses',
        icon: Icons.receipt_long_outlined,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ClaimExpensesScreen(),
            ),
          );
        },
      ),
      _ActionItem(
        label: 'Mileage',
        icon: Icons.speed_rounded,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TrackMileageScreen()),
          );
        },
      ),
      _ActionItem(
        label: 'Leave',
        icon: Icons.event_available_outlined,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ComingSoonScreen(
                title: 'Leave',
                icon: Icons.event_available_outlined,
              ),
            ),
          );
        },
      ),
      _ActionItem(
        label: 'SOS',
        icon: Icons.shield_outlined,
        isSos: true,
        onTap: () {
          showDialog(context: context, builder: (context) => const SosDialog());
        },
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((act) {
        return Expanded(
          child: GestureDetector(
            onTap: act.onTap,
            child: Column(
              children: [
                Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    color: act.isSos
                        ? const Color(0xFFFEF2F2)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    act.icon,
                    color: act.isSos
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF475569),
                    size: 22.sp,
                  ),
                ),
                SizedBox(height: 7.h),
                Text(
                  act.label,
                  style: TextStyle(
                    color: const Color(0xFF475569),
                    fontSize: 10.5.sp,
                    fontFamily: 'AirbnbCereal',
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLeaveBalance() {
    return Row(
      children: [
        _buildLeaveCard('Annual', '12.5'),
        SizedBox(width: 8.w),
        _buildLeaveCard('Sick', '5.0'),
        SizedBox(width: 8.w),
        _buildLeaveCard('Casual', '3.0'),
        SizedBox(width: 8.w),
        _buildLeaveCard('Comp Off', '2.0'),
      ],
    );
  }

  Widget _buildLeaveCard(String title, String count) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                color: const Color(0xFF0F172A),
                fontSize: 17.sp,
                fontFamily: 'AirbnbCereal',
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              title,
              style: TextStyle(
                color: const Color(0xFF94A3B8),
                fontSize: 9.sp,
                fontFamily: 'AirbnbCereal',
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.h),
            Text(
              'days',
              style: TextStyle(
                color: const Color(0xFFCBD5E1),
                fontSize: 8.5.sp,
                fontFamily: 'AirbnbCereal',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(9.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.campaign_outlined,
              color: const Color(0xFF64748B),
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Safety Guidelines',
                  style: TextStyle(
                    color: const Color(0xFF0F172A),
                    fontSize: 13.sp,
                    fontFamily: 'AirbnbCereal',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'New safety guidelines have been updated.',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11.sp,
                    fontFamily: 'AirbnbCereal',
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '2h ago',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 9.5.sp,
                  fontFamily: 'AirbnbCereal',
                ),
              ),
              SizedBox(height: 6.h),
              Container(
                width: 7.w,
                height: 7.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF1877F2),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMessages(BuildContext context) {
    final messages = [
      _MessageModel(
        name: 'Rohit Sharma',
        text: 'The inspection report is ready.',
        time: '10:30 AM',
        unreadCount: 2,
        avatarUrl:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100',
      ),
      _MessageModel(
        name: 'Site Team – Building A',
        text: 'Please submit your daily report.',
        time: '9:45 AM',
        unreadCount: 5,
        avatarUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
      ),
      _MessageModel(
        name: 'HR Team',
        text: 'Your leave request has been approved.',
        time: 'Yesterday',
        unreadCount: 1,
        avatarUrl:
            'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=100',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(messages.length, (index) {
          final msg = messages[index];
          return Column(
            children: [
              InkWell(
                onTap: () => _navigateToTab(3),
                borderRadius: BorderRadius.circular(12.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20.r,
                        backgroundImage: NetworkImage(msg.avatarUrl),
                        backgroundColor: Colors.grey.shade100,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.name,
                              style: TextStyle(
                                color: const Color(0xFF0F172A),
                                fontSize: 12.5.sp,
                                fontFamily: 'AirbnbCereal',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              msg.text,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 11.sp,
                                fontFamily: 'AirbnbCereal',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            msg.time,
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 9.5.sp,
                              fontFamily: 'AirbnbCereal',
                            ),
                          ),
                          if (msg.unreadCount > 0) ...[
                            SizedBox(height: 5.h),
                            Container(
                              constraints: BoxConstraints(minWidth: 18.w),
                              padding: EdgeInsets.symmetric(
                                horizontal: 5.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                '${msg.unreadCount}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.sp,
                                  fontFamily: 'AirbnbCereal',
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (index < messages.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: const Color(0xFFF1F5F9),
                  indent: 14.w,
                  endIndent: 14.w,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _ActionItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSos;
  _ActionItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isSos = false,
  });
}

class _MessageModel {
  final String name;
  final String text;
  final String time;
  final int unreadCount;
  final String avatarUrl;
  _MessageModel({
    required this.name,
    required this.text,
    required this.time,
    required this.unreadCount,
    required this.avatarUrl,
  });
}
