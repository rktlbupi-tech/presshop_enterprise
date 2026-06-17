import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/di/injection.dart';
import 'config/routes/app_router.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';

/// Global camera list — populated before runApp so it's ready on first frame.
List<CameraDescription> cameras = [];

/// Global SharedPreferences instance — used by camera screens for lat/lon/address caching.
SharedPreferences? sharedPreferences;

/// Global navigator key — used by camera screens to push routes from async callbacks.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

class PresshopEnterpriseApp extends StatelessWidget {
  const PresshopEnterpriseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        final router = createRouter(getIt());
        return MaterialApp.router(
          title: 'PressHop Enterprise',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: router,
        );
      },
    );
  }
}
