import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'services/game_state.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  await dotenv.load(fileName: ".env");
  runApp(const LifeArcApp());
}

class C {
  // Backgrounds
  static const bg = Color(0xFFF5F0E8);
  static const surface = Color(0xFFFFFFFF);
  static const elevated = Color(0xFFF0EBE1);

  // Text
  static const ink = Color(0xFF1A1A1A);
  static const inkSub = Color(0xFF6B6B6B);
  static const inkFaint = Color(0xFFAAAAAA);

  // Divider / border
  static const div = Color(0xFFE8E2D8);

  // Primary action button
  static const dark = Color(0xFF1C2333);

  // Stats — exactly as in mockup
  static const health = Color(0xFF4CAF50); // green
  static const happy = Color(0xFFFFA726); // amber
  static const wealth = Color(0xFF66BB6A); // green (slightly lighter)
  static const social = Color(0xFF9575CD); // purple

  // Stat icon backgrounds
  static const healthBg = Color(0xFFE8F5E9);
  static const happyBg = Color(0xFFFFF3E0);
  static const wealthBg = Color(0xFFE8F5E9);
  static const socialBg = Color(0xFFEDE7F6);

  // Outcome
  static const up = Color(0xFF4CAF50);
  static const down = Color(0xFFEF5350);

  // Death screen
  static const deathBg = Color(0xFF111318);
  static const deathCard = Color(0xFF1C1F26);
  static const deathText = Color(0xFFF0F0F0);
  static const deathSub = Color(0xFF8A8A8A);

  // Track
  static const track = Color(0xFFE5E0D5);
}

class LifeArcApp extends StatelessWidget {
  const LifeArcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameState(),
      child: MaterialApp(
        title: 'LifeArc',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: C.bg,
          colorScheme: const ColorScheme.light(
            primary: C.dark,
            surface: C.surface,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
