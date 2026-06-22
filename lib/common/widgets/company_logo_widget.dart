import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/di/injection.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';

/// Circle widget showing the company logo — used as an AppBar action on every screen.
/// Reads logo URL from ProfileBloc (if available) then falls back to SharedPreferences.
class CompanyLogoWidget extends StatelessWidget {
  final double? size;

  const CompanyLogoWidget({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    String? logoUrl;

    // Try ProfileBloc first (available on screens that provide it)
    try {
      final state = BlocProvider.of<ProfileBloc>(context, listen: false).state;
      if (state is ProfileLoaded) logoUrl = state.profile.companyLogo;
    } catch (_) {}

    // Fall back to SharedPreferences
    if (logoUrl == null || logoUrl.isEmpty) {
      final prefs = getIt<SharedPreferences>();
      logoUrl = prefs.getString('company_logo');
    }

    final s = size ?? 38.w;
    final hasLogo = logoUrl != null && logoUrl.isNotEmpty;

    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade400, width: 1.5),
        image: hasLogo
            ? DecorationImage(
                image: NetworkImage(logoUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: hasLogo
          ? null
          : ClipOval(
              child: Image.asset(
                AppIcons.appLogo,
                fit: BoxFit.contain,
                errorBuilder: (_, e, s) => Icon(
                  Icons.business,
                  color: AppColors.primary,
                  size: (size ?? 38.w) * 0.5,
                ),
              ),
            ),
    );
  }
}

/// Convenience padding wrapper to drop into AppBar.actions lists.
class CompanyLogoAction extends StatelessWidget {
  final double? size;

  const CompanyLogoAction({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: Center(child: CompanyLogoWidget(size: size)),
    );
  }
}
