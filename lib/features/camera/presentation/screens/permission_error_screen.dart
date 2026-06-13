import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/constants/app_colors.dart';

class CameraPermissionErrorScreen extends StatelessWidget {
  final Map<Permission, bool> permissionsStatus;

  const CameraPermissionErrorScreen({
    super.key,
    required this.permissionsStatus,
  });

  String get _message {
    final denied = permissionsStatus.entries
        .where((e) => e.value == false)
        .map((e) {
          if (e.key == Permission.camera) return 'Camera';
          if (e.key == Permission.microphone) return 'Microphone';
          if (e.key == Permission.location) return 'Location';
          return e.key.toString();
        })
        .join(', ');
    return '$denied permission${permissionsStatus.length > 1 ? 's are' : ' is'} required to use this feature.';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: size.width * 0.2, color: AppColors.primary),
            SizedBox(height: size.width * 0.06),
            Text(
              'Permission Required',
              style: TextStyle(
                fontSize: size.width * 0.05,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: size.width * 0.04),
            Text(
              _message,
              style: TextStyle(
                fontSize: size.width * 0.035,
                color: Colors.grey[600],
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: size.width * 0.08),
            SizedBox(
              width: double.infinity,
              height: size.width * 0.13,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(size.width * 0.03),
                  ),
                ),
                onPressed: () => openAppSettings(),
                child: Text(
                  'Open Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
