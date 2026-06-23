import 'package:currency_converter/data/database.dart';
import 'package:currency_converter/viewmodels/currency_bloc.dart';
import 'package:currency_converter/viewmodels/currency_converter_bloc.dart';
import 'package:currency_converter/viewmodels/theme/theme_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:currency_converter/data/dio_client.dart';

final locator = GetIt.instance;

Future<void> setupDependencies() async {
  // Register DioClient as a singleton
  locator.registerSingleton<DioClient>(DioClient());

  locator.registerSingleton<AppDatabase>(AppDatabase());

  locator.registerFactory<CurrencyBloc>(
    () => CurrencyBloc(
      db: locator<AppDatabase>(),
      dioClient: locator<DioClient>(),
    ),
  );

  locator.registerFactory<CurrencyConverterBloc>(
    () => CurrencyConverterBloc(database: locator<AppDatabase>()),
  );
  locator.registerFactory<ThemeBloc>(
    () => ThemeBloc(database: locator<AppDatabase>()),
  );
}
