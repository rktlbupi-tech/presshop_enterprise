import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../presentation/widgets/employee_app_bar.dart';

/// Port of the old EmployeeTaskScheduleScreen — month header, weekday row,
/// a calendar grid, and the selected day's task list below.
class TaskScheduleScreen extends StatefulWidget {
  final bool hideLeading;
  const TaskScheduleScreen({super.key, this.hideLeading = true});

  @override
  State<TaskScheduleScreen> createState() => _TaskScheduleScreenState();
}

class _TaskScheduleScreenState extends State<TaskScheduleScreen> {
  late DateTime _visibleMonth;
  late DateTime _selectedDay;

  static const _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December'
  ];

  // Sample tasks keyed by day-of-month.
  final Map<int, List<_Task>> _tasks = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
    _selectedDay = DateTime(now.year, now.month, now.day);
    _tasks[now.day] = [
      _Task('09:00', 'Morning briefing', 'Newsroom', AppColors.primary),
      _Task('13:30', 'Cover city council', 'Town Hall', AppColors.accent),
    ];
    final tomorrow = now.day + 1;
    _tasks[tomorrow] = [
      _Task('10:00', 'Interview — local MP', 'Constituency office',
          AppColors.warning),
    ];
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth =
          DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: widget.hideLeading
          ? const EmployeeAppBar()
          : AppBar(
              title: const Text('View Task'),
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              elevation: 0.5,
            ),
      body: Column(
        children: [
          _monthHeader(),
          _weekDayRow(),
          const Divider(height: 1, thickness: 0.5, color: AppColors.border),
          _calendarGrid(),
          _taskListHeader(),
          Expanded(child: _taskList()),
        ],
      ),
    );
  }

  Widget _monthHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_months[_visibleMonth.month - 1]} ${_visibleMonth.year}',
            style: AppTextStyles.h4,
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, size: 24.sp),
                onPressed: () => _changeMonth(-1),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, size: 24.sp),
                onPressed: () => _changeMonth(1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _weekDayRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: _weekDays.map((d) {
          final weekend = d == 'Sat' || d == 'Sun';
          return Expanded(
            child: Center(
              child: Text(
                d,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: weekend ? AppColors.textHint : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _calendarGrid() {
    final firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    // Monday = 1 ... Sunday = 7 → leading blanks before day 1.
    final leading = firstOfMonth.weekday - 1;
    final cells = leading + daysInMonth;
    final rows = (cells / 7).ceil();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Column(
        children: List.generate(rows, (r) {
          return Row(
            children: List.generate(7, (c) {
              final index = r * 7 + c;
              final dayNum = index - leading + 1;
              if (dayNum < 1 || dayNum > daysInMonth) {
                return const Expanded(child: SizedBox(height: 44));
              }
              final isSelected = _selectedDay.year == _visibleMonth.year &&
                  _selectedDay.month == _visibleMonth.month &&
                  _selectedDay.day == dayNum;
              final hasTasks = (_tasks[dayNum]?.isNotEmpty ?? false) &&
                  _visibleMonth.month == DateTime.now().month;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDay = DateTime(
                      _visibleMonth.year, _visibleMonth.month, dayNum)),
                  child: Container(
                    height: 44.h,
                    margin: EdgeInsets.all(2.r),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayNum',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isSelected
                                ? AppColors.textOnPrimary
                                : AppColors.textPrimary,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                        if (hasTasks) ...[
                          SizedBox(height: 2.h),
                          Container(
                            width: 5.w,
                            height: 5.w,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.textOnPrimary
                                  : AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _taskListHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 20.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            '${_selectedDay.day} ${_months[_selectedDay.month - 1]} ${_selectedDay.year}',
            style: AppTextStyles.labelLarge,
          ),
        ],
      ),
    );
  }

  Widget _taskList() {
    final showForCurrentMonth =
        _visibleMonth.month == DateTime.now().month &&
            _visibleMonth.year == DateTime.now().year;
    final tasks = showForCurrentMonth
        ? (_tasks[_selectedDay.day] ?? const [])
        : const <_Task>[];

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 48.sp, color: AppColors.textHint),
            SizedBox(height: 12.h),
            Text('No tasks scheduled for this day',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: tasks.length,
      itemBuilder: (context, i) => _taskCard(tasks[i]),
    );
  }

  Widget _taskCard(_Task t) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: t.color,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 14.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.time,
                  style: AppTextStyles.caption
                      .copyWith(color: t.color, fontWeight: FontWeight.w700)),
              SizedBox(height: 2.h),
              Text(t.title, style: AppTextStyles.labelLarge),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(Icons.location_on_outlined,
                  size: 16.sp, color: AppColors.textHint),
              SizedBox(height: 2.h),
              Text(t.place,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Task {
  final String time;
  final String title;
  final String place;
  final Color color;
  const _Task(this.time, this.title, this.place, this.color);
}
