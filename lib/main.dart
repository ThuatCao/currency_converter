import 'package:currency_converter/constants/color_util.dart';
import 'package:currency_converter/data/database.dart';
import 'package:currency_converter/di.dart';
import 'package:currency_converter/theme/app_theme.dart';
import 'package:currency_converter/viewmodels/theme/theme_bloc.dart';
import 'package:currency_converter/views/currency_view.dart';
import 'package:currency_converter/constants/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});


  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeBloc>(
      create: (_) =>
      locator<ThemeBloc>()
        ..add(InitThemeEvent()),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          if(state is ThemeLoaded) {
            return MaterialApp(
              title: "Currency Freak Offline-First App",
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme(),
              darkTheme: AppTheme.darkTheme(),
              themeMode: state.themeMode,
              // Localization setup
              locale: const Locale('vi', 'VN'),
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('vi', 'VN'),
                Locale('en', 'US'),
              ],
              home: CurrencyScreen(),
            );
          } else {
            // Show a loading indicator while the theme is being loaded
            return const MaterialApp(
              home: Scaffold(
                body: Center(child: CircularProgressIndicator(color: primaryColor,)),
              ),
            );
          }
        },
      ),
    );
  }
}


