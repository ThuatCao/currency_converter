part of 'theme_bloc.dart';

abstract class ThemeState {}

class ThemeInitial extends ThemeState {}

class ThemeLoaded extends ThemeState {
  final ThemeMode themeMode;

  ThemeLoaded({required this.themeMode});
}
