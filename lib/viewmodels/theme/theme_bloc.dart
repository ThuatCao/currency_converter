import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../data/database.dart';

part 'theme_event.dart';

part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final AppDatabase database;

  ThemeBloc({required this.database}) : super(ThemeInitial()) {
    on<InitThemeEvent>(_onInitTheme);
    on<ToggleThemeEvent>(_onToggleTheme);
  }

  FutureOr<void> _onInitTheme(
    ThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final themeMode = await database.isDarkMode()
        ? ThemeMode.dark
        : ThemeMode.light;
    emit(ThemeLoaded(themeMode: themeMode));
  }

  FutureOr<void> _onToggleTheme(ToggleThemeEvent event, Emitter<ThemeState> emit) async {

    if(event.themeMode == ThemeMode.light){
      await database.setDarkMode(true);
      emit(ThemeLoaded(themeMode: ThemeMode.dark));
    }else{
      await database.setDarkMode(false);
      emit(ThemeLoaded(themeMode: ThemeMode.light));
    }
  }
}
