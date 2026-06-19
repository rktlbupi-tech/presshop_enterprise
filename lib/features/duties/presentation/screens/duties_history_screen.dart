import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';
import 'package:presshop_enterprise/core/constants/app_colors.dart';
import 'package:presshop_enterprise/features/duties/data/models/duty_shift_model.dart';
import 'package:presshop_enterprise/features/duties/presentation/screens/duties_history_details_screen.dart';
import 'package:presshop_enterprise/presentation/widgets/app_app_bar.dart';

class DutiesHistoryScreen extends StatefulWidget {
  const DutiesHistoryScreen({super.key});

  @override
  State<DutiesHistoryScreen> createState() => _DutiesHistoryScreenState();
}

class _DutiesHistoryScreenState extends State<DutiesHistoryScreen> {
  final List<DutyShiftHistory> _allShifts = DutyShiftHistory.getMockShifts();
  String _selectedRange = 'Last 1 Year';

  final List<String> _rangeOptions = [
    'Last 30 Days',
    'Last 3 Months',
    'Last 6 Months',
    'Last 1 Year',
  ];

  List<DutyShiftHistory> get _filteredShifts {
    // Current time context is June 19, 2026
    final refDate = DateTime(2026, 6, 19, 23, 59, 59);
    DateTime cutOffDate;

    switch (_selectedRange) {
      case 'Last 30 Days':
        cutOffDate = refDate.subtract(const Duration(days: 30));
        break;
      case 'Last 3 Months':
        cutOffDate = refDate.subtract(const Duration(days: 90));
        break;
      case 'Last 6 Months':
        cutOffDate = refDate.subtract(const Duration(days: 180));
        break;
      case 'Last 1 Year':
      default:
        cutOffDate = refDate.subtract(const Duration(days: 365));
        break;
    }

    return _allShifts.where((s) => s.date.isAfter(cutOffDate)).toList();
  }

  String _calculateAverageShift(List<DutyShiftHistory> shifts) {
    if (shifts.isEmpty) return "0h 0m";
    double total = shifts.fold(0.0, (sum, s) => sum + s.durationHours);
    double avg = total / shifts.length;
    int hours = avg.floor();
    int minutes = ((avg - hours) * 60).round();
    return "${hours}h ${minutes}m";
  }

  String _calculateTotalHours(List<DutyShiftHistory> shifts) {
    double total = shifts.fold(0.0, (sum, s) => sum + s.durationHours);
    if (total == total.roundToDouble()) {
      return "${total.round()}h";
    }
    return "${total.toStringAsFixed(1)}h";
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredShifts;
    final avgShift = _calculateAverageShift(filteredList);
    final totalHrs = _calculateTotalHours(filteredList);
    final shiftsDone = filteredList.length.toString();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: const AppAppBar(
        title: "Duties history",
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        showBack: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter and Stats Card Header
            _buildStatsCard(avgShift, totalHrs, shiftsDone),

            Expanded(
              child: filteredList.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final shift = filteredList[index];
                        return _buildHistoryItem(shift);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(String avgShift, String totalHrs, String shiftsDone) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFEFF1F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF1FE),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      LucideIcons.briefcase,
                      color: AppColors.primary,
                      size: 15.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Duties Summary',
                        style: TextStyle(
                          color: const Color(0xFF0B0F1A),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'AirbnbCereal',
                        ),
                      ),
                      Text(
                        'Based on selected filter',
                        style: TextStyle(
                          color: const Color(0xFF5A6373),
                          fontSize: 10.sp,
                          fontFamily: 'AirbnbCereal',
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Filter Dropdown
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: const Color(0xFFE2E6EE)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.015),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRange,
                    dropdownColor: Colors.white,
                    isDense: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: const Color(0xFF5A6373),
                      size: 18.sp,
                    ),
                    style: TextStyle(
                      color: const Color(0xFF0B0F1A),
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'AirbnbCereal',
                    ),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedRange = newValue;
                        });
                      }
                    },
                    items: _rangeOptions.map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.calendar,
                              size: 13.sp,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              value,
                              style: TextStyle(
                                color: const Color(0xFF0B0F1A),
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'AirbnbCereal',
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(avgShift, 'Avg Shift'),
              Container(width: 1, height: 24.h, color: const Color(0xFFE5E8EE)),
              _buildStatItem(totalHrs, 'Total Hrs'),
              Container(width: 1, height: 24.h, color: const Color(0xFFE5E8EE)),
              _buildStatItem(shiftsDone, 'Shifts Done'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFF0B0F1A),
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            fontFamily: 'AirbnbCereal',
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF5A6373),
            fontSize: 9.5.sp,
            fontWeight: FontWeight.w500,
            fontFamily: 'AirbnbCereal',
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(DutyShiftHistory shift) {
    // Wait, let's make it look correct. E.g. "Mon, Jun 16"
    final formattedDate = DateFormat('EEE, MMM d').format(shift.date);

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFEFF1F5)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DutiesHistoryDetailsScreen(shift: shift),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F5F9),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    LucideIcons.clock,
                    color: const Color(0xFF9AA2B1),
                    size: 14.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: const Color(0xFF0B0F1A),
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'AirbnbCereal',
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        '${shift.checkInTime} – ${shift.checkOutTime}',
                        style: TextStyle(
                          color: const Color(0xFF9AA2B1),
                          fontSize: 10.5.sp,
                          fontFamily: 'AirbnbCereal',
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.map_pin,
                            size: 11.sp,
                            color: const Color(0xFF9AA2B1),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              shift.locationName,
                              style: TextStyle(
                                color: const Color(0xFF5A6373),
                                fontSize: 10.5.sp,
                                fontFamily: 'AirbnbCereal',
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F5F9),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        shift.duration,
                        style: TextStyle(
                          color: const Color(0xFF5A6373),
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'AirbnbCereal',
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF5EE),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        "Completed",
                        style: TextStyle(
                          color: const Color(0xFF127A45),
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'AirbnbCereal',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.calendar_x,
            color: const Color(0xFF9AA2B1),
            size: 48.sp,
          ),
          SizedBox(height: 12.h),
          Text(
            'No Shifts Found',
            style: TextStyle(
              color: const Color(0xFF0B0F1A),
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'AirbnbCereal',
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Try choosing a broader date range filter.',
            style: TextStyle(
              color: const Color(0xFF9AA2B1),
              fontSize: 11.sp,
              fontFamily: 'AirbnbCereal',
            ),
          ),
        ],
      ),
    );
  }
}
