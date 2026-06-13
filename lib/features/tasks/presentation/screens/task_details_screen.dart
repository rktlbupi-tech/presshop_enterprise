import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../presentation/widgets/app_app_bar.dart';
import '../bloc/tasks_bloc.dart';

class TaskDetailsScreen extends StatefulWidget {
  final String taskId;
  const TaskDetailsScreen({super.key, required this.taskId});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  // Dummy data matching old EmployeeTaskDetailsModal structure
  final Map<String, dynamic> _taskDetail = {
    'id': '1',
    'status': 'accepted', // accepted, open, completed
    'companyName': 'BBC NEWS',
    'creatorProfileImage': 'https://picsum.photos/100',
    'taskCode': 'TSK-001',
    'priority': 'high',
    'reference': 'REF-992',
    'emergency': true,
    'hasDeadline': true,
    'deadLine': DateTime.now().add(const Duration(hours: 3, minutes: 12)),
    'latitude': 51.5072,
    'longitude': -0.1276,
    'address': '123 City Centre, London, UK',
    'description': 'Filmed the ongoing protest at the city centre with multiple angles. Need high quality footage.',
    'amount': 150.0,
    'currency': '£',
    'distance': '2.5 km',
    'walkingEstTime': '30 mins',
    'drivingEstTime': '10 mins',
  };

  bool _isMapPlaceholder = true;

  @override
  Widget build(BuildContext context) {
    // Determine header color
    Color statusColor = AppColors.primary;
    String statusText = _taskDetail['status'].toString().toUpperCase();
    if (statusText == 'COMPLETED') statusColor = Colors.green;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppAppBar(
        title: 'Task Details',
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Company + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: ClipOval(
                        child: Image.network(
                          _taskDetail['creatorProfileImage'],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.grey),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      _taskDetail['companyName'],
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                )
              ],
            ),
            SizedBox(height: 12.h),

            // Map & Timer Row
            Row(
              children: [
                // Map Placeholder
                Expanded(
                  child: Container(
                    height: 140.w,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            color: Colors.grey.shade200,
                            child: Center(
                              child: Icon(Icons.map, size: 40.w, color: Colors.grey),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(16.r),
                                bottomRight: Radius.circular(16.r),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Click the Map & GO",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Timer Placeholder
                Expanded(
                  child: Container(
                    height: 140.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAEAEA),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Time remaining",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          "03:12:45", // Dummy countdown
                          style: TextStyle(
                            fontSize: 28.sp,
                            color: const Color(0xFF2D83E6), // Blue as in old app for accepted
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined, size: 24.w, color: Colors.grey.shade600),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    _taskDetail['address'],
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(Icons.content_copy, size: 20.w, color: Colors.black54),
              ],
            ),
            SizedBox(height: 16.h),

            // Distance & Travel Time
            Row(
              children: [
                _buildTravelInfo(Icons.directions_walk, _taskDetail['walkingEstTime']),
                SizedBox(width: 16.w),
                _buildTravelInfo(Icons.directions_car, _taskDetail['drivingEstTime']),
                SizedBox(width: 16.w),
                _buildTravelInfo(Icons.moving, _taskDetail['distance']),
              ],
            ),
            SizedBox(height: 16.h),
            const Divider(color: Color(0xFFEEEEEE)),
            SizedBox(height: 12.h),

            // Description
            Text(
              "Task Description",
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              _taskDetail['description'],
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16.h),
            const Divider(color: Color(0xFFEEEEEE)),
            SizedBox(height: 12.h),

            // Price
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Task Price",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "${_taskDetail['currency']}${_taskDetail['amount']}",
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Buttons
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: Size(double.infinity, 48.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text(
                "Complete Task",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 48.h),
                side: BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text(
                "Upload Evidence",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTravelInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18.w, color: Colors.grey.shade600),
        SizedBox(width: 4.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
