import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../config/di/injection.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/config/app_config.dart';
import '../../../../presentation/widgets/app_app_bar.dart';
import '../../../../presentation/widgets/loading_widget.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../documents/presentation/screens/documents_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../bloc/profile_bloc.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ProfileBloc>()..add(const FetchProfile())),
        BlocProvider(create: (_) => getIt<AuthBloc>()),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) context.go(AppRoutes.login);
        },
        child: const _ProfileView(),
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(title: 'My Profile'),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) return const LoadingWidget();
          if (state is ProfileError) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(state.message, style: AppTextStyles.bodyMedium),
                SizedBox(height: 12.h),
                ElevatedButton(
                  onPressed: () => context.read<ProfileBloc>().add(const FetchProfile()),
                  child: const Text('Retry'),
                ),
              ]),
            );
          }
          final profile = state is ProfileLoaded ? state.profile : null;
          if (profile == null) return const LoadingWidget();
          return SingleChildScrollView(
            child: Column(
              children: [
                // Gradient header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 32.h),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(children: [
                    profile.profileImage != null
                        ? CircleAvatar(
                            radius: 44.r,
                            backgroundImage: NetworkImage(AppConfig.avatarImage(profile.profileImage!)),
                          )
                        : CircleAvatar(
                            radius: 44.r,
                            backgroundColor: AppColors.accent,
                            child: Text(
                              profile.firstName.isNotEmpty ? profile.firstName[0].toUpperCase() : '?',
                              style: AppTextStyles.h1.copyWith(color: AppColors.textOnPrimary),
                            ),
                          ),
                    SizedBox(height: 12.h),
                    Text(profile.fullName, style: AppTextStyles.h3.copyWith(color: AppColors.textOnPrimary)),
                    SizedBox(height: 4.h),
                    if (profile.designation != null)
                      Text(profile.designation!, style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                    SizedBox(height: 4.h),
                    if (profile.companyName != null)
                      Text(profile.companyName!, style: AppTextStyles.caption.copyWith(color: Colors.white60)),
                    SizedBox(height: 16.h),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textOnPrimary,
                        side: const BorderSide(color: Colors.white54),
                        minimumSize: Size(0, 36.h),
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                      ),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<ProfileBloc>(),
                          child: EditProfileScreen(profile: profile),
                        ),
                      )),
                      icon: Icon(Icons.edit_outlined, size: 16.sp),
                      label: const Text('Edit Profile'),
                    ),
                  ]),
                ),
                SizedBox(height: 16.h),
                _InfoSection(title: 'Personal Info', items: [
                  _InfoItem(icon: Icons.email_outlined, label: 'Email', value: profile.email),
                  if (profile.phone != null) _InfoItem(icon: Icons.phone_outlined, label: 'Phone', value: profile.phone!),
                  if (profile.address != null) _InfoItem(icon: Icons.location_on_outlined, label: 'Location', value: profile.address!),
                ]),
                SizedBox(height: 12.h),
                _InfoSection(title: 'Work Info', items: [
                  if (profile.employeeId != null) _InfoItem(icon: Icons.badge_outlined, label: 'Employee ID', value: profile.employeeId!),
                  if (profile.department != null) _InfoItem(icon: Icons.work_outline, label: 'Department', value: profile.department!),
                  if (profile.joinedAt != null) _InfoItem(icon: Icons.calendar_today_outlined, label: 'Joined', value: DateFormat('dd MMM yyyy').format(profile.joinedAt!)),
                ]),
                SizedBox(height: 12.h),
                _MenuSection(items: [
                  _MenuItem(icon: Icons.folder_outlined, label: 'My Documents',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DocumentsScreen()))),
                  _MenuItem(icon: Icons.notifications_outlined, label: 'Notifications',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
                  _MenuItem(icon: Icons.lock_outline, label: 'Change Password', onTap: () {}),
                  _MenuItem(icon: Icons.help_outline, label: 'Help & Support', onTap: () {}),
                ]),
                SizedBox(height: 12.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      minimumSize: Size(double.infinity, 52.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              context.read<AuthBloc>().add(const LogoutRequested());
                            },
                            child: Text('Logout', style: TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    ),
                    icon: Icon(Icons.logout, size: 18.sp),
                    label: const Text('Logout'),
                  ),
                ),
                SizedBox(height: 32.h),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<_InfoItem> items;
  const _InfoSection({required this.title, required this.items});
  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
          child: Text(title, style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary)),
        ),
        ...items,
      ]),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon; final String label, value;
  const _InfoItem({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    child: Row(children: [
      Icon(icon, size: 18.sp, color: AppColors.primary),
      SizedBox(width: 12.w),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppTextStyles.caption),
        Text(value, style: AppTextStyles.bodyMedium),
      ])),
    ]),
  );
}

class _MenuSection extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuSection({required this.items});
  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.symmetric(horizontal: 16.w),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12.r),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
    ),
    child: Column(children: items),
  );
}

class _MenuItem extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: AppColors.primary, size: 20.sp),
    title: Text(label, style: AppTextStyles.bodyMedium),
    trailing: Icon(Icons.chevron_right, color: AppColors.textHint, size: 20.sp),
    onTap: onTap,
  );
}
