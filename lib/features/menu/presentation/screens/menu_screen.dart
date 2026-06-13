import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../config/di/injection.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../presentation/widgets/coming_soon_screen.dart';
import '../../../../presentation/widgets/employee_app_bar.dart';
import '../../../attendance/presentation/screens/attendance_screen.dart';
import '../../../documents/presentation/screens/documents_screen.dart';
import '../../../earnings/presentation/screens/earnings_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../sos/presentation/widgets/sos_dialog.dart';
import '../../../team_chat/presentation/screens/team_chat_screen.dart';
import '../../../content/presentation/screens/evidence_screen.dart';
import '../../../tasks/presentation/screens/task_schedule_screen.dart';

/// Port of the old app's MenuScreen — the "hub" tab that links to every
/// employee page, grouped into sections, with a duty/online toggle on top.
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool _onDuty = false;

  void _open(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _logout() async {
    final prefs = getIt<SharedPreferences>();
    await prefs.remove('auth_token');
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: EmployeeAppBar(
        isOnline: _onDuty,
        onProfileTap: () => _open(const ProfileScreen()),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
        children: [
          _dutyCard(),
          SizedBox(height: 20.h),
          _section('MY ACCOUNT', [
            _MenuItem('My profile', Icons.person_outline,
                const Color(0xFF4A80F0), const Color(0xFFEEF2FF),
                () => _open(const ProfileScreen())),
            _MenuItem('Digital ID', Icons.badge_outlined,
                const Color(0xFF2DC78A), const Color(0xFFE6F9F2),
                () => _open(const ComingSoonScreen(
                    title: 'Digital ID', icon: Icons.badge_outlined))),
            _MenuItem('Notifications', Icons.notifications_none,
                const Color(0xFFF59E0B), const Color(0xFFFFF8EC),
                () => _open(const NotificationsScreen())),
          ]),
          _section('WORK HUB', [
            _MenuItem('View tasks', Icons.event_note_outlined,
                const Color(0xFF4A80F0), const Color(0xFFEEF2FF),
                () => _open(const TaskScheduleScreen())),
            _MenuItem('Evidence', Icons.collections_outlined,
                const Color(0xFF2DC78A), const Color(0xFFE6F9F2),
                () => _open(const EvidenceScreen())),
            _MenuItem('Submit forms', Icons.description_outlined,
                const Color(0xFF7B61FF), const Color(0xFFF0EEFF),
                () => _open(const ComingSoonScreen(
                    title: 'Submit forms', icon: Icons.description_outlined))),
            _MenuItem('Track mileage', Icons.route_outlined,
                const Color(0xFFF59E0B), const Color(0xFFFFF8EC),
                () => _open(const ComingSoonScreen(
                    title: 'Track mileage', icon: Icons.route_outlined))),
            _MenuItem('Claim expenses', Icons.receipt_long_outlined,
                const Color(0xFF10B981), const Color(0xFFD1FAE5),
                () => _open(const ComingSoonScreen(
                    title: 'Claim expenses',
                    icon: Icons.receipt_long_outlined))),
          ]),
          _section('PAY HUB', [
            _MenuItem('Duties', Icons.work_outline,
                const Color(0xFF3B82F6), const Color(0xFFEFF6FF),
                () => _open(const ComingSoonScreen(
                    title: 'Duties', icon: Icons.work_outline))),
            _MenuItem('Attendance log', Icons.fact_check_outlined,
                const Color(0xFFE11D48), const Color(0xFFFFE4E6),
                () => _open(const AttendanceScreen())),
            _MenuItem('Payslip', Icons.savings_outlined,
                const Color(0xFF10B981), const Color(0xFFD1FAE5),
                () => _open(const ComingSoonScreen(
                    title: 'Payslip', icon: Icons.savings_outlined))),
            _MenuItem('View earnings', Icons.account_balance_wallet_outlined,
                const Color(0xFFF59E0B), const Color(0xFFFEF3C7),
                () => _open(const EarningsScreen())),
            _MenuItem('My documents', Icons.folder_open_outlined,
                const Color(0xFF6366F1), const Color(0xFFE0E7FF),
                () => _open(const DocumentsScreen())),
          ]),
          _section('SAFETY & SUPPORT', [
            _MenuItem('Share alert', Icons.campaign_outlined,
                const Color(0xFFF59E0B), const Color(0xFFFFF8EC),
                () => _open(const ComingSoonScreen(
                    title: 'Share alert', icon: Icons.campaign_outlined))),
            _MenuItem('SOS', Icons.sos_outlined, const Color(0xFFEF4444),
                const Color(0xFFFFEEEE), () => SosDialog.show(context)),
            _MenuItem('Chat', Icons.chat_bubble_outline,
                const Color(0xFF4A80F0), const Color(0xFFEEF2FF),
                () => _open(const TeamChatScreen(
                    roomId: 'general', roomName: 'Team Chat'))),
          ]),
          _section('MORE', [
            _MenuItem('FAQs', Icons.help_outline, const Color(0xFF7B61FF),
                const Color(0xFFF0EEFF),
                () => _open(const ComingSoonScreen(
                    title: 'FAQs', icon: Icons.help_outline))),
            _MenuItem('Settings', Icons.settings_outlined,
                const Color(0xFF64748B), const Color(0xFFF1F5F9),
                () => _open(const ComingSoonScreen(
                    title: 'Settings', icon: Icons.settings_outlined))),
            _MenuItem('Logout', Icons.logout, const Color(0xFFEF4444),
                const Color(0xFFFFEEEE), _logout),
          ]),
        ],
      ),
    );
  }

  Widget _dutyCard() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: (_onDuty ? AppColors.accent : Colors.grey)
                  .withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _onDuty ? Icons.location_on : Icons.location_off_outlined,
              color: _onDuty ? AppColors.accent : Colors.grey,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_onDuty ? 'On Duty' : 'Off Duty',
                    style: AppTextStyles.labelLarge),
                SizedBox(height: 2.h),
                Text(
                  _onDuty ? 'Online — sharing location' : 'Toggle to go on duty',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: _onDuty,
            activeColor: AppColors.accent,
            onChanged: (v) => setState(() => _onDuty = v),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<_MenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(4.w, 16.h, 4.w, 8.h),
          child: Text(
            title,
            style: AppTextStyles.overline.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: List.generate(items.length, (i) {
              final item = items[i];
              return Column(
                children: [
                  ListTile(
                    onTap: item.onTap,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                    leading: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: item.bg,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(item.icon, color: item.color, size: 20.sp),
                    ),
                    title: Text(item.label, style: AppTextStyles.bodyMedium),
                    trailing: Icon(Icons.chevron_right,
                        color: AppColors.textHint, size: 20.sp),
                  ),
                  if (i != items.length - 1)
                    Padding(
                      padding: EdgeInsets.only(left: 64.w),
                      child: Divider(
                          height: 1, color: AppColors.divider),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _MenuItem {
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  _MenuItem(this.label, this.icon, this.color, this.bg, this.onTap);
}
