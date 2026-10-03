import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  runApp(const GreenBinApp());
}

/// Root Application Widget for GreenBin
class GreenBinApp extends StatelessWidget {
  const GreenBinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GreenBin — Community Recycling',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.splash,
      onGenerateInitialRoutes: (initialRoute) {
        return [
          AppRoutes.onGenerateRoute(
            const RouteSettings(name: AppRoutes.splash),
          ),
        ];
      },
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
