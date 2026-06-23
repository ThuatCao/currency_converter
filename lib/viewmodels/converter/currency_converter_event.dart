part of 'currency_converter_bloc.dart';

@immutable
abstract class CurrencyConverterEvent {
  const CurrencyConverterEvent();
}

class LoadLastSelectedCurrencyEvent extends CurrencyConverterEvent {
  final List<Currency> currencies;

  const LoadLastSelectedCurrencyEvent({required this.currencies});
}

class SelectSourceCurrencyEvent extends CurrencyConverterEvent {
  final String currencyCode;

  const SelectSourceCurrencyEvent({required this.currencyCode});
}

class SelectDestinationCurrencyEvent extends CurrencyConverterEvent {
  final String currencyCode;

  const SelectDestinationCurrencyEvent({required this.currencyCode});
}

class UpdateConversionAmountEvent extends CurrencyConverterEvent {
  final String amount;

  const UpdateConversionAmountEvent({required this.amount});
}

