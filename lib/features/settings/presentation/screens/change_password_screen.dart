import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../config/di/injection.dart';
import '../../../../../utils/CommonAppBar.dart';
import '../../../../../utils/CommonTextField.dart';
import '../../../../../utils/CommonWigdets.dart';
import '../../../../../utils/Common.dart';
import '../../../../../view/employee/controller/role_controller.dart';
import '../bloc/settings_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SettingsBloc>(),
      child: const _ChangePasswordScreenContent(),
    );
  }
}

class _ChangePasswordScreenContent extends ConsumerStatefulWidget {
  const _ChangePasswordScreenContent();

  @override
  ConsumerState<_ChangePasswordScreenContent> createState() => _ChangePasswordScreenContentState();
}

class _ChangePasswordScreenContentState extends ConsumerState<_ChangePasswordScreenContent> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();
  
  bool hideNewPassword = true,
      showLowercase = false,
      showSpecialcase = false,
      showUppercase = false,
      showMincase = false,
      showNumber = false;
  bool hideCurrentPassword = true;
  bool hideConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is SettingsSuccess) {
          _newPasswordController.clear();
          _currentPasswordController.clear();
          _confirmNewPasswordController.clear();
          Navigator.pop(context);
          showSnackBar("Password updated!", "Your password has been successfully changed!", colorOnlineGreen);
        } else if (state is SettingsError) {
          showSnackBar("Error", state.message, Colors.red);
        }
      },
      child: Scaffold(
        appBar: CommonAppBar(
          elevation: 0,
          hideLeading: false,
          title: Text(
            changePasswordText,
            style: TextStyle(
              color: Colors.black,
              fontSize: size.width * appBarHeadingFontSize,
            ),
          ),
          centerTitle: false,
          titleSpacing: 0,
          size: size,
          showActions: true,
          leadingFxn: () => Navigator.pop(context),
          actionWidget: const [],
        ),
        body: SafeArea(
          child: Form(
            key: formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * numD05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: size.width * numD11, right: size.width * numD1),
                    child: Text(
                      changePasswordSubTitleText,
                      style: TextStyle(color: Colors.black, fontSize: size.width * numD033),
                    ),
                  ),
                  SizedBox(height: size.width * numD06),
                  Expanded(
                    child: ListView(
                      children: [
                        Text(currentPasswordText, style: commonTextStyle(size: size, fontSize: size.width * numD035, color: Colors.black, fontWeight: FontWeight.w400)),
                        SizedBox(height: size.width * numD02),
                        CommonTextField(
                          size: size,
                          controller: _currentPasswordController,
                          hintText: enterCurrentPasswordHintText,
                          textInputFormatters: null,
                          prefixIcon: const ImageIcon(AssetImage("\${iconsPath}ic_key.png")),
                          prefixIconHeight: size.width * numD08,
                          suffixIconIconHeight: size.width * numD08,
                          suffixIcon: InkWell(
                            onTap: () => setState(() => hideCurrentPassword = !hideCurrentPassword),
                            child: ImageIcon(
                              hideCurrentPassword ? const AssetImage("\${iconsPath}ic_show_eye.png") : const AssetImage("\${iconsPath}ic_block_eye.png"),
                              color: hideCurrentPassword ? colorTextFieldIcon : colorHint,
                            ),
                          ),
                          hidePassword: hideCurrentPassword,
                          keyboardType: TextInputType.text,
                          validator: checkPasswordValidator,
                          enableValidations: true,
                          filled: false,
                          filledColor: Colors.transparent,
                          maxLines: 1,
                          borderColor: colorTextFieldBorder,
                          autofocus: false,
                        ),
                        SizedBox(height: size.width * numD06),
                        
                        Text(newPasswordText, style: commonTextStyle(size: size, fontSize: size.width * numD035, color: Colors.black, fontWeight: FontWeight.w400)),
                        SizedBox(height: size.width * numD02),
                        CommonTextField(
                          size: size,
                          maxLines: 1,
                          borderColor: colorTextFieldBorder,
                          controller: _newPasswordController,
                          hintText: enterNewPasswordHint,
                          textInputFormatters: null,
                          prefixIcon: const ImageIcon(AssetImage("\${iconsPath}ic_key.png")),
                          prefixIconHeight: size.width * numD08,
                          suffixIconIconHeight: size.width * numD08,
                          onChanged: (text) {
                            setState(() {
                              showMincase = text.length >= 8;
                              showUppercase = RegExp(r'[A-Z]').hasMatch(text);
                              showLowercase = RegExp(r'[a-z]').hasMatch(text);
                              showNumber = RegExp(r'[0-9]').hasMatch(text);
                              showSpecialcase = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(text);
                            });
                          },
                          suffixIcon: InkWell(
                            onTap: () => setState(() => hideNewPassword = !hideNewPassword),
                            child: ImageIcon(
                              hideNewPassword ? const AssetImage("\${iconsPath}ic_show_eye.png") : const AssetImage("\${iconsPath}ic_block_eye.png"),
                              color: hideNewPassword ? colorTextFieldIcon : colorHint,
                            ),
                          ),
                          hidePassword: hideNewPassword,
                          keyboardType: TextInputType.text,
                          errorMaxLines: 2,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return requiredText;
                            if (_currentPasswordController.text == value) return "Please choose a new password.";
                            if (!showNumber || !showSpecialcase || !showLowercase || !showUppercase || !showMincase) return '';
                            return null;
                          },
                          enableValidations: true,
                          filled: false,
                          filledColor: Colors.transparent,
                          autofocus: false,
                        ),
                        SizedBox(height: size.width * numD02),
                        // Requirements checklist can be added here
                        SizedBox(height: size.width * numD06),

                        Text(confirmNewPasswordText, style: commonTextStyle(size: size, fontSize: size.width * numD035, color: Colors.black, fontWeight: FontWeight.w400)),
                        SizedBox(height: size.width * numD02),
                        CommonTextField(
                          size: size,
                          maxLines: 1,
                          borderColor: colorTextFieldBorder,
                          controller: _confirmNewPasswordController,
                          hintText: confirmNewPasswordText,
                          textInputFormatters: null,
                          prefixIcon: const ImageIcon(AssetImage("\${iconsPath}ic_key.png")),
                          prefixIconHeight: size.width * numD08,
                          suffixIconIconHeight: size.width * numD08,
                          suffixIcon: InkWell(
                            onTap: () => setState(() => hideConfirmPassword = !hideConfirmPassword),
                            child: ImageIcon(
                              hideConfirmPassword ? const AssetImage("\${iconsPath}ic_show_eye.png") : const AssetImage("\${iconsPath}ic_block_eye.png"),
                              color: hideConfirmPassword ? colorTextFieldIcon : colorHint,
                            ),
                          ),
                          hidePassword: hideConfirmPassword,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value!.trim().isEmpty) return requiredText;
                            if (_newPasswordController.text.trim() != value) return confirmPasswordErrorText;
                            return null;
                          },
                          enableValidations: true,
                          filled: false,
                          filledColor: Colors.transparent,
                          autofocus: false,
                        ),

                        SizedBox(height: size.width * numD30),
                        
                        BlocBuilder<SettingsBloc, SettingsState>(
                          builder: (context, state) {
                            return Container(
                              width: size.width,
                              height: size.width * numD13,
                              margin: EdgeInsets.symmetric(horizontal: size.width * numD04),
                              child: state is SettingsLoading 
                                  ? const Center(child: CircularProgressIndicator())
                                  : commonElevatedButton(
                                      submitText,
                                      size,
                                      commonTextStyle(size: size, fontSize: size.width * numD035, color: Colors.white, fontWeight: FontWeight.w700),
                                      commonButtonStyle(size, ref.watch(userRoleProvider).activeColor),
                                      () {
                                        if (formKey.currentState!.validate()) {
                                          context.read<SettingsBloc>().add(ChangePassword({
                                            "old_password": _currentPasswordController.text.trim(),
                                            "new_password": _newPasswordController.text.trim(),
                                          }));
                                        }
                                      },
                                    ),
                            );
                          },
                        ),
                        SizedBox(height: size.width * numD03),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
