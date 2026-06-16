import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../config/di/injection.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../attendance/presentation/screens/check_in_out_screen.dart';
import '../../../attendance/presentation/bloc/attendance_bloc.dart';
import '../../../mileage/presentation/screens/track_mileage_screen.dart';
import '../../../mileage/presentation/screens/claim_expenses_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../sos/presentation/widgets/sos_dialog.dart';
import '../../../../presentation/widgets/coming_soon_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen2 extends StatefulWidget {
  const HomeScreen2({super.key});

  @override
  State<HomeScreen2> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen2> {
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  void _navigateToTab(int index) {
    final dashboardState = context
        .findAncestorStateOfType<DashboardScreenState>();
    if (dashboardState != null) {
      dashboardState.changeTab(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentDateString = DateFormat(
      'EEEE, dd MMM yyyy',
    ).format(DateTime.now());

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final profile = state is ProfileLoaded ? state.profile : null;
        final firstName = profile?.firstName ?? 'Hopper';

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // 1. Custom App Bar / Header Section
                _buildHeader(context, firstName),

                // Scrollable Body
                Expanded(
                  child: RefreshIndicator(
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
                        top: 8.h,
                        bottom:
                            80.h, // Bottom padding to avoid navigation overlay
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 2. Featured Blue Task Banner
                          _buildTaskBanner(currentDateString),
                          SizedBox(height: 16.h),

                          // 3. Upcoming Task
                          _buildSectionHeader(
                            title: 'Upcoming Task',
                            actionText: 'View All',
                            onActionTap: () => _navigateToTab(1),
                          ),
                          SizedBox(height: 8.h),
                          _buildUpcomingTaskCard(),
                          SizedBox(height: 16.h),

                          // 4. Quick Actions
                          _buildSectionHeader(
                            title: 'Quick Actions',
                            actionText: 'View All',
                            onActionTap: () => _navigateToTab(4),
                          ),
                          SizedBox(height: 12.h),
                          _buildQuickActions(context),
                          SizedBox(height: 16.h),

                          // 5. Leave Balance
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
                          SizedBox(height: 8.h),
                          _buildLeaveBalance(),
                          SizedBox(height: 16.h),

                          // 6. Announcements
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
                          SizedBox(height: 8.h),
                          _buildAnnouncementsCard(context),
                          SizedBox(height: 16.h),

                          // 7. Recent Messages
                          _buildSectionHeader(
                            title: 'Recent Messages',
                            actionText: 'View All',
                            onActionTap: () => _navigateToTab(3),
                          ),
                          SizedBox(height: 8.h),
                          _buildRecentMessages(context),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Header Welcome bar
  Widget _buildHeader(BuildContext context, String name) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _navigateToTab(4),
                child: Icon(Icons.menu, color: Colors.black87, size: 24.sp),
              ),
              SizedBox(width: 14.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14.sp,
                      fontFamily: 'AirbnbCereal',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$name! 👋',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.sp,
                      fontFamily: 'AirbnbCereal',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Have a productive day!',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11.sp,
                      fontFamily: 'AirbnbCereal',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.notifications_none_outlined,
                    color: Colors.black87,
                    size: 24.sp,
                  ),
                ),
                Positioned(
                  right: 4.w,
                  top: 4.h,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Task banner gradient card
  Widget _buildTaskBanner(String currentDate) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -10.w,
            bottom: -15.h,
            child: Icon(
              Icons.assignment_outlined,
              size: 100.w,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today is $currentDate',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 12.sp,
                  fontFamily: 'AirbnbCereal',
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'You have 2 tasks today',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontFamily: 'AirbnbCereal',
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () => _navigateToTab(1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1D4ED8),
                  elevation: 0,
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 10.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View My Tasks',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: 'AirbnbCereal',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14.sp,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Generic Section Header
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
            color: Colors.black,
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
              color: const Color(0xFF2563EB),
              fontSize: 12.sp,
              fontFamily: 'AirbnbCereal',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // Upcoming Task Card
  Widget _buildUpcomingTaskCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: const BoxDecoration(
              color: Color(0xFFF0FDF4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.trending_up,
              color: const Color(0xFF16A34A),
              size: 22.sp,
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
                    color: Colors.black87,
                    fontSize: 13.5.sp,
                    fontFamily: 'AirbnbCereal',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.grey.shade400,
                      size: 12.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Today, 10:00 AM',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11.sp,
                        fontFamily: 'AirbnbCereal',
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Icon(
                      Icons.location_on_outlined,
                      color: Colors.grey.shade400,
                      size: 12.sp,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'Building A, 2nd Floor',
                        style: TextStyle(
                          color: Colors.grey.shade600,
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
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              'In Progress',
              style: TextStyle(
                color: const Color(0xFF15803D),
                fontSize: 10.sp,
                fontFamily: 'AirbnbCereal',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Quick Actions Horizontal list
  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _ActionItem(
        label: 'Check In',
        icon: Icons.login,
        bgColor: const Color(0xFFEFF6FF),
        iconColor: const Color(0xFF2563EB),
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
        bgColor: const Color(0xFFFFF7ED),
        iconColor: const Color(0xFFEA580C),
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
        icon: Icons.speed_outlined,
        bgColor: const Color(0xFFECFDF5),
        iconColor: const Color(0xFF059669),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TrackMileageScreen()),
          );
        },
      ),
      _ActionItem(
        label: 'Leave',
        icon: Icons.calendar_month_outlined,
        bgColor: const Color(0xFFFAF5FF),
        iconColor: const Color(0xFF7C3AED),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ComingSoonScreen(
                title: 'Leave',
                icon: Icons.calendar_month_outlined,
              ),
            ),
          );
        },
      ),
      _ActionItem(
        label: 'SOS',
        icon: Icons.shield_outlined,
        bgColor: const Color(0xFFFEF2F2),
        iconColor: const Color(0xFFDC2626),
        onTap: () {
          showDialog(context: context, builder: (context) => const SosDialog());
        },
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((act) {
        return Expanded(
          child: Column(
            children: [
              GestureDetector(
                onTap: act.onTap,
                child: Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: act.bgColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: act.iconColor.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(act.icon, color: act.iconColor, size: 22.sp),
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                act.label,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 11.sp,
                  fontFamily: 'AirbnbCereal',
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Leave Balance Row
  Widget _buildLeaveBalance() {
    return Row(
      children: [
        _buildLeaveCard(
          'Annual Leave',
          '12.5',
          const Color(0xFF3B82F6),
          const Color(0xFFEFF6FF),
        ),
        SizedBox(width: 8.w),
        _buildLeaveCard(
          'Sick Leave',
          '5.0',
          const Color(0xFF10B981),
          const Color(0xFFECFDF5),
        ),
        SizedBox(width: 8.w),
        _buildLeaveCard(
          'Casual Leave',
          '3.0',
          const Color(0xFF8B5CF6),
          const Color(0xFFF5F3FF),
        ),
        SizedBox(width: 8.w),
        _buildLeaveCard(
          'Comp Off',
          '2.0',
          const Color(0xFFF59E0B),
          const Color(0xFFFFFBEB),
        ),
      ],
    );
  }

  Widget _buildLeaveCard(
    String title,
    String count,
    Color countColor,
    Color bgColor,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.01),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 9.5.sp,
                fontFamily: 'AirbnbCereal',
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 6.h),
            Text(
              count,
              style: TextStyle(
                color: countColor,
                fontSize: 16.sp,
                fontFamily: 'AirbnbCereal',
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Days Available',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 8.5.sp,
                fontFamily: 'AirbnbCereal',
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Announcements card
  Widget _buildAnnouncementsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: const BoxDecoration(
              color: Color(0xFFFAF5FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.campaign_outlined,
              color: const Color(0xFF7C3AED),
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
                    color: Colors.black87,
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
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '2h ago',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 9.sp,
                  fontFamily: 'AirbnbCereal',
                ),
              ),
              SizedBox(height: 6.h),
              Container(
                width: 7.w,
                height: 7.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Recent Messages list
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
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(messages.length, (index) {
          final msg = messages[index];
          return Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 2.h,
                ),
                leading: CircleAvatar(
                  radius: 20.r,
                  backgroundImage: NetworkImage(msg.avatarUrl),
                  backgroundColor: Colors.grey.shade200,
                ),
                title: Text(
                  msg.name,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 12.5.sp,
                    fontFamily: 'AirbnbCereal',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11.sp,
                      fontFamily: 'AirbnbCereal',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2563EB),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${msg.unreadCount}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey.shade300,
                      size: 11.sp,
                    ),
                  ],
                ),
                onTap: () => _navigateToTab(3),
              ),
              if (index < messages.length - 1)
                Divider(
                  height: 1.h,
                  thickness: 0.5.h,
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
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;
  _ActionItem({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
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
