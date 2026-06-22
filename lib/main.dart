import 'package:currency_converter/data/database.dart';
import 'package:currency_converter/di.dart';
import 'package:currency_converter/theme/app_theme.dart';
import 'package:currency_converter/views/currency_view.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  
  // Load theme preference from database
  final db = locator<AppDatabase>();
  final isDarkMode = await db.isDarkMode();
  
  runApp(MyApp(initialDarkTheme: isDarkMode));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.initialDarkTheme});
  final bool initialDarkTheme;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialDarkTheme ? ThemeMode.dark : ThemeMode.light;
  }

  void _toggleTheme(bool isDark) async {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });

    // Save theme preference to database
    final db = locator<AppDatabase>();
    await db.setDarkMode(isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Currency Freak Offline-First App",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: _themeMode,
      home: CurrencyScreen(onThemeToggle: _toggleTheme),
    );
  }
}


