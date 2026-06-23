part of 'theme_bloc.dart';


abstract class ThemeEvent {}

class InitThemeEvent extends ThemeEvent {}

class ToggleThemeEvent extends ThemeEvent {
  final ThemeMode themeMode;

  ToggleThemeEvent({required this.themeMode});
}