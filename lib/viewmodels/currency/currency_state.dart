part of 'currency_bloc.dart';


abstract class CurrencyState {}

final class CurrencyInitial extends CurrencyState {}

final class CurrencyFirstLoadProgress extends CurrencyState {}

final class CurrencyFirstLoadFailure extends CurrencyState {
  final String message;
  final int retryCountdown;
  CurrencyFirstLoadFailure({required this.message, required this.retryCountdown});
}

final class CurrencyLoadSuccess extends CurrencyState {
  final List<Currency> currencies;
  final String lastUpdatedText;
  final bool isFromCache;
  CurrencyLoadSuccess({required this.currencies, required this.lastUpdatedText, required this.isFromCache});
}

final class CurrencyAutoRetry extends CurrencyState {
  final int remainingTicks;
  CurrencyAutoRetry(this.remainingTicks);
}