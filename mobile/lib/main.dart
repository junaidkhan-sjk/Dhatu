import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/localization_service.dart';
import 'services/sync_engine.dart';
import 'services/audio_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Core Services
  await LocalizationService().init();
  await AudioService().init();
  await SyncEngine().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: LocalizationService()),
        ChangeNotifierProvider.value(value: SyncEngine()),
      ],
      child: const DhatuApp(),
    ),
  );
}

class DhatuApp extends StatelessWidget {
  const DhatuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dhatu · धातु',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B1120),
        primaryColor: const Color(0xFF0F6B6B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0F6B6B),
          secondary: Color(0xFFE0A526),
          surface: Color(0xFF1E293B),
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
