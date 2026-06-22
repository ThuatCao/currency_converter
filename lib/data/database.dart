import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

// Currencies Table
class Currencies extends Table {
  TextColumn get code => text()();
  TextColumn get name => text().nullable()();
  RealColumn get rate => real()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {code};
}

// Settings Table for app preferences
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Currencies, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          // Create Settings table for new schema version 2
          await m.create(settings);
        }
      },
    );
  }

  Future<void> saveOrUpdateCurrencies(List<Currency> currencyList) async {
    await batch((batch) {
      batch.insertAll(
        currencies,
        currencyList,
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<List<Currency>> getAllCurrencies() {
    return select(currencies).get();
  }

  /// Save or update a setting value
  Future<void> saveSetting(String key, String value) async {
    await into(settings).insert(
      SettingsCompanion(
        key: Value(key),
        value: Value(value),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  /// Get a setting value by key
  Future<String?> getSetting(String key) async {
    final result = await (select(settings)
      ..where((tbl) => tbl.key.equals(key)))
      .getSingleOrNull();
    return result?.value;
  }

  /// Get dark mode preference
  Future<bool> isDarkMode() async {
    final value = await getSetting('isDarkMode');
    return value == 'true';
  }

  /// Save dark mode preference
  Future<void> setDarkMode(bool isDark) async {
    await saveSetting('isDarkMode', isDark.toString());
  }

  /// Get last selected currency
  Future<String?> getLastSelectedCurrency() async {
    return await getSetting('lastSelectedCurrency');
  }

  /// Save last selected currency
  Future<void> setLastSelectedCurrency(String currencyCode) async {
    await saveSetting('lastSelectedCurrency', currencyCode);
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'currency_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}





