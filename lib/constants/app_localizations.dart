import 'package:flutter/material.dart';

// Localization delegate
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  // Vietnamese translations
  static const Map<String, String> _viTranslations = {
    // App title
    'app_title': 'Currency Freak Offline-First App',
    
    // Currency screen
    'exchange_rate': 'Tỷ giá Tiền Tệ',
    'loading_rates': 'Đang đồng bộ tỷ giá lần đầu từ Server...',
    'retry_in': 'Ứng dụng sẽ tự động tải lại sau',
    'retry_seconds': 'giây...',
    'retry_now': 'Thử lại ngay',
    'no_internet': 'Không có kết nối Internet',
    'reload': 'Tải lại',
    'light_mode': 'Light Mode',
    'dark_mode': 'Dark Mode',
    'no_data': 'Không có dữ liệu hiển thị.',
    'base_currency': 'Base Currency: USD',
    
    // Input widget
    'from_currency': 'Từ',
    'select': 'Chọn',
    'amount_hint': '0.00',
    
    // Output widget
    'to_currency': 'Đến',
    
    // Converter
    'exchange': 'Tỷ giá tính đơn vị',

    'last_update': 'Cập nhật lần cuối',

    'currency_list':"Danh sách tất cả Tỉ giá Tiền Tệ",
    'view_more': "Xem thêm"
  };

  // English translations
  static const Map<String, String> _enTranslations = {
    // App title
    'app_title': 'Currency Freak Offline-First App',
    
    // Currency screen
    'exchange_rate': 'Exchange Rate',
    'loading_rates': 'Syncing exchange rates for the first time from Server...',
    'retry_in': 'The app will automatically reload after',
    'retry_seconds': 'seconds...',
    'retry_now': 'Retry Now',
    'no_internet': 'No Internet Connection',
    'reload': 'Reload',
    'light_mode': 'Light Mode',
    'dark_mode': 'Dark Mode',
    'no_data': 'No data available.',
    'base_currency': 'Base Currency: USD',
    
    // Input widget
    'from_currency': 'From',
    'select': 'Select',
    'amount_hint': '0.00',
    
    // Output widget
    'to_currency': 'To',
    
    // Converter
    'exchange': 'Exchange Rate',

    'last_update': 'Last Update',
    'currency_list':"List All Currencies",
    'view_more': "View more"
  };

  static final LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('vi', 'VN'));
  }

  String translate(String key) {
    if (locale.languageCode == 'en') {
      return _enTranslations[key] ?? key;
    } else {
      return _viTranslations[key] ?? key;
    }
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['vi', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) {
    return false;
  }
}

// Extension to access translations easily
extension AppLocalizationsExtension on BuildContext {
  String tr(String key) {
    return AppLocalizations.of(this).translate(key);
  }
}


