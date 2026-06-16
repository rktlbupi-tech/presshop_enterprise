import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../presentation/widgets/app_app_bar.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/custom_dropdown.dart';

class ClaimExpensesScreen extends StatefulWidget {
  const ClaimExpensesScreen({super.key});

  @override
  State<ClaimExpensesScreen> createState() => _ClaimExpensesScreenState();
}

class _ClaimExpensesScreenState extends State<ClaimExpensesScreen> {
  // Expenses State
  String _expenseSummaryFilter = 'This Month';
  final List<Map<String, dynamic>> _claims = [
    {
      'type': 'Fuel Expense',
      'detail': 'Site Visit - Building A',
      'date': '08 May 2026',
      'amount': '£65.50',
      'status': 'In Review',
      'icon': LucideIcons.fuel,
      'iconColor': const Color(0xFF0066FF),
      'iconBg': const Color(0xFFEFF6FF),
    },
    {
      'type': 'Meal Expense',
      'detail': 'Client Meeting',
      'date': '07 May 2026',
      'amount': '£28.00',
      'status': 'Approved',
      'isReimbursed': true,
      'icon': LucideIcons.utensils,
      'iconColor': const Color(0xFF10B981),
      'iconBg': const Color(0xFFE6F9F2),
    },
    {
      'type': 'Parking Charges',
      'detail': 'Site Visit - Building B',
      'date': '06 May 2026',
      'amount': '£12.00',
      'status': 'Approved',
      'isReimbursed': true,
      'icon': LucideIcons.car,
      'iconColor': const Color(0xFF8B5CF6),
      'iconBg': const Color(0xFFF5F3FF),
    },
    {
      'type': 'Toll Charges',
      'detail': 'Site Visit - Building A',
      'date': '05 May 2026',
      'amount': '£15.00',
      'status': 'Rejected',
      'icon': LucideIcons.container,
      'iconColor': const Color(0xFFEF4444),
      'iconBg': const Color(0xFFFEE2E2),
    },
  ];

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'AirbnbCereal',
            fontSize: 12,
            color: Colors.white,
          ),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required double sizeWidth,
    required String hintText,
    IconData? prefixIcon,
    double fontSize = 13.5,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, size: 18, color: Colors.grey)
          : null,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      hintStyle: TextStyle(
        fontFamily: 'AirbnbCereal',
        color: Colors.grey,
        fontSize: fontSize,
      ),
      errorStyle: const TextStyle(fontFamily: 'AirbnbCereal'),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  void _addNewExpense() {
    String selectedCategory = 'Select Category';
    final dateCtrl = TextEditingController();
    final detailCtrl = TextEditingController();
    final amtCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final size = MediaQuery.of(context).size;
        String? attachmentName;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Add New Expense",
                    style: TextStyle(
                      fontFamily: 'AirbnbCereal',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 14),
                  CustomDropdown<String>(
                    value: selectedCategory,
                    items: const [
                      'Select Category',
                      'Fuel',
                      'Meal',
                      'Parking & Toll',
                      'Travel',
                      'Accommodation',
                      'Office Supplies',
                      'Other',
                    ],
                    width: double.infinity,
                    buttonWidth: size.width - 64,
                    buttonColor: Colors.grey.shade50,
                    borderRadius: 10,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9.5,
                    ),
                    border: Border.all(color: Colors.grey.shade200, width: 1.0),
                    itemBuilder: (category, isSelected) {
                      return Text(
                        category,
                        style: TextStyle(
                          fontFamily: 'AirbnbCereal',
                          fontSize: 13.5,
                          color: category == 'Select Category'
                              ? Colors.grey
                              : Colors.black87,
                        ),
                      );
                    },
                    onChanged: (String val) {
                      setModalState(() {
                        selectedCategory = val;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: dateCtrl,
                    readOnly: true,
                    style: const TextStyle(
                      fontFamily: 'AirbnbCereal',
                      fontSize: 13.5,
                    ),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2101),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppColors.primary,
                                onPrimary: Colors.white,
                                onSurface: Colors.black,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedDate != null) {
                        setModalState(() {
                          dateCtrl.text = DateFormat(
                            'dd MMM yyyy',
                          ).format(pickedDate);
                        });
                      }
                    },
                    decoration: _inputDecoration(
                      sizeWidth: size.width,
                      hintText: "Date",
                      prefixIcon: LucideIcons.calendar,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: detailCtrl,
                    style: const TextStyle(
                      fontFamily: 'AirbnbCereal',
                      fontSize: 13.5,
                    ),
                    decoration: _inputDecoration(
                      sizeWidth: size.width,
                      hintText: "Add description",
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: amtCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontFamily: 'AirbnbCereal',
                      fontSize: 13.5,
                    ),
                    decoration: _inputDecoration(
                      sizeWidth: size.width,
                      hintText: "Amount (£)",
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "Attach Receipt",
                    style: TextStyle(
                      fontFamily: 'AirbnbCereal',
                      fontSize: size.width * 0.03,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(
                                  LucideIcons.camera,
                                  color: AppColors.primary,
                                ),
                                title: const Text(
                                  "Take Photo",
                                  style: TextStyle(fontFamily: 'AirbnbCereal'),
                                ),
                                onTap: () async {
                                  Navigator.pop(context);
                                  try {
                                    final XFile? image = await picker.pickImage(
                                      source: ImageSource.camera,
                                    );
                                    if (image != null) {
                                      setModalState(() {
                                        attachmentName = image.name;
                                      });
                                    }
                                  } catch (e) {
                                    _showToast("Camera access denied: $e");
                                  }
                                },
                              ),
                              ListTile(
                                leading: const Icon(
                                  LucideIcons.image,
                                  color: AppColors.primary,
                                ),
                                title: const Text(
                                  "Choose from Gallery",
                                  style: TextStyle(fontFamily: 'AirbnbCereal'),
                                ),
                                onTap: () async {
                                  Navigator.pop(context);
                                  try {
                                    final XFile? image = await picker.pickImage(
                                      source: ImageSource.gallery,
                                    );
                                    if (image != null) {
                                      setModalState(() {
                                        attachmentName = image.name;
                                      });
                                    }
                                  } catch (e) {
                                    _showToast("Gallery access denied: $e");
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 9.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          const Icon(
                            LucideIcons.paperclip,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              attachmentName ?? "Upload Receipt / Camera",
                              style: const TextStyle(
                                fontFamily: 'AirbnbCereal',
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _PresshopCommonButton(
                    text: "Submit Claim",
                    backgroundColor: AppColors.primary,
                    height: 44,
                    fontSize: 14,
                    onPressed: () {
                      if (selectedCategory == 'Select Category') {
                        _showToast("Please select a category");
                        return;
                      }
                      if (dateCtrl.text.isEmpty) {
                        _showToast("Please select a date");
                        return;
                      }
                      if (detailCtrl.text.isEmpty) {
                        _showToast("Please add a description");
                        return;
                      }
                      if (amtCtrl.text.isEmpty) {
                        _showToast("Please enter an amount");
                        return;
                      }
                      if (attachmentName == null) {
                        _showToast("Please attach a receipt");
                        return;
                      }

                      setState(() {
                        _claims.insert(0, {
                          'type': selectedCategory,
                          'detail': detailCtrl.text,
                          'date': dateCtrl.text,
                          'amount': '£${amtCtrl.text}',
                          'status': 'In Review',
                          'icon': LucideIcons.receipt,
                          'iconColor': const Color(0xFF8B5CF6),
                          'iconBg': const Color(0xFFF5F3FF),
                          'attachment': attachmentName,
                        });
                      });
                      Navigator.pop(context);
                      _showToast("Expense claim submitted.");
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppAppBar(
        title: "Claim Expenses",
        elevation: 0.5,
        centerTitle: false,
        titleSpacing: 0,
        showBack: true,
      ),
      body: SafeArea(child: _buildExpensesContent(size)),
    );
  }

  Widget _buildExpensesContent(Size size) {
    return ListView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
      children: [
        // My Expense Summary Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "My Expense Summary",
              style: TextStyle(
                fontFamily: 'AirbnbCereal',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            // Summary month dropdown
            CustomDropdown<String>(
              value: _expenseSummaryFilter,
              items: const ['This Month', 'Last Month', 'Last 3 Months'],
              buttonWidth: 125,
              buttonColor: Colors.white,
              itemBuilder: (month, isSelected) {
                return Text(
                  month,
                  style: TextStyle(
                    fontFamily: 'AirbnbCereal',
                    fontSize: 12,
                    color: isSelected
                        ? const Color(0xFF1F2937)
                        : const Color(0xFF6B7280),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                );
              },
              onChanged: (String val) {
                setState(() {
                  _expenseSummaryFilter = val;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Expense metrics status grid (horizontal row)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildExpenseStatusItem(
                "Submitted",
                "£320.50",
                "3 Claims",
                LucideIcons.folder,
                const Color(0xFF0066FF),
                const Color(0xFFEFF6FF),
              ),
              const SizedBox(width: 8),
              _buildExpenseStatusItem(
                "In Review",
                "£120.00",
                "1 Claim",
                LucideIcons.clock,
                const Color(0xFFF59E0B),
                const Color(0xFFFFF8EC),
              ),
              const SizedBox(width: 8),
              _buildExpenseStatusItem(
                "Approved",
                "£200.50",
                "2 Claims",
                Icons.check_circle_outline,
                const Color(0xFF10B981),
                const Color(0xFFE6F9F2),
              ),
              const SizedBox(width: 8),
              _buildExpenseStatusItem(
                "Rejected",
                "£0.00",
                "0 Claims",
                Icons.cancel_outlined,
                const Color(0xFFEF4444),
                const Color(0xFFFEE2E2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _PresshopCommonButton(
          text: "Add Expense",
          backgroundColor: AppColors.primary,
          onPressed: _addNewExpense,
        ),
        const SizedBox(height: 18),

        // Recent Claims Section
        const Text(
          "Recent Claims",
          style: TextStyle(
            fontFamily: 'AirbnbCereal',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),

        // Claims list items
        ..._claims.map((claim) {
          final isApproved = claim['status'] == 'Approved';
          final isRejected = claim['status'] == 'Rejected';
          final isReimbursed = claim['isReimbursed'] == true;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: claim['iconBg'],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    claim['icon'],
                    color: claim['iconColor'],
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        claim['type'],
                        style: const TextStyle(
                          fontFamily: 'AirbnbCereal',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        claim['detail'],
                        style: const TextStyle(
                          fontFamily: 'AirbnbCereal',
                          fontSize: 10,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        claim['date'],
                        style: const TextStyle(
                          fontFamily: 'AirbnbCereal',
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isApproved
                            ? const Color(0xFFE6F9F2)
                            : isRejected
                            ? const Color(0xFFFEE2E2)
                            : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        claim['status'],
                        style: TextStyle(
                          fontFamily: 'AirbnbCereal',
                          fontWeight: FontWeight.bold,
                          fontSize: size.width * 0.023,
                          color: isApproved
                              ? const Color(0xFF10B981)
                              : isRejected
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF0066FF),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      claim['amount'],
                      style: const TextStyle(
                        fontFamily: 'AirbnbCereal',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    if (isReimbursed) ...[
                      const SizedBox(height: 2),
                      Text(
                        "Reimbursed",
                        style: TextStyle(
                          fontFamily: 'AirbnbCereal',
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF10B981),
                          fontSize: size.width * 0.023,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 12),

        // Reimbursements footnote note
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(LucideIcons.info, size: 16, color: Color(0xFF0066FF)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Claim expenses and get reimbursed. Ensure receipts are clear and all details are accurate for faster approval.",
                  style: TextStyle(
                    fontFamily: 'AirbnbCereal',
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildExpenseStatusItem(
    String label,
    String value,
    String subText,
    IconData icon,
    Color color,
    Color bgColor,
  ) {
    final size = MediaQuery.of(context).size;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15), width: 1.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'AirbnbCereal',
                fontSize: size.width * 0.028,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'AirbnbCereal',
                fontSize: size.width * 0.038,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subText,
              style: TextStyle(
                fontFamily: 'AirbnbCereal',
                fontSize: size.width * 0.024,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PresshopCommonButton extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final Color? backgroundColor;
  final Color textColor;
  final double height;
  final double? width;
  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;
  final BorderSide? borderSide;

  const _PresshopCommonButton({
    this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.height = 48,
    this.width,
    this.borderRadius = 12,
    this.fontSize = 15,
    this.fontWeight = FontWeight.bold,
    this.borderSide,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null && !isLoading;

    final Widget content = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
              strokeWidth: 2.5,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                icon!,
                if (text != null) const SizedBox(width: 8),
              ],
              if (text != null)
                Text(
                  text!,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                    color: textColor,
                    fontFamily: "AirbnbCereal",
                  ),
                ),
            ],
          );

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          disabledBackgroundColor: (backgroundColor ?? AppColors.primary)
              .withOpacity(0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: borderSide ?? BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: content,
      ),
    );
  }
}
