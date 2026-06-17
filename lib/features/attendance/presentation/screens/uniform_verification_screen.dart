import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../main.dart' show cameras;
import '../bloc/attendance_bloc.dart';

enum _Step { capture, verifying, success }

class UniformVerificationScreen extends StatefulWidget {
  const UniformVerificationScreen({super.key});

  @override
  State<UniformVerificationScreen> createState() =>
      _UniformVerificationScreenState();
}

class _UniformVerificationScreenState extends State<UniformVerificationScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  bool _cameraReady = false;
  bool _capturing = false;
  int _activeSlot = 0; // which view is captured next on shutter tap

  // Three capture slots: Front, Side, Full Body
  final List<File?> _photos = [null, null, null];
  static const _slotLabels = ['Front View', 'Side View', 'Full Body'];
  static const _slotIcons = [
    LucideIcons.user,
    LucideIcons.scan_face,
    LucideIcons.scan,
  ];

  _Step _step = _Step.capture;
  int _scanProgressIndex = 0; // 0-4 scanning sub-steps
  static const _scanMessages = [
    'Detecting uniform…',
    'Matching dress code…',
    'Checking completeness…',
    'Finalising…',
    'Verified!',
  ];

  late final AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (cameras.isEmpty) return;
    // Front camera for the uniform self-check; fall back to whatever exists.
    final desc = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    final controller = CameraController(
      desc,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup:
          Platform.isIOS ? ImageFormatGroup.bgra8888 : ImageFormatGroup.jpeg,
    );
    _cameraController = controller;
    try {
      await controller.initialize();
      if (mounted) setState(() => _cameraReady = true);
    } catch (_) {
      if (mounted) setState(() => _cameraReady = false);
    }
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  /// Captures the given view directly from the live in-app preview — no
  /// device camera app is opened.
  Future<void> _captureSlot(int index) async {
    final c = _cameraController;
    if (c == null || !c.value.isInitialized || _capturing) return;
    setState(() => _capturing = true);
    try {
      final XFile shot = await c.takePicture();
      if (!mounted) return;
      setState(() {
        _photos[index] = File(shot.path);
        // Advance to the next empty slot so the next shutter tap fills it.
        final next = _photos.indexWhere((p) => p == null);
        _activeSlot = next == -1 ? index : next;
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<void> _runVerification() async {
    setState(() {
      _step = _Step.verifying;
      _scanProgressIndex = 0;
    });

    for (int i = 1; i <= _scanMessages.length; i++) {
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      setState(() => _scanProgressIndex = i);
    }

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _step = _Step.success);

    // Trigger actual check-in after a brief success display.
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    context.read<AttendanceBloc>().add(const CheckInRequested(0.0, 0.0));
    Navigator.of(context).pop();
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C18),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: switch (_step) {
          _Step.capture => _buildCapturePage(),
          _Step.verifying => _buildVerifyingPage(),
          _Step.success => _buildSuccessPage(),
        },
      ),
    );
  }

  // ── Step 1 : Capture ─────────────────────────────────────────────────────

  Widget _buildCapturePage() {
    return SafeArea(
      key: const ValueKey('capture'),
      child: Column(
        children: [
          // Top bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Uniform Check',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'AirbnbCereal',
                    ),
                  ),
                ),
                SizedBox(width: 48.w),
              ],
            ),
          ),

          // Instruction banner
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.info,
                    color: const Color(0xFF7AABFF),
                    size: 16.sp,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'Take at least one clear photo of your uniform before logging on duty.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11.sp,
                        height: 1.4,
                        fontFamily: 'AirbnbCereal',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Live in-app camera preview inside the guide frame
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 200.w,
                  height: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 80.w),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                      width: 1.5,
                    ),
                  ),
                  child: (_cameraReady &&
                          _cameraController != null &&
                          _cameraController!.value.isInitialized)
                      ? FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width:
                                _cameraController!.value.previewSize?.height ?? 1,
                            height:
                                _cameraController!.value.previewSize?.width ?? 1,
                            child: CameraPreview(_cameraController!),
                          ),
                        )
                      : Center(
                          child: Icon(
                            LucideIcons.user_round,
                            size: 130.sp,
                            color: Colors.white.withValues(alpha: 0.10),
                          ),
                        ),
                ),
                // Corner brackets for framing effect
                ..._buildCornerBrackets(),
                // Center label — shows the view being captured next
                Positioned(
                  bottom: 20.h,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F5BF6).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      !_photos.contains(null)
                          ? 'All views captured'
                          : 'Capturing: ${_slotLabels[_activeSlot]}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontFamily: 'AirbnbCereal',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 14.h),

          // Shutter — captures the active view from the live preview in-place
          GestureDetector(
            onTap: (_cameraReady && _photos.contains(null))
                ? () => _captureSlot(_activeSlot)
                : null,
            child: Container(
              width: 66.w,
              height: 66.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: _capturing
                  ? Padding(
                      padding: EdgeInsets.all(18.w),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(LucideIcons.camera, color: Colors.white, size: 26.sp),
            ),
          ),

          SizedBox(height: 16.h),

          // Capture slot buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(children: List.generate(3, (i) => _buildSlotButton(i))),
          ),

          SizedBox(height: 24.h),

          // Verify CTA
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: GestureDetector(
              onTap: _runVerification,
              child: Container(
                width: double.infinity,
                height: 52.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E66FF), Color(0xFF1540C0)],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.shield_check,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'Verify & Log On Duty',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'AirbnbCereal',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 28.h),
        ],
      ),
    );
  }

  Widget _buildSlotButton(int index) {
    final captured = _photos[index] != null;
    return Expanded(
      child: GestureDetector(
        onTap: () => _captureSlot(index),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 5.w),
          height: 88.h,
          decoration: BoxDecoration(
            color: captured
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: captured
                  ? const Color(0xFF4CAF50)
                  : Colors.white.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: captured
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(13.r),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(_photos[index]!, fit: BoxFit.cover),
                      Positioned(
                        top: 4.h,
                        right: 4.w,
                        child: Container(
                          width: 18.w,
                          height: 18.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 11.sp,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 4.h),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.65),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Text(
                            _slotLabels[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8.5.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'AirbnbCereal',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_slotIcons[index], color: Colors.white54, size: 22.sp),
                    SizedBox(height: 6.h),
                    Text(
                      _slotLabels[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 9.sp,
                        fontFamily: 'AirbnbCereal',
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Icon(
                      LucideIcons.camera,
                      color: Colors.white30,
                      size: 12.sp,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  List<Widget> _buildCornerBrackets() {
    const color = Color(0xFF2E66FF);
    const size = 22.0;
    const thickness = 2.5;
    return [
      Positioned(
        top: 0,
        left: 80,
        child: _corner(color, size, thickness, top: true, left: true),
      ),
      Positioned(
        top: 0,
        right: 80,
        child: _corner(color, size, thickness, top: true, left: false),
      ),
      Positioned(
        bottom: 0,
        left: 80,
        child: _corner(color, size, thickness, top: false, left: true),
      ),
      Positioned(
        bottom: 0,
        right: 80,
        child: _corner(color, size, thickness, top: false, left: false),
      ),
    ];
  }

  Widget _corner(
    Color color,
    double size,
    double thickness, {
    required bool top,
    required bool left,
  }) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CornerPainter(
        color: color,
        thickness: thickness,
        top: top,
        left: left,
      ),
    );
  }

  // ── Step 2 : Verifying ───────────────────────────────────────────────────

  Widget _buildVerifyingPage() {
    final progress = _scanProgressIndex / _scanMessages.length;
    final currentMsg = _scanProgressIndex < _scanMessages.length
        ? _scanMessages[_scanProgressIndex]
        : _scanMessages.last;

    return Center(
      key: const ValueKey('verifying'),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Rotating scan ring
            SizedBox(
              width: 120.w,
              height: 120.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background ring
                  SizedBox(
                    width: 120.w,
                    height: 120.w,
                    child: CircularProgressIndicator(
                      value: 1,
                      strokeWidth: 3,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  // Animated progress ring
                  SizedBox(
                    width: 120.w,
                    height: 120.w,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      builder: (_, val, child) => CircularProgressIndicator(
                        value: val,
                        strokeWidth: 4,
                        strokeCap: StrokeCap.round,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF2E66FF),
                        ),
                      ),
                    ),
                  ),
                  // Center icon
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF12163A),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF2E66FF).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: RotationTransition(
                      turns: _rotateController,
                      child: Icon(
                        LucideIcons.scan_face,
                        color: const Color(0xFF4A8EFF),
                        size: 32.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            Text(
              'Scanning Uniform',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                fontFamily: 'AirbnbCereal',
              ),
            ),
            SizedBox(height: 8.h),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                currentMsg,
                key: ValueKey(currentMsg),
                style: TextStyle(
                  color: const Color(0xFF7AABFF),
                  fontSize: 13.sp,
                  fontFamily: 'AirbnbCereal',
                ),
              ),
            ),

            SizedBox(height: 40.h),

            // Scan step indicators
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(_scanMessages.length - 1, (i) {
                final done = _scanProgressIndex > i;
                final active = _scanProgressIndex == i + 1;
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.h),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 20.w,
                        height: 20.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done
                              ? const Color(0xFF4CAF50)
                              : active
                              ? const Color(0xFF2E66FF)
                              : Colors.white.withValues(alpha: 0.08),
                          border: Border.all(
                            color: done
                                ? const Color(0xFF4CAF50)
                                : active
                                ? const Color(0xFF2E66FF)
                                : Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: done
                            ? Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 11.sp,
                              )
                            : active
                            ? Padding(
                                padding: const EdgeInsets.all(4),
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        _scanMessages[i],
                        style: TextStyle(
                          color: done
                              ? Colors.white
                              : active
                              ? Colors.white
                              : Colors.white30,
                          fontSize: 12.sp,
                          fontWeight: done || active
                              ? FontWeight.w600
                              : FontWeight.w400,
                          fontFamily: 'AirbnbCereal',
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 3 : Success ─────────────────────────────────────────────────────

  Widget _buildSuccessPage() {
    return Center(
      key: const ValueKey('success'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Success ring
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.5, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (_, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Container(
              width: 110.w,
              height: 110.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0D3D1E),
                border: Border.all(color: const Color(0xFF4CAF50), width: 3),
              ),
              child: Icon(
                Icons.check_rounded,
                color: const Color(0xFF4CAF50),
                size: 52.sp,
              ),
            ),
          ),

          SizedBox(height: 28.h),

          Text(
            'Uniform Verified!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              fontFamily: 'AirbnbCereal',
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Dress code confirmed. Logging you on duty…',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 13.sp,
              fontFamily: 'AirbnbCereal',
            ),
          ),

          SizedBox(height: 36.h),

          // Captured photo row
          SizedBox(
            height: 64.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              shrinkWrap: true,
              itemCount: _photos.where((f) => f != null).length,
              separatorBuilder: (_, i) => SizedBox(width: 8.w),
              itemBuilder: (_, i) {
                final nonNull = _photos.where((f) => f != null).toList();
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.file(
                    nonNull[i]!,
                    width: 64.w,
                    height: 64.h,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Corner bracket custom painter ────────────────────────────────────────────

class _CornerPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final bool top;
  final bool left;

  const _CornerPainter({
    required this.color,
    required this.thickness,
    required this.top,
    required this.left,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final x = left ? 0.0 : size.width;
    final y = top ? 0.0 : size.height;
    final dx = left ? size.width : -size.width;
    final dy = top ? size.height : -size.height;

    canvas.drawLine(Offset(x, y), Offset(x + dx, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) =>
      old.color != color || old.thickness != thickness;
}
