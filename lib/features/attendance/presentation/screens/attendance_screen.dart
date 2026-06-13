import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../config/di/injection.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../presentation/widgets/app_app_bar.dart';
import '../../../../presentation/widgets/empty_state.dart';
import '../../../../presentation/widgets/loading_widget.dart';
import '../bloc/attendance_bloc.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AttendanceBloc>()..add(const FetchAttendanceLog()),
      child: const _AttendanceView(),
    );
  }
}

class _AttendanceView extends StatefulWidget {
  const _AttendanceView();
  @override State<_AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<_AttendanceView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isCheckedIn = false;
  DateTime? _checkInTime;
  String _workingHours = '0h 0m';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _handleToggle(BuildContext context) {
    if (_isCheckedIn) {
      context.read<AttendanceBloc>().add(const CheckOutRequested(0.0, 0.0));
    } else {
      context.read<AttendanceBloc>().add(const CheckInRequested(0.0, 0.0));
    }
  }

  void _startTimer() {
    _checkInTime = DateTime.now();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      final diff = DateTime.now().difference(_checkInTime!);
      setState(() => _workingHours = '${diff.inHours}h ${diff.inMinutes % 60}m');
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _checkInTime = null;
    setState(() { _workingHours = '0h 0m'; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(title: 'Attendance'),
      body: BlocConsumer<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceActionSuccess) {
            setState(() => _isCheckedIn = state.isCheckedIn);
            if (state.isCheckedIn) { _startTimer(); } else { _stopTimer(); }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message),
                  backgroundColor: state.isCheckedIn ? AppColors.success : AppColors.primary));
            context.read<AttendanceBloc>().add(const FetchAttendanceLog());
          } else if (state is AttendanceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error));
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Container(
                color: AppColors.primary,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.accent, indicatorWeight: 3,
                  labelColor: AppColors.textOnPrimary, unselectedLabelColor: Colors.white60,
                  labelStyle: AppTextStyles.labelLarge,
                  tabs: const [Tab(text: 'Check In/Out'), Tab(text: 'Log')],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCheckInTab(context, state),
                    _buildLogTab(context, state),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCheckInTab(BuildContext context, AttendanceState state) {
    final now = DateTime.now();
    final isLoading = state is AttendanceLoading;
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.r),
      child: Column(
        children: [
          SizedBox(height: 16.h),
          Container(
            width: 200.w, height: 200.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle, color: AppColors.surface,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20)],
              border: Border.all(color: _isCheckedIn ? AppColors.success : AppColors.border, width: 4),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(DateFormat('hh:mm').format(now),
                  style: AppTextStyles.h1.copyWith(fontSize: 36.sp, color: AppColors.primary)),
              Text(DateFormat('a').format(now), style: AppTextStyles.bodySmall),
              SizedBox(height: 4.h),
              Text(DateFormat('EEE, dd MMM').format(now), style: AppTextStyles.labelMedium),
            ]),
          ),
          SizedBox(height: 24.h),
          if (_isCheckedIn) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.timer_outlined, size: 16.sp, color: AppColors.success),
                SizedBox(width: 6.w),
                Text('Working: $_workingHours',
                    style: AppTextStyles.labelLarge.copyWith(color: AppColors.success)),
              ]),
            ),
            SizedBox(height: 8.h),
            if (_checkInTime != null)
              Text('Checked in at ${DateFormat('hh:mm a').format(_checkInTime!)}',
                  style: AppTextStyles.bodySmall),
          ],
          SizedBox(height: 32.h),
          isLoading
              ? const LoadingWidget()
              : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isCheckedIn ? AppColors.error : AppColors.success,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    onPressed: () => _handleToggle(context),
                    icon: Icon(_isCheckedIn ? Icons.logout : Icons.login, size: 20.sp),
                    label: Text(_isCheckedIn ? 'Check Out' : 'Check In', style: AppTextStyles.button),
                  ),
                ),
          SizedBox(height: 32.h),
          if (state is AttendanceLoaded && state.summary != null)
            _SummaryRow(summary: state.summary!),
        ],
      ),
    );
  }

  Widget _buildLogTab(BuildContext context, AttendanceState state) {
    if (state is AttendanceLoading) return const LoadingWidget();
    if (state is AttendanceError) return EmptyState(icon: Icons.error_outline, title: state.message, buttonLabel: 'Retry', onButtonTap: () => context.read<AttendanceBloc>().add(const FetchAttendanceLog()));
    if (state is AttendanceLoaded) {
      if (state.logs.isEmpty) return const EmptyState(icon: Icons.access_time_outlined, title: 'No attendance records');
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => context.read<AttendanceBloc>().add(const FetchAttendanceLog()),
        child: ListView.separated(
          padding: EdgeInsets.all(16.r),
          itemCount: state.logs.length,
          separatorBuilder: (ctx, i) => SizedBox(height: 12.h),
          itemBuilder: (_, i) => _LogTile(log: state.logs[i]),
        ),
      );
    }
    return const EmptyState(icon: Icons.access_time_outlined, title: 'No records found');
  }
}

class _LogTile extends StatelessWidget {
  final dynamic log;
  const _LogTile({required this.log});

  Color _statusColor(String s) => switch (s) {
        'present' => AppColors.success,
        'late' => AppColors.warning,
        _ => AppColors.error,
      };

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(log.status as String);
    final checkIn = log.checkIn != null ? DateFormat('hh:mm a').format(log.checkIn as DateTime) : '--';
    final checkOut = log.checkOut != null ? DateFormat('hh:mm a').format(log.checkOut as DateTime) : '--';
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Row(children: [
        Container(width: 4.w, height: 56.h,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2.r))),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(DateFormat('dd MMM yyyy').format(log.date as DateTime), style: AppTextStyles.labelLarge),
            SizedBox(height: 4.h),
            Row(children: [
              Icon(Icons.login, size: 12.sp, color: AppColors.success),
              SizedBox(width: 4.w), Text(checkIn, style: AppTextStyles.bodySmall),
              SizedBox(width: 16.w),
              Icon(Icons.logout, size: 12.sp, color: AppColors.error),
              SizedBox(width: 4.w), Text(checkOut, style: AppTextStyles.bodySmall),
            ]),
          ]),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6.r)),
          child: Text(log.status as String, style: AppTextStyles.labelSmall.copyWith(color: color)),
        ),
      ]),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final dynamic summary;
  const _SummaryRow({required this.summary});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _Item('${summary.present}', 'Present', AppColors.success),
        _D(), _Item('${summary.absent}', 'Absent', AppColors.error),
        _D(), _Item('${summary.late}', 'Late', AppColors.warning),
        _D(), _Item('${summary.leaves}', 'Leaves', AppColors.info),
      ]),
    );
  }
}

class _Item extends StatelessWidget {
  final String v, l; final Color c;
  const _Item(this.v, this.l, this.c);
  @override Widget build(BuildContext context) => Column(children: [
    Text(v, style: AppTextStyles.h3.copyWith(color: c)),
    SizedBox(height: 2.h), Text(l, style: AppTextStyles.labelSmall),
  ]);
}

class _D extends StatelessWidget {
  @override Widget build(BuildContext context) =>
      Container(height: 36.h, width: 1, color: AppColors.divider);
}
