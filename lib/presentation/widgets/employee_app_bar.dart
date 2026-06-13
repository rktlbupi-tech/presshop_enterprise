import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/di/injection.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';

/// Shared dashboard top bar — port of the old app's [EmployeeDashboardAppBar].
/// Left: circular avatar with an online dot, employee name, media house.
/// Right: company logo. Tapping the left cluster can open the profile.
class EmployeeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isOnline;
  final VoidCallback? onProfileTap;
  final VoidCallback? onFilterTap;

  const EmployeeAppBar({
    super.key,
    this.isOnline = true,
    this.onProfileTap,
    this.onFilterTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final prefs = getIt<SharedPreferences>();
    final firstName = prefs.getString('user_first_name') ?? 'Employee';
    final lastName = prefs.getString('user_last_name') ?? '';
    final fullName = '$firstName $lastName'.trim();
    final mediaHouse = prefs.getString('company_name') ?? 'PressHop Enterprise';
    final avatar = prefs.getString('user_avatar');

    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onProfileTap,
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 42.w,
                          height: 42.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade100,
                            border: Border.all(
                                color: Colors.grey.shade400, width: 1.5),
                            image: (avatar != null && avatar.isNotEmpty)
                                ? DecorationImage(
                                    image: NetworkImage(avatar),
                                    fit: BoxFit.cover)
                                : null,
                          ),
                          child: (avatar == null || avatar.isEmpty)
                              ? Icon(Icons.person,
                                  color: Colors.grey.shade500, size: 24.sp)
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 11.w,
                            height: 11.w,
                            decoration: BoxDecoration(
                              color: isOnline
                                  ? AppColors.accent
                                  : Colors.grey.shade400,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Text(
                            mediaHouse,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (onFilterTap != null)
              IconButton(
                onPressed: onFilterTap,
                icon: Icon(Icons.tune, color: Colors.black87, size: 22.sp),
              ),
            Container(
              height: 42.w,
              width: 42.w,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
              ),
              child: ClipOval(
                child: Image.asset(
                  AppIcons.appLogo,
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, e, st) => Icon(Icons.business,
                      color: AppColors.primary, size: 20.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
