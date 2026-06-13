import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../presentation/widgets/app_app_bar.dart';
import '../../../../presentation/widgets/loading_widget.dart';
import '../bloc/tasks_bloc.dart';

class TaskDetailsScreen extends StatefulWidget {
  final String taskId;
  const TaskDetailsScreen({super.key, required this.taskId});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  String? _selectedStatus;

  Color _priorityColor(String p) => switch (p.toLowerCase()) {
        'high' => AppColors.error, 'medium' => AppColors.warning, _ => AppColors.info,
      };
  Color _statusColor(String s) => switch (s) {
        'completed' => AppColors.success, 'in-progress' => AppColors.info, _ => AppColors.warning,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(title: 'Task Details', showBack: true),
      body: BlocBuilder<TasksBloc, TasksState>(
        builder: (context, state) {
          if (state is TasksLoading) return const LoadingWidget();
          final task = state is TasksLoaded
              ? state.allTasks.where((t) => t.id == widget.taskId).firstOrNull
              : null;
          if (task == null) return const Center(child: Text('Task not found'));
          _selectedStatus ??= task.status;
          return SingleChildScrollView(
            padding: EdgeInsets.all(20.r),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Title + priority
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(task.title, style: AppTextStyles.h4)),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: _priorityColor(task.priority).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(task.displayPriority,
                          style: AppTextStyles.labelMedium.copyWith(color: _priorityColor(task.priority))),
                    ),
                  ]),
                  if (task.description != null && task.description!.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    Text(task.description!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  ],
                ]),
              ),
              SizedBox(height: 16.h),
              // Details
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                ),
                child: Column(children: [
                  _DetailRow(icon: Icons.person_outline, label: 'Assigned by', value: task.assignedBy ?? 'Admin'),
                  if (task.deadline != null)
                    _DetailRow(icon: Icons.calendar_today_outlined, label: 'Deadline',
                        value: DateFormat('dd MMM yyyy').format(task.deadline!)),
                  if (task.createdAt != null)
                    _DetailRow(icon: Icons.access_time, label: 'Created',
                        value: DateFormat('dd MMM yyyy').format(task.createdAt!)),
                ]),
              ),
              SizedBox(height: 16.h),
              // Status update
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Update Status', style: AppTextStyles.labelLarge),
                  SizedBox(height: 12.h),
                  Row(children: ['pending', 'in-progress', 'completed'].map((s) {
                    final sel = _selectedStatus == s;
                    final color = _statusColor(s);
                    final label = switch (s) { 'in-progress' => 'In Progress', 'completed' => 'Completed', _ => 'Pending' };
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: s != 'completed' ? 8.w : 0),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedStatus = s),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            decoration: BoxDecoration(
                              color: sel ? color : color.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: color.withValues(alpha: 0.4)),
                            ),
                            child: Text(label, textAlign: TextAlign.center,
                                style: AppTextStyles.labelSmall.copyWith(
                                    color: sel ? Colors.white : color,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    );
                  }).toList()),
                ]),
              ),
              SizedBox(height: 24.h),
              if (_selectedStatus != task.status)
                ElevatedButton(
                  onPressed: () {
                    context.read<TasksBloc>().add(UpdateTaskStatus(task.id, _selectedStatus!));
                    Navigator.pop(context);
                  },
                  child: const Text('Save Status'),
                ),
            ]),
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon; final String label, value;
  const _DetailRow({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: 8.h),
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
