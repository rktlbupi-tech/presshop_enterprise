import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Port of the old EmployeeCameraScreen look — a full-screen viewfinder with
/// a capture button, gallery/flip controls and a photo/video mode toggle.
/// (The actual camera plugin is not wired in this build; this is the UI shell.)
class EmployeeCameraScreen extends StatefulWidget {
  const EmployeeCameraScreen({super.key});

  @override
  State<EmployeeCameraScreen> createState() => _EmployeeCameraScreenState();
}

class _EmployeeCameraScreenState extends State<EmployeeCameraScreen> {
  bool _videoMode = false;
  bool _flashOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Viewfinder placeholder.
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1B1B1B), Color(0xFF000000)],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.photo_camera_outlined,
                        size: 64.sp, color: Colors.white24),
                    SizedBox(height: 12.h),
                    Text('Camera preview',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: Colors.white38)),
                  ],
                ),
              ),
            ),
          ),

          // Top controls.
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circleBtn(
                    icon: _flashOn ? Icons.flash_on : Icons.flash_off,
                    onTap: () => setState(() => _flashOn = !_flashOn),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text('Capture evidence',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: Colors.white)),
                  ),
                  _circleBtn(icon: Icons.settings_outlined, onTap: () {}),
                ],
              ),
            ),
          ),

          // Bottom controls.
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(bottom: 24.h, top: 12.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Photo / Video toggle.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _modeChip('Photo', !_videoMode,
                            () => setState(() => _videoMode = false)),
                        SizedBox(width: 12.w),
                        _modeChip('Video', _videoMode,
                            () => setState(() => _videoMode = true)),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _circleBtn(
                            icon: Icons.photo_library_outlined, onTap: () {}),
                        // Shutter.
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 78.w,
                            height: 78.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 4),
                            ),
                            child: Center(
                              child: Container(
                                width: 60.w,
                                height: 60.w,
                                decoration: BoxDecoration(
                                  color: _videoMode
                                      ? AppColors.error
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                        _circleBtn(
                            icon: Icons.flip_camera_ios_outlined, onTap: () {}),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: const BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22.sp),
      ),
    );
  }

  Widget _modeChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: selected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
