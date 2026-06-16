import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:presshop_enterprise/features/map/core/map_constants.dart';
import 'package:presshop_enterprise/presentation/widgets/app_app_bar.dart';

class PayslipScreen extends StatefulWidget {
  const PayslipScreen({super.key});

  @override
  State<PayslipScreen> createState() => _PayslipScreenState();
}

class _PayslipScreenState extends State<PayslipScreen> {
  String _selectedMonth = 'April 2026';
  bool _earningsExpanded = true;
  bool _deductionsExpanded = true;

  final Map<String, Map<String, dynamic>> _payslipData = {
    'April 2026': {
      'netPay': 78450.00,
      'payDate': '05 May 2026',
      'payPeriod': '01 Apr 2026 - 30 Apr 2026',
      'earnings': {
        'Basic Salary': 45000.00,
        'House Rent Allowance (HRA)': 18000.00,
        'Dearness Allowance (DA)': 7500.00,
        'Special Allowance': 6000.00,
        'Other Allowances': 2500.00,
      },
      'deductions': {
        'Provident Fund (PF)': 5400.00,
        'Professional Tax': 200.00,
        'Income Tax (TDS)': 10950.00,
        'ESI': 0.00,
      },
    },
    'May 2026': {
      'netPay': 81200.00,
      'payDate': '05 Jun 2026',
      'payPeriod': '01 May 2026 - 31 May 2026',
      'earnings': {
        'Basic Salary': 47000.00,
        'House Rent Allowance (HRA)': 19000.00,
        'Dearness Allowance (DA)': 7800.00,
        'Special Allowance': 6200.00,
        'Other Allowances': 2700.00,
      },
      'deductions': {
        'Provident Fund (PF)': 5600.00,
        'Professional Tax': 200.00,
        'Income Tax (TDS)': 11300.00,
        'ESI': 400.00,
      },
    },
    'June 2026': {
      'netPay': 76500.00,
      'payDate': '05 Jul 2026',
      'payPeriod': '01 Jun 2026 - 30 Jun 2026',
      'earnings': {
        'Basic Salary': 44000.00,
        'House Rent Allowance (HRA)': 17500.00,
        'Dearness Allowance (DA)': 7200.00,
        'Special Allowance': 5800.00,
        'Other Allowances': 2300.00,
      },
      'deductions': {
        'Provident Fund (PF)': 5280.00,
        'Professional Tax': 200.00,
        'Income Tax (TDS)': 10200.00,
        'ESI': 0.00,
      },
    },
  };

  double _calculateTotal(Map<String, double> items) {
    return items.values.fold(0.0, (sum, val) => sum + val);
  }

  void _showNotification(String message, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'AirbnbCereal',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colorEmployeeGreen1,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _payslipData[_selectedMonth] ?? _payslipData['April 2026']!;
    final double totalEarnings = _calculateTotal(
      Map<String, double>.from(data['earnings']),
    );
    final double totalDeductions = _calculateTotal(
      Map<String, double>.from(data['deductions']),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppAppBar(
        title: "Payslip",
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        showBack: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.download, color: Colors.black),
            onPressed: () => _showNotification(
              "Downloading payslip PDF...",
              LucideIcons.download,
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.share_2, color: Colors.black),
            onPressed: () =>
                _showNotification("Sharing payslip...", LucideIcons.share_2),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                children: [
                  // Month selection and Net Pay header row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Select Month dropdown box
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Select Month",
                              style: TextStyle(
                                fontFamily: 'AirbnbCereal',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedMonth,
                                  isExpanded: true,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.grey,
                                  ),
                                  items: _payslipData.keys.map((String month) {
                                    return DropdownMenuItem<String>(
                                      value: month,
                                      child: Row(
                                        children: [
                                          const Icon(
                                            LucideIcons.calendar,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            month,
                                            style: const TextStyle(
                                              fontFamily: 'AirbnbCereal',
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedMonth = value;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Net Pay quick indicator card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFDCFCE7)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Net Pay",
                                style: TextStyle(
                                  fontFamily: 'AirbnbCereal',
                                  fontSize: 11,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "₹ ${data['netPay'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                                style: const TextStyle(
                                  fontFamily: 'AirbnbCereal',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    "Paid on ${data['payDate'].toString().split(' ')[0]} ${data['payDate'].toString().split(' ')[1]}",
                                    style: const TextStyle(
                                      fontFamily: 'AirbnbCereal',
                                      fontSize: 9,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.check_circle,
                                    size: 12,
                                    color: Color(0xFF10B981),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Employee Details Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: NetworkImage(
                                    "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=120&auto=format&fit=crop",
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Rohit Sharma",
                                    style: TextStyle(
                                      fontFamily: 'AirbnbCereal',
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    "EMP12345",
                                    style: TextStyle(
                                      fontFamily: 'AirbnbCereal',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: colorEmployeeGreen1,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    "Site Engineer",
                                    style: TextStyle(
                                      fontFamily: 'AirbnbCereal',
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildProfileMetaItem(
                                    LucideIcons.briefcase,
                                    "Engineering Department",
                                  ),
                                  const SizedBox(height: 8),
                                  _buildProfileMetaItem(
                                    LucideIcons.map_pin,
                                    "Bangalore, India",
                                  ),
                                  const SizedBox(height: 8),
                                  _buildProfileMetaItem(
                                    LucideIcons.calendar,
                                    "Joined on 15 Jun 2023",
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Collapsible Earnings Card
                  _buildSectionCard(
                    title: "Earnings",
                    icon: LucideIcons.wallet,
                    iconColor: const Color(0xFF10B981),
                    iconBgColor: const Color(0xFFE6F9F2),
                    isExpanded: _earningsExpanded,
                    onToggle: () =>
                        setState(() => _earningsExpanded = !_earningsExpanded),
                    items: Map<String, double>.from(data['earnings']),
                    totalLabel: "Total Earnings",
                    totalValue: totalEarnings,
                    accentColor: const Color(0xFF10B981),
                  ),
                  const SizedBox(height: 16),

                  // Collapsible Deductions Card
                  _buildSectionCard(
                    title: "Deductions",
                    icon: LucideIcons.shield_alert,
                    iconColor: const Color(0xFFEF4444),
                    iconBgColor: const Color(0xFFFEE2E2),
                    isExpanded: _deductionsExpanded,
                    onToggle: () => setState(
                      () => _deductionsExpanded = !_deductionsExpanded,
                    ),
                    items: Map<String, double>.from(data['deductions']),
                    totalLabel: "Total Deductions",
                    totalValue: totalDeductions,
                    accentColor: const Color(0xFFEF4444),
                  ),
                  const SizedBox(height: 16),

                  // Formula Net Pay highlights Card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFDBEAFE)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Net Pay",
                              style: TextStyle(
                                fontFamily: 'AirbnbCereal',
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "(Total Earnings - Total Deductions)",
                              style: TextStyle(
                                fontFamily: 'AirbnbCereal',
                                fontSize: 10,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "₹ ${data['netPay'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                          style: const TextStyle(
                            fontFamily: 'AirbnbCereal',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Grid bank and period details card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Table(
                      children: [
                        TableRow(
                          children: [
                            _buildGridDetailItem(
                              "Pay Period",
                              data['payPeriod'],
                            ),
                            _buildGridDetailItem("Pay Date", data['payDate']),
                            _buildGridDetailItem(
                              "Payment Mode",
                              "Bank Transfer",
                            ),
                          ],
                        ),
                        const TableRow(
                          children: [
                            SizedBox(height: 14),
                            SizedBox(height: 14),
                            SizedBox(height: 14),
                          ],
                        ),
                        TableRow(
                          children: [
                            _buildGridDetailItem("Bank Name", "HDFC Bank"),
                            _buildGridDetailItem(
                              "Account Number",
                              "XXXX XXXX 1234",
                            ),
                            _buildGridDetailItem("IFSC Code", "HDFC0001234"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Disclaimer footnote
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        LucideIcons.info,
                        size: 14,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "This is a system generated payslip and does not require signature.",
                          style: TextStyle(
                            fontFamily: 'AirbnbCereal',
                            fontSize: 10.5,
                            color: Colors.grey.shade500,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMetaItem(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Colors.grey.shade500),
        const SizedBox(width: 10),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'AirbnbCereal',
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Map<String, double> items,
    required String totalLabel,
    required double totalValue,
    required Color accentColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'AirbnbCereal',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "Amount (₹)",
                    style: TextStyle(
                      fontFamily: 'AirbnbCereal',
                      fontSize: 11,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ...items.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontFamily: 'AirbnbCereal',
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            entry.value
                                .toStringAsFixed(2)
                                .replaceAllMapped(
                                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                  (Match m) => '${m[1]},',
                                ),
                            style: const TextStyle(
                              fontFamily: 'AirbnbCereal',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 4),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        totalLabel,
                        style: TextStyle(
                          fontFamily: 'AirbnbCereal',
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                      Text(
                        totalValue
                            .toStringAsFixed(2)
                            .replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]},',
                            ),
                        style: TextStyle(
                          fontFamily: 'AirbnbCereal',
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGridDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'AirbnbCereal',
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'AirbnbCereal',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
