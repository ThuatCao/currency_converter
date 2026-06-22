import 'package:currency_converter/theme/app_theme.dart';
import 'package:currency_converter/views/currency_view.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // load theme from db if not set light is default
  runApp( MyApp(initialDarkTheme:false,));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key,required this.initialDarkTheme});
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

    //update to save theme to db later
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: _themeMode,
      home: CurrencyView(),
    );
  }
}


