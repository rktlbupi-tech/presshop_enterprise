import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../config/di/injection.dart';
import '../../../../common/widgets/employee_app_bar.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final prefs = getIt<SharedPreferences>();
    final onDuty = prefs.getBool('on_duty') ?? false;

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final profile = state is ProfileLoaded ? state.profile : null;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: EmployeeAppBar(
            isOnline: onDuty,
            firstNameOverride: profile?.firstName,
            lastNameOverride: profile?.lastName,
            companyNameOverride: profile?.companyName,
            avatarOverride: profile?.profileImage,
            companyLogoOverride: profile?.companyLogo,
            onProfileTap: () {
              final dashboardState = context
                  .findAncestorStateOfType<DashboardScreenState>();
              if (dashboardState != null) {
                dashboardState.changeTab(
                  4,
                ); // Switch to Menu screen where profile actions live
              }
            },
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<ProfileBloc>().add(const FetchProfile());
              setState(() {});
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              children: [
                _buildCameraCard(context),
                SizedBox(height: 12.h),
                _buildRecentTasksSection(context),
                SizedBox(height: 12.h),
                _buildRecentContentSection(context),
                SizedBox(height: 12.h),
                _buildTopStoriesSection(context),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        );
      },
    );
  }

  // 1. Camera Card Design
  Widget _buildCameraCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF030D1B), Color(0xFF0A1E3F), Color(0xFF0F2E63)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A1E3F).withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          children: [
            // Concentric Glow Rings on the Right
            Positioned(
              right: -30.w,
              top: -10.h,
              bottom: -10.h,
              child: SizedBox(
                width: 180.w,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer ring
                      Container(
                        width: 150.w,
                        height: 150.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.05),
                            width: 1.2.w,
                          ),
                        ),
                      ),
                      // Middle ring
                      Container(
                        width: 120.w,
                        height: 120.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.08),
                            width: 1.2.w,
                          ),
                        ),
                      ),
                      // Inner glowing circle
                      Container(
                        width: 90.w,
                        height: 90.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue.shade600.withValues(alpha: 0.4),
                              Colors.blue.shade900.withValues(alpha: 0.6),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.2),
                            width: 1.5.w,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade500.withValues(
                                alpha: 0.25,
                              ),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                          size: 32.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Text Content on the Left
            Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                top: 16.h,
                bottom: 16.h,
                right: 125.w,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Capture the\nmoment. Share\nthe story.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'AirbnbCereal',
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "Report real-time updates and make an impact.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11.sp,
                      fontFamily: 'AirbnbCereal',
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Recent Tasks Widget
  Widget _buildRecentTasksSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent Tasks",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'AirbnbCereal',
              ),
            ),
            GestureDetector(
              onTap: () {
                final dashboardState = context
                    .findAncestorStateOfType<DashboardScreenState>();
                if (dashboardState != null) {
                  dashboardState.changeTab(1); // Switch to Task screen
                }
              },
              child: Text(
                "View all",
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'AirbnbCereal',
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.grey.shade200, width: 1.w),
          ),
          child: Column(
            children: [
              _buildTaskItem(
                icon: Icons.description_outlined,
                iconBgColor: const Color(0xFFF3E8FF),
                iconColor: const Color(0xFF9333EA),
                title: "Interview with City Mayor",
                time: "Due today, 3:00 PM",
                statusText: "In Progress",
                statusBgColor: const Color(0xFFF3E8FF),
                statusTextColor: const Color(0xFF9333EA),
                isLast: false,
              ),
              _buildTaskItem(
                icon: Icons.check_circle_outline,
                iconBgColor: const Color(0xFFDCFCE7),
                iconColor: const Color(0xFF16A34A),
                title: "Community Cleanup Drive",
                time: "Due tomorrow, 10:00 AM",
                statusText: "Completed",
                statusBgColor: const Color(0xFFDCFCE7),
                statusTextColor: const Color(0xFF16A34A),
                isLast: false,
              ),
              _buildTaskItem(
                icon: Icons.access_time_outlined,
                iconBgColor: const Color(0xFFFFEDD5),
                iconColor: const Color(0xFFEA580C),
                title: "Breaking: Road Accident",
                time: "Due today, 5:00 PM",
                statusText: "Pending",
                statusBgColor: const Color(0xFFFFEDD5),
                statusTextColor: const Color(0xFFEA580C),
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String time,
    required String statusText,
    required Color statusBgColor,
    required Color statusTextColor,
    required bool isLast,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            children: [
              // Icon Circle
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 16.sp),
              ),
              SizedBox(width: 10.w),
              // Task details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'AirbnbCereal',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 10.5.sp,
                        fontFamily: 'AirbnbCereal',
                      ),
                    ),
                  ],
                ),
              ),
              // Status chip
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusTextColor,
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'AirbnbCereal',
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1.h,
            thickness: 0.5.h,
            color: Colors.grey.shade200,
            indent: 12.w,
            endIndent: 12.w,
          ),
      ],
    );
  }

  // 3. Recent Content Widget
  Widget _buildRecentContentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent Content",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'AirbnbCereal',
              ),
            ),
            GestureDetector(
              onTap: () {
                final dashboardState = context
                    .findAncestorStateOfType<DashboardScreenState>();
                if (dashboardState != null) {
                  dashboardState.changeTab(0); // Switch to Evidence screen
                }
              },
              child: Text(
                "View all",
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'AirbnbCereal',
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        SizedBox(
          height: 146.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildContentCard(
                imageUrl:
                    "https://images.unsplash.com/photo-1541872703-74c5e44368f9?w=400",
                timeText: "2m ago",
                title: "Protest Rally Downtown",
                isImage: true,
              ),
              _buildContentCard(
                imageUrl:
                    "https://images.unsplash.com/photo-1516550893923-42d28e5677af?w=400",
                timeText: "15m ago",
                title: "Fire Breaks Out in Warehouse",
                isImage: false,
              ),
              _buildContentCard(
                imageUrl:
                    "https://images.unsplash.com/photo-1493166228553-4fa0efc7d409?w=400",
                timeText: "1h ago",
                title: "Heavy Rains in Northern Area",
                isImage: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContentCard({
    required String imageUrl,
    required String timeText,
    required String title,
    required bool isImage,
  }) {
    return Container(
      width: 108.w,
      margin: EdgeInsets.only(right: 10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade200, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image / Icon stack
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(7.r),
                    ),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.image,
                          color: Colors.grey,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                // Media Type Icon Badge (Top Right)
                Positioned(
                  top: 4.h,
                  right: 4.w,
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isImage ? Icons.photo_outlined : Icons.videocam_outlined,
                      color: Colors.white,
                      size: 11.sp,
                    ),
                  ),
                ),
                // Duration/Time Badge (Bottom Left)
                Positioned(
                  bottom: 4.h,
                  left: 4.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                    child: Text(
                      timeText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'AirbnbCereal',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Footer
          Padding(
            padding: EdgeInsets.all(6.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'AirbnbCereal',
                      height: 1.15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.more_vert, color: Colors.grey.shade500, size: 14.sp),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. Top Stories Widget
  Widget _buildTopStoriesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Top Stories",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'AirbnbCereal',
              ),
            ),
            GestureDetector(
              onTap: () {
                // Keep interactive flow but just print or do default action
              },
              child: Text(
                "View all",
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'AirbnbCereal',
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.grey.shade200, width: 1.w),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Image
              ClipRRect(
                borderRadius: BorderRadius.circular(6.r),
                child: Image.network(
                  "https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=600",
                  width: 80.w,
                  height: 60.h,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80.w,
                    height: 60.h,
                    color: Colors.grey.shade200,
                    child: Icon(Icons.image, color: Colors.grey, size: 18.sp),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              // Middle text details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TOP STORY",
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'AirbnbCereal',
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      "City Council Approves New Affordable Housing Plan",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'AirbnbCereal',
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      "The Daily Globe • 2h ago",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 9.sp,
                        fontFamily: 'AirbnbCereal',
                      ),
                    ),
                  ],
                ),
              ),
              // Right bookmark button
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bookmark_border,
                  color: Colors.blue.shade700,
                  size: 14.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
