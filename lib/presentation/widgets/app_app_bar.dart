import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBack;
  final Color? backgroundColor;

  const AppAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBack = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.primary,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: showBack,
      leading: leading ??
          (showBack
              ? IconButton(
                  icon: Icon(Icons.arrow_back_ios,
                      color: AppColors.textOnPrimary, size: 20.sp),
                  onPressed: () => Navigator.pop(context),
                )
              : null),
      title: Text(title, style: AppTextStyles.h4.copyWith(color: AppColors.textOnPrimary)),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56.h);
}
