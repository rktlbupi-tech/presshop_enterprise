import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'config/di/injection.dart';
import 'config/routes/app_router.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'package:presshop_enterprise/l10n/app_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:presshop_enterprise/features/notifications/data/services/enterprise_fcm_service.dart';
import 'dart:io';
import 'package:presshop_enterprise/features/notifications/data/services/local_notification_service.dart';
import 'package:force_update_helper/force_update_helper.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:presshop_enterprise/features/splash/data/repositories/force_update_repository.dart';
import 'package:presshop_enterprise/features/camera/utils/camera_constants.dart';

/// Global camera list — populated before runApp so it's ready on first frame.
List<CameraDescription> cameras = [];

/// Global SharedPreferences instance — used by camera screens for lat/lon/address caching.
SharedPreferences? sharedPreferences;

/// Global navigator key — used by camera screens to push routes from async callbacks.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await LocalNotificationService.instance.setup();
  EnterpriseFcmService.setupTokenRefreshListener();

  // ── Environment ───────────────────────────────────────────
  AppConfig.init(AppFlavor.dev);

  // ── System UI ─────────────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── Dependencies ──────────────────────────────────────────
  await setupDependencies();

  // ── Camera & Prefs ────────────────────────────────────────
  try {
    cameras = await availableCameras();
  } catch (_) {
    cameras = [];
  }
  sharedPreferences = await SharedPreferences.getInstance();

  runApp(const PresshopEnterpriseApp());
}

class PresshopEnterpriseApp extends StatefulWidget {
  const PresshopEnterpriseApp({super.key});

  @override
  State<PresshopEnterpriseApp> createState() => _PresshopEnterpriseAppState();
}

class _PresshopEnterpriseAppState extends State<PresshopEnterpriseApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter(getIt());
  }

  void _openStore() async {
    final url = Platform.isAndroid
        ? 'https://play.google.com/store/apps/details?id=com.presshop.enterprise'
        : 'https://apps.apple.com/app/id6744651614';

    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Could not open store: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Enterprise',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: _router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) {
            return ForceUpdateWidget(
              navigatorKey: navigatorKey,
              forceUpdateClient: ForceUpdateClient(
                fetchRequiredVersion: () async {
                  try {
                    final force = await ForceUpdateRepository.checkForceUpdate();
                    if (force) return "999.0.0";
                    final info = await PackageInfo.fromPlatform();
                    return info.version;
                  } catch (e) {
                    debugPrint("Force update check failed: $e");
                    final info = await PackageInfo.fromPlatform();
                    return info.version;
                  }
                },
                iosAppStoreId: '6744651614',
              ),
              allowCancel: false,
              showForceUpdateAlert: (context, allowCancel) {
                final size = MediaQuery.of(context).size;
                final dialogContext = navigatorKey.currentContext ?? context;
                return showDialog(
                  context: dialogContext,
                  barrierDismissible: allowCancel,
                  builder: (context) {
                    return WillPopScope(
                      onWillPop: () async => allowCancel,
                      child: AlertDialog(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        contentPadding: EdgeInsets.zero,
                        insetPadding: EdgeInsets.symmetric(
                          horizontal: size.width * numD04,
                        ),
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
                                    padding: EdgeInsets.only(
                                      left: size.width * numD04,
                                      top: size.width * numD02,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          "Update Required",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: size.width * numD04,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Spacer(),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: size.width * numD04,
                                    ),
                                    child: const Divider(
                                      color: Colors.black,
                                      thickness: 0.5,
                                    ),
                                  ),
                                  SizedBox(height: size.width * numD02),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: size.width * numD04,
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(size.width * numD04),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(size.width * numD04),
                                            child: Image.asset(
                                              "assets/rabbits/update_rabbit.png",
                                              height: size.width * numD25,
                                              width: size.width * numD35,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: size.width * numD04),
                                        Expanded(
                                          child: Text(
                                            "A newer version of PressHop is available. Please update the app to continue using all features smoothly.",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: size.width * numD035,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: size.width * numD08),
                                  SizedBox(
                                    height: size.width * 0.12,
                                    width: size.width * numD35,
                                    child: commonElevatedButton(
                                      "Update Now",
                                      size,
                                      commonButtonTextStyle(size),
                                      commonButtonStyle(size, colorEmployeeGreen1),
                                      _openStore,
                                    ),
                                  ),
                                  SizedBox(height: size.width * numD05),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
              showStoreListing: (Uri storeUrl) async {},
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
