import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:currency_converter/constants/app_localizations.dart';

void main() {
  group('AppLocalizations', () {
    test('returns Vietnamese translation for known key', () {
      final loc = AppLocalizations(const Locale('vi', 'VN'));
      expect(loc.translate('exchange_rate'), 'Tỷ giá Tiền Tệ');
    });

    test('returns English translation for known key', () {
      final loc = AppLocalizations(const Locale('en', 'US'));
      expect(loc.translate('exchange_rate'), 'Exchange Rate');
    });

    test('falls back to key when translation missing', () {
      final loc = AppLocalizations(const Locale('vi', 'VN'));
      expect(loc.translate('non_existing_key'), 'non_existing_key');
    });
  });
}

