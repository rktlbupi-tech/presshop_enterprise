import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../config/di/injection.dart';
import '../../../../../utils/CommonAppBar.dart';
import '../../../../../utils/CommonExtensions.dart';
import '../../../../../utils/CommonWigdets.dart';
import '../../../../../utils/Common.dart';
import '../../../../../view/authentication/LoginScreen.dart';
import '../bloc/settings_bloc.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../main.dart'; // Ensure googleSignIn is available

class AccountDeleteScreen extends StatelessWidget {
  const AccountDeleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SettingsBloc>(),
      child: const _AccountDeleteScreenContent(),
    );
  }
}

class _AccountDeleteScreenContent extends StatefulWidget {
  const _AccountDeleteScreenContent();

  @override
  State<_AccountDeleteScreenContent> createState() => _AccountDeleteScreenContentState();
}

class _AccountDeleteScreenContentState extends State<_AccountDeleteScreenContent> {
  List<dynamic> purposeData = [...purposeForDeleteAccount];
  Map<String, String> selectReason = {};

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) async {
        if (state is SettingsSuccess) {
          await FirebaseAnalytics.instance.logEvent(
            name: 'account deleted successfully',
            parameters: {
              'error': 'Account deleted successfully',
              'timestamp': DateTime.now().toIso8601String(),
            },
          );
          final prefs = getIt<SharedPreferences>();
          await prefs.clear();
          googleSignIn.signOut();
          showToast(state.message);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        } else if (state is SettingsError) {
          showSnackBar("Error", state.message, Colors.red);
        }
      },
      child: Scaffold(
        appBar: CommonAppBar(
          elevation: 0,
          hideLeading: false,
          title: Text(
            "Delete account",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
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
        body: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            return Padding(
              padding: EdgeInsets.all(size.width * numD045),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Image.asset(
                      "assets/rabbits/delete_rabbit.png",
                      height: size.width * numD35,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: size.height * numD02),
                  Text(
                    deleteAccountText,
                    style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD035,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: size.height * numD02),
                  Text(
                    "Please let us know your reason for deleting the app :- ",
                    style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD04,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: size.height * numD01),
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.grey),
                      padding: isIpad ? EdgeInsets.symmetric(vertical: size.width * numD012) : EdgeInsets.zero,
                      physics: const BouncingScrollPhysics(),
                      itemCount: purposeData.length,
                      itemBuilder: (ctx, int index) {
                        return ListTile(
                          contentPadding: isIpad ? EdgeInsets.symmetric(vertical: size.width * numD02) : EdgeInsets.zero,
                          leading: Transform.scale(
                            scale: isIpad ? 1.8 : 1,
                            child: Checkbox(
                              visualDensity: VisualDensity.compact,
                              value: selectReason == purposeData[index],
                              onChanged: (value) {
                                setState(() {
                                  selectReason = purposeData[index];
                                });
                              },
                              activeColor: colorThemePink,
                              checkColor: Colors.white,
                            ),
                          ),
                          title: Text(
                            purposeData[index]['title'],
                            style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD034,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: size.height * (isIpad ? numD1 : numD08),
                    padding: EdgeInsets.symmetric(vertical: size.height * numD015),
                    child: state is SettingsLoading
                        ? const Center(child: CircularProgressIndicator())
                        : commonElevatedButton(
                            'Delete Account',
                            size,
                            commonTextStyle(
                              size: size,
                              fontSize: size.width * (isIpad ? numD032 : numD038),
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                            commonButtonStyle(size, colorThemePink),
                            () {
                              if (selectReason.isNotEmpty) {
                                showDeleteDialog(size, context.read<SettingsBloc>());
                              } else {
                                showToast("Please select reason...");
                              }
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void showDeleteDialog(Size size, SettingsBloc bloc) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          contentPadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.symmetric(horizontal: size.width * numD04),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(size.width * numD045),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: size.width * numD04),
                      child: Row(
                        children: [
                          Text(
                            youWIllBeMissedText,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * numD05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            icon: Icon(Icons.close, color: Colors.black, size: size.width * numD06),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: size.width * numD04),
                      child: const Divider(color: Colors.black, thickness: 0.5),
                    ),
                    SizedBox(height: size.width * numD02),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: size.width * numD04),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(size.width * numD04),
                              border: Border.all(color: Colors.black),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(size.width * numD04),
                              child: Image.asset(
                                "assets/rabbits/delete_rabbit2.png",
                                height: size.width * numD30,
                                width: size.width * numD35,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: size.width * numD04),
                          Expanded(
                            child: Text(
                              deleteAccountPopupMessageText,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: size.width * numD035,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.width * numD04),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: size.width * numD04, vertical: size.width * numD04),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: size.width * numD12,
                              child: commonElevatedButton(
                                "Proceed",
                                size,
                                commonButtonTextStyle(size),
                                commonButtonStyle(size, Colors.black),
                                () {
                                  Navigator.pop(dialogContext);
                                  bloc.add(DeleteAccount(selectReason));
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: size.width * numD04),
                          Expanded(
                            child: SizedBox(
                              height: size.width * numD12,
                              child: commonElevatedButton(
                                "Cancel",
                                size,
                                commonButtonTextStyle(size),
                                commonButtonStyle(size, colorThemePink),
                                () => Navigator.pop(dialogContext),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
