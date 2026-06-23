// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:currency_converter/constants/app_localizations.dart';

void main() {
  testWidgets('AppLocalizations provides Vietnamese translation in widget tree',
      (WidgetTester tester) async {
    // Build a MaterialApp that uses AppLocalizations as a delegate
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('vi', 'VN'),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('vi', 'VN'), Locale('en', 'US')],
      home: Builder(builder: (context) {
        final text = AppLocalizations.of(context).translate('exchange_rate');
        return Scaffold(body: Center(child: Text(text)));
      }),
    ));

    // Allow localization futures to resolve
    await tester.pumpAndSettle();

    // Expect the Vietnamese translation to be shown
    expect(find.text('Tỷ giá Tiền Tệ'), findsOneWidget);
  });
}
