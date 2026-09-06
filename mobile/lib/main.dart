import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/theme_manager.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
      ],
      child: const DhatuApp(),
    ),
  );
}

class DhatuApp extends StatelessWidget {
  const DhatuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, theme, child) {
        return MaterialApp(
          title: 'Dhatu',
          theme: ThemeData(
            primaryColor: theme.primaryColor,
            scaffoldBackgroundColor: theme.backgroundColor,
            useMaterial3: true,
            brightness: theme.isDarkMode ? Brightness.dark : Brightness.light,
            fontFamily: 'Inter',
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
