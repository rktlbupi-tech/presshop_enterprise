import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../../core/constants/app_colors.dart';

const double _numD05 = 0.05;
const double _numD025 = 0.025;
const double _numD03 = 0.03;
const double _numD032 = 0.032;
const double _numD026 = 0.026;
const double _numD036 = 0.036;
const double _numD04 = 0.04;
const double _numD045 = 0.045;
const double _appBarHeadingFontSize = 0.045;

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  String? _expandedMonth;
  String _selectedYear = '2026';

  // Earnings dataset corresponding to different months
  final Map<String, Map<String, dynamic>> _earningsData = {
    'April 2026': {
      'netEarnings': 83450.00,
      'payDate': '05 May 2026',
      'payPeriod': '01 Apr 2026 - 30 Apr 2026',
      'salaryComponents': {
        'Basic Salary': 45000.00,
        'House Rent Allowance (HRA)': 18000.00,
        'Dearness Allowance (DA)': 7500.00,
        'Special Allowance': 6000.00,
        'Performance Bonus': 4500.00,
      },
      'reimbursements': {
        'Mileage Claims': 1250.00,
        'Meal Expenses': 800.00,
        'Parking & Toll Charges': 400.00,
      },
      'transactions': [
        {
          'title': 'Monthly Salary Payout',
          'amount': 81000.00,
          'date': '05 May 2026',
          'status': 'Paid',
          'bank': 'HDFC Bank (XXXX 1234)',
          'refNo': 'TXN83749284',
        },
        {
          'title': 'Mileage & Expense Reimbursement',
          'amount': 2450.00,
          'date': '08 May 2026',
          'status': 'Paid',
          'bank': 'HDFC Bank (XXXX 1234)',
          'refNo': 'TXN83750192',
        },
      ],
    },
    'May 2026': {
      'netEarnings': 87200.00,
      'payDate': '05 Jun 2026',
      'payPeriod': '01 May 2026 - 31 May 2026',
      'salaryComponents': {
        'Basic Salary': 47000.00,
        'House Rent Allowance (HRA)': 19000.00,
        'Dearness Allowance (DA)': 7800.00,
        'Special Allowance': 6200.00,
        'Overtime Pay': 3500.00,
      },
      'reimbursements': {
        'Mileage Claims': 1950.00,
        'Meal Expenses': 1200.00,
        'Parking & Toll Charges': 550.00,
      },
      'transactions': [
        {
          'title': 'Monthly Salary Payout',
          'amount': 83500.00,
          'date': '05 Jun 2026',
          'status': 'Paid',
          'bank': 'HDFC Bank (XXXX 1234)',
          'refNo': 'TXN84920485',
        },
        {
          'title': 'Mileage & Expense Reimbursement',
          'amount': 3700.00,
          'date': '10 Jun 2026',
          'status': 'Paid',
          'bank': 'HDFC Bank (XXXX 1234)',
          'refNo': 'TXN84931024',
        },
      ],
    },
    'June 2026': {
      'netEarnings': 81300.00,
      'payDate': '05 Jul 2026',
      'payPeriod': '01 Jun 2026 - 30 Jun 2026',
      'salaryComponents': {
        'Basic Salary': 44000.00,
        'House Rent Allowance (HRA)': 17500.00,
        'Dearness Allowance (DA)': 7200.00,
        'Special Allowance': 5800.00,
        'Bonus Incentive': 3000.00,
      },
      'reimbursements': {
        'Mileage Claims': 1800.00,
        'Meal Expenses': 1500.00,
        'Parking & Toll Charges': 500.00,
      },
      'transactions': [
        {
          'title': 'Monthly Salary Payout',
          'amount': 77500.00,
          'date': '05 Jul 2026',
          'status': 'Paid',
          'bank': 'HDFC Bank (XXXX 1234)',
          'refNo': 'TXN85102948',
        },
        {
          'title': 'Mileage & Expense Reimbursement',
          'amount': 3800.00,
          'date': '12 Jul 2026',
          'status': 'Paid',
          'bank': 'HDFC Bank (XXXX 1234)',
          'refNo': 'TXN85114829',
        },
      ],
    },
  };

  void _showNotification(String message, IconData icon) {
    final size = MediaQuery.of(context).size;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: size.width * _numD05),
            SizedBox(width: size.width * _numD025),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontFamily: 'AirbnbCereal',
                  fontWeight: FontWeight.bold,
                  fontSize: size.width * 0.035,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size.width * _numD025),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Calculate total earnings of the year
    double totalEarningsOfYear = 0.0;
    _earningsData.forEach((key, val) {
      totalEarningsOfYear += (val['netEarnings'] as num).toDouble();
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Image.asset(
            'assets/icons/ic_arrow_left.png',
            width: 24.w,
            height: 24.w,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Earnings",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'AirbnbCereal',
            fontSize: size.width * _appBarHeadingFontSize,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              LucideIcons.download,
              color: Colors.black,
              size: size.width * _numD05,
            ),
            onPressed: () => _showNotification(
              "Downloading statement PDF...",
              LucideIcons.download,
            ),
          ),
          IconButton(
            icon: Icon(
              LucideIcons.share_2,
              color: Colors.black,
              size: size.width * _numD05,
            ),
            onPressed: () =>
                _showNotification("Sharing statement...", LucideIcons.share_2),
          ),
          SizedBox(width: size.width * _numD025),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * _numD04,
                  vertical: size.width * _numD03,
                ),
                children: [
                  // Total Earnings Card (Premium Full-width, Hopper-style)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(
                        alpha: 0.05,
                      ), // Pale Blue background
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          // Left: Profile Avatar
                          Container(
                            width: size.width * 0.15,
                            height: size.width * 0.15,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2,
                              ),
                              image: const DecorationImage(
                                image: NetworkImage(
                                  "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=120&auto=format&fit=crop",
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Right: Earnings details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Total Earnings of Year",
                                  style: TextStyle(
                                    fontFamily: 'AirbnbCereal',
                                    fontSize: size.width * _numD032,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "₹ ${totalEarningsOfYear.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                                  style: TextStyle(
                                    fontFamily: 'AirbnbCereal',
                                    fontSize:
                                        size.width *
                                        0.07, // Hopper style big font
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(
                                      "Year: ",
                                      style: TextStyle(
                                        fontFamily: 'AirbnbCereal',
                                        fontSize: size.width * _numD026,
                                        color: AppColors.primary.withValues(
                                          alpha: 0.8,
                                        ),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(
                                      height: size.width * 0.05,
                                      child: _CustomDropdown<String>(
                                        value: _selectedYear,
                                        items: const [
                                          '2023',
                                          '2024',
                                          '2025',
                                          '2026',
                                        ],
                                        buttonColor: Colors.transparent,
                                        padding: const EdgeInsets.only(left: 4),
                                        border: Border.all(
                                          color: Colors.transparent,
                                        ),
                                        icon: Icon(
                                          LucideIcons.chevron_down,
                                          size: size.width * _numD03,
                                          color: AppColors.primary.withValues(
                                            alpha: 0.8,
                                          ),
                                        ),
                                        itemBuilder: (value, isSelected) {
                                          return Text(
                                            value,
                                            style: TextStyle(
                                              fontFamily: 'AirbnbCereal',
                                              fontSize: size.width * _numD026,
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.8),
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.w500,
                                            ),
                                          );
                                        },
                                        onChanged: (String newValue) {
                                          setState(() {
                                            _selectedYear = newValue;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: size.width * _numD05),

                  // Monthly breakdown header
                  Text(
                    "Monthly Breakdown",
                    style: TextStyle(
                      fontFamily: 'AirbnbCereal',
                      fontSize: size.width * _numD036,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // List of months and their income
                  ..._earningsData.entries.map((entry) {
                    final monthName = entry.key;
                    final monthData = entry.value;
                    final double netEarnings = monthData['netEarnings'];
                    final isExpanded = _expandedMonth == monthName;
                    final salaryComponents = Map<String, double>.from(
                      monthData['salaryComponents'] ?? {},
                    );
                    final reimbursements = Map<String, double>.from(
                      monthData['reimbursements'] ?? {},
                    );
                    final double totalSalary = salaryComponents.values.fold(
                      0.0,
                      (sum, val) => sum + val,
                    );
                    final double totalReimbursements = reimbursements.values
                        .fold(0.0, (sum, val) => sum + val);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEFF1F6)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.01),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (_expandedMonth == monthName) {
                              _expandedMonth = null;
                            } else {
                              _expandedMonth = monthName;
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.08,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        LucideIcons.calendar,
                                        color: AppColors.primary,
                                        size: size.width * _numD04,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            monthName,
                                            style: const TextStyle(
                                              fontFamily: 'AirbnbCereal',
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1F2937),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Paid on ${monthData['payDate']}",
                                            style: TextStyle(
                                              fontFamily: 'AirbnbCereal',
                                              fontSize: 12,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      "₹ ${netEarnings.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                                      style: TextStyle(
                                        fontFamily: 'AirbnbCereal',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      isExpanded
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: Colors.grey,
                                      size: size.width * _numD045,
                                    ),
                                  ],
                                ),
                                if (isExpanded) ...[
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Divider(
                                      height: 1,
                                      color: Color(0xFFF1F5F9),
                                    ),
                                  ),
                                  // Pay Period
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Pay Period",
                                        style: TextStyle(
                                          fontFamily: 'AirbnbCereal',
                                          fontSize: 12,
                                          color: Color(0xFF6B7280),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        monthData['payPeriod'] ?? '',
                                        style: const TextStyle(
                                          fontFamily: 'AirbnbCereal',
                                          fontSize: 12,
                                          color: Color(0xFF1F2937),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Salary Components Section
                                  Row(
                                    children: [
                                      Icon(
                                        LucideIcons.wallet,
                                        size: 16,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        "Salary Components",
                                        style: TextStyle(
                                          fontFamily: 'AirbnbCereal',
                                          fontSize: 13,
                                          color: Color(0xFF374151),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ...salaryComponents.entries.map(
                                    (entry) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 6,
                                        left: 22,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            entry.key,
                                            style: const TextStyle(
                                              fontFamily: 'AirbnbCereal',
                                              fontSize: 12,
                                              color: Color(0xFF4B5563),
                                            ),
                                          ),
                                          Text(
                                            "₹ ${entry.value.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                                            style: const TextStyle(
                                              fontFamily: 'AirbnbCereal',
                                              fontSize: 12,
                                              color: Color(0xFF1F2937),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(
                                      left: 22,
                                      top: 4,
                                      bottom: 8,
                                    ),
                                    child: Divider(
                                      height: 1,
                                      color: Color(0xFFF1F5F9),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 22,
                                      bottom: 12,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Total Salary",
                                          style: TextStyle(
                                            fontFamily: 'AirbnbCereal',
                                            fontSize: 12,
                                            color: Color(0xFF10B981),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "₹ ${totalSalary.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                                          style: const TextStyle(
                                            fontFamily: 'AirbnbCereal',
                                            fontSize: 12,
                                            color: Color(0xFF10B981),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Reimbursements Section
                                  Row(
                                    children: [
                                      Icon(
                                        LucideIcons.receipt,
                                        size: 16,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        "Reimbursements",
                                        style: TextStyle(
                                          fontFamily: 'AirbnbCereal',
                                          fontSize: 13,
                                          color: Color(0xFF374151),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ...reimbursements.entries.map(
                                    (entry) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 6,
                                        left: 22,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            entry.key,
                                            style: const TextStyle(
                                              fontFamily: 'AirbnbCereal',
                                              fontSize: 12,
                                              color: Color(0xFF4B5563),
                                            ),
                                          ),
                                          Text(
                                            "₹ ${entry.value.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                                            style: const TextStyle(
                                              fontFamily: 'AirbnbCereal',
                                              fontSize: 12,
                                              color: Color(0xFF1F2937),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(
                                      left: 22,
                                      top: 4,
                                      bottom: 8,
                                    ),
                                    child: Divider(
                                      height: 1,
                                      color: Color(0xFFF1F5F9),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 22),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Total Reimbursements",
                                          style: TextStyle(
                                            fontFamily: 'AirbnbCereal',
                                            fontSize: 12,
                                            color: Color(0xFF3B82F6),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "₹ ${totalReimbursements.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                                          style: const TextStyle(
                                            fontFamily: 'AirbnbCereal',
                                            fontSize: 12,
                                            color: Color(0xFF3B82F6),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: size.width * _numD025),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final Widget Function(T, bool)
  itemBuilder; // Item widget builder, passes item and selected state
  final ValueChanged<T> onChanged;
  final Widget? icon;
  final Color? buttonColor;
  final double? buttonWidth;
  final double? width;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final BoxBorder? border;

  const _CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.itemBuilder,
    required this.onChanged,
    this.icon,
    this.buttonColor,
    this.buttonWidth,
    this.width,
    this.borderRadius,
    this.padding,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: PopupMenuButton<T>(
        initialValue: value,
        onSelected: onChanged,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        color: Colors.white,
        elevation: 8,
        offset: const Offset(0, 38),
        padding: EdgeInsets.zero,
        itemBuilder: (BuildContext context) {
          return items.map((T item) {
            final isSelected = item == value;
            return PopupMenuItem<T>(
              value: item,
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: buttonWidth ?? 110,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.grey.shade200 : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: itemBuilder(item, isSelected),
              ),
            );
          }).toList();
        },
        child: Container(
          width: width,
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: buttonColor ?? Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadius ?? 8),
            border:
                border ??
                Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          ),
          child: Row(
            mainAxisSize: width != null ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (width != null)
                Expanded(child: itemBuilder(value, false))
              else
                itemBuilder(value, false),
              const SizedBox(width: 8),
              icon ??
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF64748B),
                    size: 18,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
