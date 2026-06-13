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
import '../bloc/tasks_bloc.dart';
import 'task_details_screen.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TasksBloc>()..add(const FetchTasks()),
      child: const _TasksView(),
    );
  }
}

class _TasksView extends StatefulWidget {
  const _TasksView();
  @override State<_TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<_TasksView> {
  String _activeFilter = 'All';
  final _filters = ['All', 'Pending', 'In Progress', 'Completed'];

  String _toStatusKey(String f) => switch (f) {
        'In Progress' => 'in-progress',
        'Completed' => 'completed',
        'Pending' => 'pending',
        _ => '',
      };

  Color _priorityColor(String p) => switch (p.toLowerCase()) {
        'high' => AppColors.error,
        'medium' => AppColors.warning,
        _ => AppColors.info,
      };

  Color _statusColor(String s) => switch (s) {
        'completed' => AppColors.success,
        'in-progress' => AppColors.info,
        _ => AppColors.warning,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(title: 'My Tasks'),
      body: BlocBuilder<TasksBloc, TasksState>(
        builder: (context, state) {
          return Column(
            children: [
              // filter chips
              Container(
                color: AppColors.surface,
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((f) {
                      final sel = _activeFilter == f;
                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: FilterChip(
                          label: Text(f), selected: sel,
                          showCheckmark: false,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.background,
                          labelStyle: AppTextStyles.labelMedium.copyWith(
                              color: sel ? AppColors.textOnPrimary : AppColors.textSecondary),
                          side: BorderSide(color: sel ? AppColors.primary : AppColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                          onSelected: (_) {
                            setState(() => _activeFilter = f);
                            final key = _toStatusKey(f);
                            context.read<TasksBloc>().add(FilterTasksByStatus(key.isEmpty ? null : key));
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Expanded(child: _buildBody(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, TasksState state) {
    if (state is TasksLoading) return const LoadingWidget();
    if (state is TasksError) {
      return EmptyState(
        icon: Icons.error_outline, title: state.message,
        buttonLabel: 'Retry', onButtonTap: () => context.read<TasksBloc>().add(const FetchTasks()),
      );
    }
    final tasks = state is TasksLoaded ? state.filteredTasks : [];
    if (tasks.isEmpty) return const EmptyState(icon: Icons.task_outlined, title: 'No tasks found', subtitle: 'Tasks assigned to you will appear here.');
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => context.read<TasksBloc>().add(const RefreshTasks()),
      child: ListView.separated(
        padding: EdgeInsets.all(16.r),
        itemCount: tasks.length,
        separatorBuilder: (ctx, i) => SizedBox(height: 12.h),
        itemBuilder: (_, i) {
          final task = tasks[i];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<TasksBloc>(),
                child: TaskDetailsScreen(taskId: task.id),
              ),
            )),
            child: Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(task.title, style: AppTextStyles.labelLarge, maxLines: 2, overflow: TextOverflow.ellipsis)),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: _priorityColor(task.priority).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(task.displayPriority,
                        style: AppTextStyles.labelSmall.copyWith(color: _priorityColor(task.priority))),
                  ),
                ]),
                SizedBox(height: 8.h),
                Row(children: [
                  if (task.deadline != null) ...[
                    Icon(Icons.calendar_today_outlined, size: 12.sp, color: AppColors.textSecondary),
                    SizedBox(width: 4.w),
                    Text(DateFormat('dd MMM yyyy').format(task.deadline!), style: AppTextStyles.caption),
                    SizedBox(width: 12.w),
                  ],
                  if (task.assignedBy != null) ...[
                    Icon(Icons.person_outline, size: 12.sp, color: AppColors.textSecondary),
                    SizedBox(width: 4.w),
                    Text(task.assignedBy!, style: AppTextStyles.caption),
                  ],
                ]),
                SizedBox(height: 10.h),
                Align(alignment: Alignment.centerRight, child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _statusColor(task.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(task.displayStatus,
                      style: AppTextStyles.labelSmall.copyWith(color: _statusColor(task.status))),
                )),
              ]),
            ),
          );
        },
      ),
    );
  }
}
