import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:presshop_enterprise/core/constants/app_colors.dart';

const List<Map<String, String>> alertTypesForEmployee = [
  {'type': 'contact-my-family', 'icon': 'assets/markers/gifs/contact-family.gif', 'label': 'Contact my family'},
  {'type': 'need-help', 'icon': 'assets/markers/gifs/need-help.gif', 'label': 'Need help'},
  {'type': 'send-backup', 'icon': 'assets/markers/gifs/send-backup.gif', 'label': 'Send backup'},
  {'type': 'call-police', 'icon': 'assets/markers/gifs/call police.gif', 'label': 'Call police'},
  {'type': 'call-ambulance', 'icon': 'assets/markers/gifs/medicine.webp', 'label': 'Call ambulance'},
  {'type': 'under_threat', 'icon': 'assets/markers/gifs/vandalism.webp', 'label': 'Under threat'},
  {'type': 'being-followed', 'icon': 'assets/markers/gifs/being-followed.gif', 'label': 'Being followed'},
  {'type': 'get_me_out', 'icon': 'assets/markers/gifs/get-me-out.gif', 'label': 'Get me out'},
  {'type': 'im_safe', 'icon': 'assets/markers/gifs/i-am-safe.gif', 'label': "I'm safe"},
  {'type': 'send-support', 'icon': 'assets/markers/gifs/safe.gif', 'label': 'Send support'},
  {'type': 'no-signal', 'icon': 'assets/markers/gifs/no-signal .gif', 'label': 'No signal'},
  {'type': 'low-battery', 'icon': 'assets/markers/gifs/low-battery .gif', 'label': 'Low battery'},
];

class AlertPanelEmployee extends StatefulWidget {
  final VoidCallback onClose;
  final Function(String alertType)? onAlertSelected;

  const AlertPanelEmployee({
    super.key,
    required this.onClose,
    this.onAlertSelected,
  });

  @override
  State<AlertPanelEmployee> createState() => _AlertPanelEmployeeState();
}

class _AlertPanelEmployeeState extends State<AlertPanelEmployee> {
  bool showEmergencyServices = false;

  Future<void> _makeCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) return;
    final clean = phoneNumber.replaceAll(RegExp(r'[^\d+*#]'), '');
    final uri = Uri(scheme: 'tel', path: clean);
    try {
      await launchUrl(uri);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width > 600 ? 650.0 : size.width;

    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            margin: EdgeInsets.only(
              left: w * 0.04,
              bottom: w * 0.042,
            ),
            width: w * 0.70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(w * 0.05),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: w * 0.026,
                  offset: Offset(0, w * 0.01),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(w * 0.05),
              child: SizedBox(
                height: w * 1.23,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.026,
                    vertical: w * 0.015,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        children: [
                          GestureDetector(
                            onTap: showEmergencyServices
                                ? () => setState(() => showEmergencyServices = false)
                                : null,
                            child: Row(
                              children: [
                                if (showEmergencyServices) ...[
                                  Icon(Icons.arrow_back_ios, size: w * 0.04, color: Colors.black),
                                  SizedBox(width: w * 0.02),
                                ],
                                Text(
                                  showEmergencyServices ? 'Emergency services' : 'Share Alerts',
                                  style: TextStyle(
                                    fontSize: w * 0.032,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'AirbnbCereal',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          if (!showEmergencyServices)
                            GestureDetector(
                              onTap: () => setState(() => showEmergencyServices = true),
                              child: Row(
                                children: [
                                  Icon(Icons.phone, size: w * 0.04, color: AppColors.primary),
                                  SizedBox(width: w * 0.02),
                                  Text(
                                    'Emergency services',
                                    style: TextStyle(
                                      fontSize: w * 0.032,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primary,
                                      fontFamily: 'AirbnbCereal',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: w * 0.02),
                      Container(
                        height: w * 0.005,
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: w * 0.02),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(w * 0.005),
                        ),
                      ),
                      if (!showEmergencyServices) ...[
                        Row(
                          children: [
                            Text(
                              'Tap to instantly alert your team',
                              style: TextStyle(
                                color: const Color(0xFF4F4F4F),
                                fontSize: w * 0.028,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'AirbnbCereal',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: w * 0.03),
                        GridView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: alertTypesForEmployee.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: w * 0.012,
                            mainAxisSpacing: w * 0.012,
                          ),
                          itemBuilder: (context, i) {
                            final item = alertTypesForEmployee[i];
                            return GestureDetector(
                              onTap: () {
                                widget.onAlertSelected?.call(item['type']!);
                                widget.onClose();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(w * 0.021),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      item['icon']!,
                                      width: w * 0.09,
                                      height: w * 0.09,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => Icon(
                                        Icons.warning_amber_rounded,
                                        size: w * 0.09,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    SizedBox(height: w * 0.016),
                                    Text(
                                      item['label']!,
                                      style: TextStyle(
                                        fontSize: w * 0.028,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'AirbnbCereal',
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ] else ...[
                        _buildEmergencyServices(w),
                      ],
                      SizedBox(height: w * 0.02),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Arrow pointer
        Positioned(
          left: w * 0.15,
          bottom: w * 0.016,
          child: Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: w * 0.05,
              height: w * 0.05,
              decoration: const BoxDecoration(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyServices(double w) {
    final services = [
      {'category': 'Police', 'number': '999', 'icon': Icons.local_police},
      {'category': 'Ambulance', 'number': '999', 'icon': Icons.local_hospital},
      {'category': 'Fire Brigade', 'number': '999', 'icon': Icons.local_fire_department},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: services.map((s) {
        return Container(
          margin: EdgeInsets.only(bottom: w * 0.02),
          padding: EdgeInsets.all(w * 0.03),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(w * 0.02),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(w * 0.02),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEEE),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  s['icon'] as IconData,
                  color: Colors.red,
                  size: w * 0.05,
                ),
              ),
              SizedBox(width: w * 0.03),
              Expanded(
                child: Text(
                  s['category'] as String,
                  style: TextStyle(
                    fontSize: w * 0.032,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'AirbnbCereal',
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _makeCall(s['number'] as String),
                child: Container(
                  padding: EdgeInsets.all(w * 0.015),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.red, width: 1.5),
                  ),
                  child: Icon(Icons.phone, size: w * 0.035, color: Colors.red),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
