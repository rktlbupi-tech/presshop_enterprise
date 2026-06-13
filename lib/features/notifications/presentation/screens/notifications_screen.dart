import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../presentation/widgets/app_app_bar.dart';
import '../../../../presentation/widgets/empty_state.dart';

class _Notif {
  final String id, title, body, type;
  final DateTime time;
  final bool read;
  const _Notif({required this.id, required this.title, required this.body, required this.type, required this.time, this.read = false});
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_Notif> _notifs = [
    _Notif(id: '1', title: 'New Task Assigned', body: 'Cover press conference at City Hall by 13 Jun 2026', type: 'task', time: DateTime.now().subtract(const Duration(minutes: 30))),
    _Notif(id: '2', title: 'Salary Credited', body: 'Your salary of ₹87,200 for May 2026 has been credited.', type: 'earning', time: DateTime.now().subtract(const Duration(hours: 2))),
    _Notif(id: '3', title: 'Attendance Alert', body: 'You were marked late today. Check-in was at 9:15 AM.', type: 'attendance', time: DateTime.now().subtract(const Duration(hours: 5)), read: true),
    _Notif(id: '4', title: 'Document Available', body: 'Your payslip for May 2026 is now available to download.', type: 'document', time: DateTime.now().subtract(const Duration(days: 1)), read: true),
    _Notif(id: '5', title: 'Team Message', body: 'Rahul Sharma: Meeting at 3 PM today in conference room.', type: 'chat', time: DateTime.now().subtract(const Duration(days: 1)), read: true),
  ];

  IconData _icon(String type) => switch (type) {
        'task' => Icons.task_outlined,
        'earning' => Icons.account_balance_wallet_outlined,
        'attendance' => Icons.access_time_outlined,
        'document' => Icons.description_outlined,
        'chat' => Icons.chat_outlined,
        _ => Icons.notifications_outlined,
      };

  Color _color(String type) => switch (type) {
        'task' => AppColors.warning,
        'earning' => AppColors.success,
        'attendance' => AppColors.info,
        'document' => AppColors.primary,
        'chat' => AppColors.accent,
        _ => AppColors.textSecondary,
      };

  String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('dd MMM').format(t);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: 'Notifications',
        showBack: true,
        actions: [
          TextButton(
            onPressed: () => setState(() {}),
            child: Text('Mark all read', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textOnPrimary)),
          ),
        ],
      ),
      body: _notifs.isEmpty
          ? const EmptyState(icon: Icons.notifications_none, title: 'No notifications')
          : ListView.separated(
              padding: EdgeInsets.all(16.r),
              itemCount: _notifs.length,
              separatorBuilder: (ctx, i) => SizedBox(height: 8.h),
              itemBuilder: (_, i) {
                final n = _notifs[i];
                return Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: n.read ? AppColors.surface : _color(n.type).withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12.r),
                    border: n.read ? null : Border.all(color: _color(n.type).withValues(alpha: 0.2)),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: _color(n.type).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(_icon(n.type), color: _color(n.type), size: 20.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(child: Text(n.title,
                              style: AppTextStyles.labelLarge.copyWith(
                                  fontWeight: n.read ? FontWeight.w500 : FontWeight.w700))),
                          Text(_timeAgo(n.time), style: AppTextStyles.caption),
                        ]),
                        SizedBox(height: 4.h),
                        Text(n.body, style: AppTextStyles.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                      ]),
                    ),
                    if (!n.read) ...[
                      SizedBox(width: 8.w),
                      Container(width: 8.w, height: 8.w, decoration: BoxDecoration(color: _color(n.type), shape: BoxShape.circle)),
                    ],
                  ]),
                );
              },
            ),
    );
  }
}
