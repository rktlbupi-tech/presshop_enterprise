import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../presentation/widgets/app_app_bar.dart';
import 'task_details_screen.dart';

class TaskScheduleScreen extends StatefulWidget {
  const TaskScheduleScreen({super.key});

  @override
  State<TaskScheduleScreen> createState() => _TaskScheduleScreenState();
}

class _TaskScheduleScreenState extends State<TaskScheduleScreen> {
  final List<String> _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  final List<_DummyScheduleTask> _tasks = [
    _DummyScheduleTask(
      id: "1",
      title: "Cover local protest",
      startTime: "10:00",
      endTime: "14:00",
      location: "City Centre",
      color: Colors.red,
      mediaHouseLogo: "https://picsum.photos/100",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppAppBar(title: 'View Task'),
      body: Column(
        children: [
          _buildMonthHeader(),
          _buildWeekDayRow(),
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE0E0E0)),
          _buildCalendarGrid(),
          _buildTaskListHeader(),
          Expanded(child: _buildTaskList()),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: Colors.black, size: 28.sp),
            onPressed: () {},
          ),
          Text(
            "June 2026",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: Colors.black, size: 28.sp),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDayRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _weekDays.map((day) {
          final isWeekend = day == 'Sat' || day == 'Sun';
          return Text(
            day,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: isWeekend ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return SizedBox(
      height: 250.h,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: 30, // Dummy month days
        itemBuilder: (context, index) {
          final day = index + 1;
          final isSelected = day == 13; // dummy selected day
          final hasTask = day == 13 || day == 15 || day == 20;

          return Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2D83E6) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day.toString(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
                if (hasTask && !isSelected)
                  Container(
                    margin: EdgeInsets.only(top: 2.h),
                    width: 4.w,
                    height: 4.w,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskListHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 20.h,
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            "Sat, 13 June 2026",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        return _TimelineTaskCard(task: _tasks[index]);
      },
    );
  }
}

class _TimelineTaskCard extends StatelessWidget {
  final _DummyScheduleTask task;

  const _TimelineTaskCard({required this.task});

  String _to12HourFormat(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        String ampm = hour >= 12 ? 'PM' : 'AM';
        int displayHour = hour % 12;
        if (displayHour == 0) displayHour = 12;
        String hourStr = displayHour.toString().padLeft(2, '0');
        String minuteStr = minute.toString().padLeft(2, '0');
        return "$hourStr:$minuteStr $ampm";
      }
    } catch (_) {}
    return timeStr;
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = task.color.withValues(alpha: 0.05);
    Color accentColor = task.color;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailsScreen(taskId: task.id),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4.5.w,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    bottomLeft: Radius.circular(16.r),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "${_to12HourFormat(task.startTime)} - ${_to12HourFormat(task.endTime)}",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 12.sp, color: Colors.grey.shade500),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              task.location,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12.sp,
                                color: Colors.grey.shade500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 18.w),
                child: Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: task.mediaHouseLogo.isNotEmpty
                        ? Image.network(
                            task.mediaHouseLogo,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.business, size: 20, color: Colors.grey),
                          )
                        : const Icon(Icons.business, size: 20, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DummyScheduleTask {
  final String id;
  final String title;
  final String startTime;
  final String endTime;
  final String location;
  final Color color;
  final String mediaHouseLogo;

  _DummyScheduleTask({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.color,
    required this.mediaHouseLogo,
  });
}
