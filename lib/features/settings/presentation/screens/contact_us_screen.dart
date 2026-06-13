import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../config/di/injection.dart';
import '../../../../../utils/CommonAppBar.dart';
import '../../../../../utils/CommonExtensions.dart';
import '../../../../../utils/CommonTextField.dart';
import '../../../../../utils/CommonWigdets.dart';
import '../../../../../utils/Common.dart';
import '../../../../../utils/my_common.dart';
import '../../../../../view/employee/controller/role_controller.dart';
import '../bloc/settings_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SettingsBloc>()..add(const FetchAdminDetails()),
      child: const _ContactUsScreenContent(),
    );
  }
}

class _ContactUsScreenContent extends ConsumerStatefulWidget {
  const _ContactUsScreenContent();

  @override
  ConsumerState<_ContactUsScreenContent> createState() => _ContactUsScreenContentState();
}

class _ContactUsScreenContentState extends ConsumerState<_ContactUsScreenContent> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailAddressController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  String adminEmail = "";
  final contactUsKey = GlobalKey<FormState>();

  bool isRequiredVisible = false;

  @override
  void initState() {
    super.initState();
    initialData();
  }

  void initialData() {
    final prefs = getIt<SharedPreferences>();
    nameController.text = "\${prefs.get(firstNameKey) ?? ''} \${prefs.get(lastNameKey) ?? ''}";
    phoneNumberController.text = prefs.get(phoneKey)?.toString() ?? '';
    emailAddressController.text = prefs.get(emailKey)?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is AdminDetailsLoaded) {
          // Assuming admin details API returns email
          adminEmail = state.details;
        } else if (state is SettingsSuccess) {
          messageController.clear();
          showSnackBar('PressHope', 'ContactUS Request sent successfully', Colors.black);
        } else if (state is SettingsError) {
          showSnackBar("Error", state.message, Colors.red);
        }
      },
      child: Scaffold(
        appBar: CommonAppBar(
          elevation: 0,
          hideLeading: false,
          title: Text(
            "\$contactText \${usText.toTitleCase()}",
            style: TextStyle(
              color: Colors.black,
              fontSize: size.width * appBarHeadingFontSize,
              fontWeight: FontWeight.w700,
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
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * numD06),
              child: Form(
                key: contactUsKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.width * numD05),
                    Text(
                      "We’d love to hear from you!",
                      style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD05,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: size.width * numD01),
                    Text(
                      "Our helpful teams are available 24x7 to assist, and answer your questions. All communication with us will remain discreet and secure",
                      style: commonTextStyle(size: size, fontSize: size.width * numD034, color: Colors.black, fontWeight: FontWeight.w300),
                    ),
                    SizedBox(height: size.width * numD06),

                    Text(nameText.toTitleCase(), style: commonTextStyle(size: size, fontSize: size.width * numD033, color: Colors.black, fontWeight: FontWeight.normal)),
                    SizedBox(height: size.width * numD02),
                    CommonTextField(
                      size: size,
                      maxLines: 1,
                      textInputFormatters: null,
                      borderColor: colorTextFieldBorder,
                      controller: nameController,
                      hintText: "Enter name",
                      prefixIcon: null,
                      prefixIconHeight: size.width * numD06,
                      suffixIconIconHeight: 0,
                      suffixIcon: null,
                      hidePassword: false,
                      keyboardType: TextInputType.text,
                      validator: checkRequiredValidator,
                      enableValidations: true,
                      autofocus: false,
                      filled: false,
                      filledColor: colorLightGrey,
                    ),

                    SizedBox(height: size.width * numD06),
                    Text(emailAddressText, style: commonTextStyle(size: size, fontSize: size.width * numD035, color: Colors.black, fontWeight: FontWeight.normal)),
                    SizedBox(height: size.width * numD02),
                    CommonTextField(
                      size: size,
                      maxLines: 1,
                      textInputFormatters: null,
                      borderColor: colorTextFieldBorder,
                      controller: emailAddressController,
                      hintText: emailAddressHintText,
                      prefixIcon: null,
                      prefixIconHeight: size.width * numD06,
                      suffixIconIconHeight: 0,
                      suffixIcon: null,
                      hidePassword: false,
                      autofocus: false,
                      keyboardType: TextInputType.emailAddress,
                      validator: checkEmailValidator,
                      enableValidations: true,
                      filled: false,
                      filledColor: colorLightGrey,
                    ),

                    SizedBox(height: size.width * numD06),
                    Text("\${phoneText.toTitleCase()} \$numberText", style: commonTextStyle(size: size, fontSize: size.width * numD035, color: Colors.black, fontWeight: FontWeight.normal)),
                    SizedBox(height: size.width * numD02),
                    CommonTextField(
                      controller: phoneNumberController,
                      size: size,
                      textInputFormatters: null,
                      borderColor: colorTextFieldBorder,
                      hintText: phoneHintText,
                      prefixIcon: null,
                      prefixIconHeight: size.width * numD06,
                      suffixIconIconHeight: 0,
                      suffixIcon: null,
                      hidePassword: false,
                      autofocus: false,
                      keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: true),
                      validator: checkRequiredValidator,
                      enableValidations: true,
                      filled: false,
                      filledColor: colorLightGrey,
                      maxLines: 1,
                    ),

                    SizedBox(height: size.width * numD06),
                    Text(messageText.toTitleCase(), style: commonTextStyle(size: size, fontSize: size.width * numD035, color: Colors.black, fontWeight: FontWeight.normal)),
                    SizedBox(height: size.width * numD02),
                    TextFormField(
                      maxLines: 5,
                      controller: messageController,
                      cursorColor: colorTextFieldIcon,
                      style: TextStyle(color: Colors.black, fontSize: size.width * numD032, fontFamily: 'AirbnbCereal_W_Md'),
                      onChanged: (v) => setState(() => isRequiredVisible = v.isEmpty),
                      decoration: InputDecoration(
                        counterText: "",
                        fillColor: Colors.white,
                        hintText: "\${enterText.toTitleCase()} \$messageText",
                        hintStyle: TextStyle(color: colorHint, fontSize: size.width * numD035, fontFamily: 'AirbnbCereal_W_Md'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(size.width * 0.03), borderSide: const BorderSide(width: 1, color: colorTextFieldBorder)),
                      ),
                    ),

                    SizedBox(height: size.width * numD15),
                    
                    BlocBuilder<SettingsBloc, SettingsState>(
                      builder: (context, state) {
                        return Container(
                          width: size.width,
                          height: size.width * numD14,
                          padding: EdgeInsets.symmetric(horizontal: size.width * numD08),
                          child: state is SettingsLoading
                            ? const Center(child: CircularProgressIndicator())
                            : commonElevatedButton(
                              "Submit",
                              size,
                              commonTextStyle(size: size, fontSize: size.width * numD035, color: Colors.white, fontWeight: FontWeight.w700),
                              commonButtonStyle(size, ref.watch(userRoleProvider).activeColor),
                              () {
                                if (contactUsKey.currentState!.validate() && messageController.text.isNotEmpty) {
                                  context.read<SettingsBloc>().add(ContactUs({
                                    "full_name": nameController.text,
                                    "email": emailAddressController.text,
                                    "contact_number": phoneNumberController.text,
                                    "content": messageController.text,
                                    "country_code": getIt<SharedPreferences>().getString(countryCodeKey) ?? '',
                                  }));
                                }
                              },
                            ),
                        );
                      },
                    ),

                    SizedBox(height: size.width * numD04),
                    Container(
                      width: size.width,
                      height: size.width * numD14,
                      padding: EdgeInsets.symmetric(horizontal: size.width * numD08),
                      child: commonElevatedButton(
                        emailUsText,
                        size,
                        commonTextStyle(size: size, fontSize: size.width * numD035, color: Colors.white, fontWeight: FontWeight.w700),
                        commonButtonStyle(size, Colors.black),
                        () async {
                          final Uri emailURL = Uri(
                            scheme: 'mailto',
                            path: adminEmail.isNotEmpty ? adminEmail : 'support@presshop.com',
                            queryParameters: {
                              'subject': 'Please contact me',
                              'body': messageController.text.trim(),
                            },
                          );
                          try {
                            if (!await launchUrl(emailURL, mode: LaunchMode.externalApplication)) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open email client")));
                              }
                            }
                          } catch (e) {
                            debugPrint('Error launching email: \$e');
                          }
                        },
                      ),
                    ),
                    SizedBox(height: size.width * numD08),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
