import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'presentation/screens/splash_screen.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'providers/calculation_provider.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  runApp(const SolarApp());
}

class SolarApp extends StatelessWidget {
  const SolarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalculationProvider(),
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, currentThemeMode, child) {
          return MaterialApp(
            title: 'Solar Installation App',
            debugShowCheckedModeBanner: false,
            themeMode: currentThemeMode,
            theme: ThemeData(
              primarySwatch: Colors.orange,
              primaryColor: Colors.orangeAccent,
              scaffoldBackgroundColor: Colors.grey[50],
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blueGrey,
                elevation: 0,
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.orange,
              primaryColor: Colors.orangeAccent,
              scaffoldBackgroundColor: const Color(0xFF121212),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1E1E1E),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
            // Sabse pehle Splash Screen show hogi
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
