import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:presshop_enterprise/features/duties/presentation/screens/duties_history_screen.dart';
import 'package:presshop_enterprise/features/map/core/map_constants.dart';
import 'package:presshop_enterprise/presentation/widgets/app_app_bar.dart';

class DutiesScreen extends StatefulWidget {
  const DutiesScreen({super.key});

  @override
  State<DutiesScreen> createState() => _DutiesScreenState();
}

class _DutiesScreenState extends State<DutiesScreen> {
  final bool _isOnDuty = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _getRemainingTime() {
    final now = DateTime.now();
    final shiftEnd = DateTime(now.year, now.month, now.day, 18, 0); // 06:00 PM
    if (now.isAfter(shiftEnd)) {
      return "03h 45m 00s";
    }
    final difference = shiftEnd.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    final hoursStr = hours.toString().padLeft(2, '0');
    final minutesStr = minutes.toString().padLeft(2, '0');
    final secondsStr = seconds.toString().padLeft(2, '0');
    return "${hoursStr}h ${minutesStr}m ${secondsStr}s";
  }

  final List<Map<String, dynamic>> _ongoingTasks = [
    {'name': 'Log on at site', 'done': true, 'statusText': 'Completed'},
    {'name': 'Complete first patrol', 'done': false, 'statusText': 'Pending'},
    {'name': 'Upload site photos', 'done': false, 'statusText': 'Pending'},
    {
      'name': 'Submit end-of-shift report',
      'done': false,
      'statusText': 'Pending',
    },
  ];

  final List<Map<String, dynamic>> _scheduledDuties = [
    {
      'id': 'DUTY-8493',
      'title': 'Night Shift',
      'date': '10',
      'month': 'Jun',
      'time': '10:00 PM – 06:00 AM',
      'location': 'XYZ Warehouse',
    },
    {
      'id': 'DUTY-8499',
      'title': 'Morning Shift',
      'date': '12',
      'month': 'Jun',
      'time': '08:00 AM – 04:00 PM',
      'location': 'City Mall',
    },
  ];

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'AirbnbCereal'),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppAppBar(
        title: _isOnDuty ? "Duties" : "Log on",
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        showBack: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  _buildStatusGradientCard(),
                  const SizedBox(height: 20),
                  _buildTasksSection(),
                  const SizedBox(height: 20),
                  _buildUpcomingDutiesSection(),
                  const SizedBox(height: 20),
                  _buildCurrentAssignmentCard(),
                  const SizedBox(height: 20),
                  _buildThisMonthSection(),
                  const SizedBox(height: 20),
                  _buildHistoryCard(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusGradientCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2979FF), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "09:00 AM – 06:00 PM",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'AirbnbCereal',
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: const TextSpan(
                    text: "Duty days : ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'AirbnbCereal',
                    ),
                    children: [
                      TextSpan(
                        text: "Mon, Tue, Wed, Thurs, Fri",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: const TextSpan(
                    text: "Off days     : ",
                    style: TextStyle(
                      color: Colors.yellowAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'AirbnbCereal',
                    ),
                    children: [
                      TextSpan(
                        text: "Sat, Sun",
                        style: TextStyle(
                          color: Colors.yellow,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2.0),
                      child: Icon(
                        LucideIcons.map_pin,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "ABC Corporate Office",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'AirbnbCereal',
                            ),
                          ),
                          SizedBox(height: 1),
                          Text(
                            "Sector 62, Noida",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontFamily: 'AirbnbCereal',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        "Remaining \nduty time",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'AirbnbCereal',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getRemainingTime(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'AirbnbCereal',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "Today’s Tasks",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'AirbnbCereal',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _ongoingTasks.length,
            itemBuilder: (context, index) {
              final task = _ongoingTasks[index];
              final isLast = index == _ongoingTasks.length - 1;
              final isCompleted = task['done'] == true;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        isCompleted
                            ? const Icon(
                                Icons.check_circle,
                                color: colorEmployeeGreen1,
                                size: 22,
                              )
                            : Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                    width: 1.5,
                                  ),
                                  color: Colors.white,
                                ),
                              ),
                        if (!isLast)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                children: List.generate(4, (i) {
                                  return Expanded(
                                    child: Container(
                                      width: 1.5,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 2.5,
                                      ),
                                      color: isCompleted
                                          ? colorEmployeeGreen1
                                          : Colors.grey.shade300,
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2.0, bottom: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              task['name'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: isCompleted
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                                fontFamily: 'AirbnbCereal',
                              ),
                            ),
                            Text(
                              task['statusText'],
                              style: TextStyle(
                                fontSize: 12,
                                color: isCompleted
                                    ? colorEmployeeGreen1
                                    : Colors.grey.shade500,
                                fontWeight: isCompleted
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontFamily: 'AirbnbCereal',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentAssignmentCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Current Duty Site",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'AirbnbCereal',
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        LucideIcons.building,
                        color: Color(0xFF1877F2),
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "ABC Corporate Office",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'AirbnbCereal',
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "Sector 62, Noida",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12.5,
                              fontFamily: 'AirbnbCereal',
                            ),
                          ),
                          const SizedBox(height: 6),
                          RichText(
                            text: TextSpan(
                              text: "Supervisor: ",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                                fontFamily: 'AirbnbCereal',
                              ),
                              children: const [
                                TextSpan(
                                  text: "Rahul Sharma",
                                  style: TextStyle(
                                    color: Color(0xFF1877F2),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "Shift: Morning (09:00 AM – 06:00 PM)",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              fontFamily: 'AirbnbCereal',
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showToast("Map thumbnail clicked"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: const [
                            Icon(
                              LucideIcons.map_pin,
                              color: Color(0xFF1877F2),
                              size: 20,
                            ),
                            SizedBox(height: 4),
                            Text(
                              "On Map",
                              style: TextStyle(
                                color: Color(0xFF1877F2),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'AirbnbCereal',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: Colors.grey.shade200),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _showToast("View Map clicked"),
                      icon: const Icon(
                        LucideIcons.map,
                        size: 16,
                        color: Color(0xFF1877F2),
                      ),
                      label: const Text(
                        "View Map",
                        style: TextStyle(
                          color: Color(0xFF1877F2),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'AirbnbCereal',
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  Container(width: 1, height: 30, color: Colors.grey.shade200),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _showToast("Calling Supervisor..."),
                      icon: const Icon(
                        LucideIcons.phone,
                        size: 16,
                        color: Color(0xFF2DC78A),
                      ),
                      label: const Text(
                        "Call Supervisor",
                        style: TextStyle(
                          color: Color(0xFF2DC78A),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'AirbnbCereal',
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _showHandoverReportDialog(context),
                  icon: const Icon(
                    LucideIcons.triangle_alert,
                    size: 16,
                    color: Color(0xFFFF3B30),
                  ),
                  label: const Text(
                    "Report Handover Issue (Next Shift)",
                    style: TextStyle(
                      color: Color(0xFFFF3B30),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'AirbnbCereal',
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingDutiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "Upcoming Tasks",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'AirbnbCereal',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _scheduledDuties.length,
          itemBuilder: (context, index) {
            final duty = _scheduledDuties[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          duty['date']!,
                          style: const TextStyle(
                            color: Color(0xFF1877F2),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'AirbnbCereal',
                          ),
                        ),
                        Text(
                          duty['month']!,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontFamily: 'AirbnbCereal',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          duty['title']!,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'AirbnbCereal',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.map_pin,
                              size: 13,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              duty['location']!,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                                fontFamily: 'AirbnbCereal',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        duty['time']!,
                        style: const TextStyle(
                          color: Color(0xFF1877F2),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'AirbnbCereal',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "Upcoming",
                          style: TextStyle(
                            color: Color(0xFF1877F2),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'AirbnbCereal',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildThisMonthSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "This Month's Summery",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'AirbnbCereal',
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  LucideIcons.calendar,
                  color: Color(0xFF1877F2),
                  size: 20,
                ),
                onPressed: () => _showToast("Calendar filter clicked"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F8F0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.calendar_check,
                        color: Color(0xFF2DC78A),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "18",
                            style: TextStyle(
                              color: Color(0xFF2DC78A),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'AirbnbCereal',
                            ),
                          ),
                          Text(
                            "Days Compoeted",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                              fontFamily: 'AirbnbCereal',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEEF2FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.clock,
                        color: Color(0xFF1877F2),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "162",
                            style: TextStyle(
                              color: Color(0xFF1877F2),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'AirbnbCereal',
                            ),
                          ),
                          Text(
                            "Total Hours",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                              fontFamily: 'AirbnbCereal',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3E8FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.trending_up,
                        color: Color(0xFF9333EA),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "96%",
                            style: TextStyle(
                              color: Color(0xFF9333EA),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'AirbnbCereal',
                            ),
                          ),
                          Text(
                            "Attendance",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                              fontFamily: 'AirbnbCereal',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showHandoverReportDialog(BuildContext context) {
    final locationController = TextEditingController(
      text: "ABC Corporate Office, Sector 62, Noida",
    );
    final detailsController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: const [
                  Icon(
                    LucideIcons.triangle_alert,
                    color: Color(0xFFFF3B30),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Report Handover Issue",
                    style: TextStyle(
                      fontFamily: 'AirbnbCereal',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Notify your supervisor if the next shift guard has not arrived or if there is a handover delay.",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                          fontFamily: 'AirbnbCereal',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Location / Site Name",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.black87,
                          fontFamily: 'AirbnbCereal',
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: locationController,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'AirbnbCereal',
                        ),
                        decoration: InputDecoration(
                          hintText: "Enter location name",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontFamily: 'AirbnbCereal',
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return "Location cannot be empty";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Report Details / Comments",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.black87,
                          fontFamily: 'AirbnbCereal',
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: detailsController,
                        maxLines: 4,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'AirbnbCereal',
                        ),
                        decoration: InputDecoration(
                          hintText: "Describe the issue (e.g. Relief guard has not arrived yet, shift ended but relief not here, etc.)",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12.5,
                            fontFamily: 'AirbnbCereal',
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return "Please enter report details";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'AirbnbCereal',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (formKey.currentState?.validate() ?? false) {
                            setDialogState(() {
                              isSubmitting = true;
                            });

                            // Simulate submission
                            await Future.delayed(const Duration(milliseconds: 1500));

                            if (context.mounted) {
                              Navigator.pop(context);
                              _showToast("Handover report submitted successfully.");
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3B30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          "Submit Report",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'AirbnbCereal',
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DutiesHistoryScreen()),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFEAF1FE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.history,
                color: Color(0xFF1877F2),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "View Shift History",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'AirbnbCereal',
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Inspect all past duties and shift details",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      fontFamily: 'AirbnbCereal',
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
