part of 'currency_converter_bloc.dart';

@immutable
abstract class CurrencyConverterState {
  const CurrencyConverterState();
}

class CurrencyConverterInitial extends CurrencyConverterState {
  const CurrencyConverterInitial();
}

class CurrencyConverterLoaded extends CurrencyConverterState {
  final String selectedCurrency;
  final double selectedCurrencyRate;
  final String destinationCurrency;
  final String amount;
  final double convertedAmount;
  final List<Currency> currencies;

  const CurrencyConverterLoaded({
    required this.selectedCurrency,
    required this.selectedCurrencyRate,
    required this.destinationCurrency,
    required this.amount,
    required this.convertedAmount,
    required this.currencies,
  });
}

class CurrencyConverterError extends CurrencyConverterState {
  final String message;

  const CurrencyConverterError(this.message);
}

