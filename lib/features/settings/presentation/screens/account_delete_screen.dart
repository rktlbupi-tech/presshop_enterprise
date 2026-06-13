import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../config/di/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../../../../config/routes/app_router.dart';
import '../bloc/settings_bloc.dart';

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
  final List<Map<String, String>> purposeData = [
    {"title": "I don't like the app"},
    {"title": "Found a better alternative app"},
    {"title": "I have another Presshop Account"},
    {"title": "No longer using the app"},
    {"title": "App is too complicated or hard to use"},
    {"title": "Technical issues (e.g., bugs, crashes)"},
    {"title": "Privacy or data concerns"},
    {"title": "Other"}
  ];
  Map<String, String> selectReason = {};

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final bool isIpad = size.width > 600;

    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) async {
        if (state is SettingsSuccess) {
          final prefs = getIt<SharedPreferences>();
          await prefs.clear();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
            context.go(AppRoutes.login);
          }
        } else if (state is SettingsError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.black),
          title: Text(
            "Delete account",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: size.width * 0.05,
            ),
          ),
        ),
        body: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            return Padding(
              padding: EdgeInsets.all(size.width * 0.045),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Image.asset(
                      "assets/rabbits/delete_rabbit.png",
                      height: size.width * 0.35,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Text(
                    "Delete Account",
                    style: TextStyle(
                      fontSize: size.width * 0.035,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Text(
                    "Please let us know your reason for deleting the app :- ",
                    style: TextStyle(
                      fontSize: size.width * 0.04,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.grey),
                      padding: isIpad ? EdgeInsets.symmetric(vertical: size.width * 0.012) : EdgeInsets.zero,
                      physics: const BouncingScrollPhysics(),
                      itemCount: purposeData.length,
                      itemBuilder: (ctx, int index) {
                        return ListTile(
                          contentPadding: isIpad ? EdgeInsets.symmetric(vertical: size.width * 0.02) : EdgeInsets.zero,
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
                              activeColor: Colors.pink,
                              checkColor: Colors.white,
                            ),
                          ),
                          title: Text(
                            purposeData[index]['title']!,
                            style: TextStyle(
                              fontSize: size.width * 0.034,
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
                    height: size.height * (isIpad ? 0.1 : 0.08),
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
                    child: state is SettingsLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                            onPressed: () {
                              if (selectReason.isNotEmpty) {
                                showDeleteDialog(size, context.read<SettingsBloc>());
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select reason...")));
                              }
                            },
                            child: Text(
                              'Delete Account',
                              style: TextStyle(
                                fontSize: size.width * (isIpad ? 0.032 : 0.038),
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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
          insetPadding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(size.width * 0.045),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: size.width * 0.04),
                      child: Row(
                        children: [
                          Text(
                            "You will be missed!",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            icon: Icon(Icons.close, color: Colors.black, size: size.width * 0.06),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                      child: const Divider(color: Colors.black, thickness: 0.5),
                    ),
                    SizedBox(height: size.width * 0.02),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(size.width * 0.04),
                              border: Border.all(color: Colors.black),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(size.width * 0.04),
                              child: Image.asset(
                                "assets/rabbits/delete_rabbit2.png",
                                height: size.width * 0.30,
                                width: size.width * 0.35,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: size.width * 0.04),
                          Expanded(
                            child: Text(
                              "Are you sure you want to delete your account? All your data will be lost.",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: size.width * 0.035,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.width * 0.04),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04, vertical: size.width * 0.04),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: size.width * 0.12,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  bloc.add(DeleteAccount(selectReason));
                                },
                                child: Text("Proceed", style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ),
                          SizedBox(width: size.width * 0.04),
                          Expanded(
                            child: SizedBox(
                              height: size.width * 0.12,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                                onPressed: () => Navigator.pop(dialogContext),
                                child: Text("Cancel", style: TextStyle(color: Colors.white)),
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
