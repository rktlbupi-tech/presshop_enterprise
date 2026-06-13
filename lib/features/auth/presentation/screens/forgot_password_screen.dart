import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../presentation/widgets/app_app_bar.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sent = false;
  bool _loading = false;

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() { _loading = false; _sent = true; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(title: 'Forgot Password', showBack: true),
      body: Padding(
        padding: EdgeInsets.all(24.r),
        child: _sent ? _SuccessView(email: _emailCtrl.text, onBack: () => Navigator.pop(context)) : _FormView(
          formKey: _formKey,
          emailCtrl: _emailCtrl,
          loading: _loading,
          onSubmit: _submit,
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final bool loading;
  final VoidCallback onSubmit;
  const _FormView({required this.formKey, required this.emailCtrl, required this.loading, required this.onSubmit});
  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: 24.h),
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(children: [
            Icon(Icons.lock_reset_outlined, color: AppColors.primary, size: 32.sp),
            SizedBox(width: 12.w),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Reset your password', style: AppTextStyles.labelLarge),
              SizedBox(height: 4.h),
              Text('Enter your registered email and we\'ll send you a password reset link.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
            ])),
          ]),
        ),
        SizedBox(height: 32.h),
        Text('Email Address', style: AppTextStyles.labelMedium),
        SizedBox(height: 8.h),
        TextFormField(
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'you@company.com',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Email is required';
            if (!v.contains('@')) return 'Enter a valid email';
            return null;
          },
        ),
        SizedBox(height: 28.h),
        ElevatedButton(
          onPressed: loading ? null : onSubmit,
          child: loading
              ? SizedBox(height: 20.h, width: 20.w,
                  child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.textOnPrimary))
              : const Text('Send Reset Link'),
        ),
      ]),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String email; final VoidCallback onBack;
  const _SuccessView({required this.email, required this.onBack});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(Icons.mark_email_read_outlined, size: 56.sp, color: AppColors.success),
        ),
        SizedBox(height: 24.h),
        Text('Email Sent!', style: AppTextStyles.h3),
        SizedBox(height: 8.h),
        Text("We've sent a password reset link to\n$email",
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center),
        SizedBox(height: 32.h),
        ElevatedButton(onPressed: onBack, child: const Text('Back to Login')),
        SizedBox(height: 12.h),
        TextButton(
          onPressed: () {},
          child: Text('Didn\'t receive? Resend', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
        ),
      ]),
    );
  }
}
