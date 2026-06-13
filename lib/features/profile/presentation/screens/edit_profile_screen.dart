import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../presentation/widgets/app_app_bar.dart';
import '../../../../presentation/widgets/loading_widget.dart';
import '../../domain/entities/profile_entity.dart';
import '../bloc/profile_bloc.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileEntity profile;
  const EditProfileScreen({super.key, required this.profile});
  @override State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _firstNameCtrl = TextEditingController(text: widget.profile.firstName);
  late final _lastNameCtrl = TextEditingController(text: widget.profile.lastName);
  late final _phoneCtrl = TextEditingController(text: widget.profile.phone ?? '');
  late final _addressCtrl = TextEditingController(text: widget.profile.address ?? '');

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<ProfileBloc>().add(UpdateProfile({
      'firstName': _firstNameCtrl.text.trim(),
      'lastName': _lastNameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(title: 'Edit Profile', showBack: true),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: AppColors.success,
            ));
            Navigator.pop(context);
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message), backgroundColor: AppColors.error,
            ));
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) return const LoadingWidget();
          return SingleChildScrollView(
            padding: EdgeInsets.all(20.r),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(
                  child: Stack(children: [
                    CircleAvatar(
                      radius: 48.r,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        widget.profile.firstName.isNotEmpty ? widget.profile.firstName[0].toUpperCase() : '?',
                        style: AppTextStyles.h1.copyWith(color: AppColors.primary),
                      ),
                    ),
                    Positioned(bottom: 0, right: 0, child: Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: Icon(Icons.camera_alt_outlined, size: 16.sp, color: Colors.white),
                    )),
                  ]),
                ),
                SizedBox(height: 28.h),
                _Field(controller: _firstNameCtrl, label: 'First Name', icon: Icons.person_outline,
                    validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null),
                SizedBox(height: 16.h),
                _Field(controller: _lastNameCtrl, label: 'Last Name', icon: Icons.person_outline,
                    validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null),
                SizedBox(height: 16.h),
                _Field(controller: _phoneCtrl, label: 'Phone', icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone),
                SizedBox(height: 16.h),
                _Field(controller: _addressCtrl, label: 'Address', icon: Icons.location_on_outlined, maxLines: 2),
                SizedBox(height: 8.h),
                // Read-only fields
                _ReadonlyField(label: 'Email', value: widget.profile.email, icon: Icons.email_outlined),
                SizedBox(height: 8.h),
                if (widget.profile.designation != null)
                  _ReadonlyField(label: 'Designation', value: widget.profile.designation!, icon: Icons.work_outline),
                SizedBox(height: 32.h),
                ElevatedButton(
                  onPressed: () => _submit(context),
                  child: const Text('Save Changes'),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  const _Field({required this.controller, required this.label, required this.icon,
    this.keyboardType = TextInputType.text, this.validator, this.maxLines = 1});
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller, keyboardType: keyboardType,
    maxLines: maxLines, validator: validator,
    decoration: InputDecoration(
      labelText: label, prefixIcon: Icon(icon, size: 20.sp, color: AppColors.primary),
    ),
  );
}

class _ReadonlyField extends StatelessWidget {
  final String label, value; final IconData icon;
  const _ReadonlyField({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Opacity(
    opacity: 0.6,
    child: TextFormField(
      initialValue: value, readOnly: true,
      decoration: InputDecoration(
        labelText: label, prefixIcon: Icon(icon, size: 20.sp, color: AppColors.primary),
        filled: true, fillColor: AppColors.background,
      ),
    ),
  );
}
