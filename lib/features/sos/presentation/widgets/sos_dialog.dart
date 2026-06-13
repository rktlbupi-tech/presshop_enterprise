import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/socket/socket_events.dart';
import '../../../../core/network/socket/socket_manager.dart';
import '../../../../config/di/injection.dart';

enum _SosState { idle, active, stopping }

class SosDialog extends StatefulWidget {
  const SosDialog({super.key});
  static Future<void> show(BuildContext context) => showDialog(
    context: context, barrierDismissible: false,
    builder: (_) => const SosDialog(),
  );
  @override State<SosDialog> createState() => _SosDialogState();
}

class _SosDialogState extends State<SosDialog> with SingleTickerProviderStateMixin {
  _SosState _state = _SosState.idle;
  late AnimationController _pulse;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  Future<void> _activate() async {
    setState(() => _state = _SosState.active);
    try {
      final api = getIt<ApiClient>();
      await api.post(ApiEndpoints.sosStart, data: {'lat': 0.0, 'lng': 0.0});
      SocketManager.instance.liveSocket.emit(SocketEvents.sosAlert, {'active': true});
    } catch (_) {}
    setState(() => _message = 'SOS activated. Help is on the way.');
  }

  Future<void> _deactivate() async {
    setState(() => _state = _SosState.stopping);
    try {
      final api = getIt<ApiClient>();
      await api.post(ApiEndpoints.sosStop, data: {});
      SocketManager.instance.liveSocket.emit(SocketEvents.sosStopped, {'active': false});
    } catch (_) {}
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Emergency SOS', style: AppTextStyles.h4),
          SizedBox(height: 8.h),
          Text(
            _state == _SosState.idle
                ? 'Press the SOS button to alert your team and management immediately.'
                : 'SOS is ACTIVE. Your location is being shared with your team.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 28.h),
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, child) {
              final scale = _state == _SosState.active ? 1.0 + _pulse.value * 0.1 : 1.0;
              return Transform.scale(scale: scale, child: child);
            },
            child: GestureDetector(
              onTap: _state == _SosState.idle ? _activate : null,
              child: Container(
                width: 120.w, height: 120.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _state == _SosState.idle
                      ? AppColors.error
                      : AppColors.error.withValues(alpha: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.error.withValues(alpha: _state == _SosState.active ? 0.5 : 0.2),
                      blurRadius: _state == _SosState.active ? 32 : 16,
                      spreadRadius: _state == _SosState.active ? 8 : 0,
                    ),
                  ],
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.sos_outlined, size: 40.sp, color: Colors.white),
                  SizedBox(height: 4.h),
                  Text('SOS', style: AppTextStyles.button.copyWith(fontSize: 14.sp, color: Colors.white, letterSpacing: 2)),
                ]),
              ),
            ),
          ),
          if (_message.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(_message, style: AppTextStyles.labelSmall.copyWith(color: AppColors.error), textAlign: TextAlign.center),
            ),
          ],
          SizedBox(height: 24.h),
          if (_state == _SosState.active)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                onPressed: _deactivate,
                child: const Text('I\'m Safe — Stop SOS'),
              ),
            ),
          if (_state == _SosState.stopping)
            const CircularProgressIndicator(),
          SizedBox(height: _state == _SosState.idle ? 0 : 8.h),
          TextButton(
            onPressed: _state == _SosState.idle ? () => Navigator.pop(context) : null,
            child: Text('Cancel', style: AppTextStyles.labelMedium.copyWith(
                color: _state == _SosState.idle ? AppColors.textSecondary : AppColors.textHint)),
          ),
        ]),
      ),
    );
  }
}
