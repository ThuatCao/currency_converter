import 'package:bloc/bloc.dart';
import 'package:currency_converter/data/database.dart';
import 'package:meta/meta.dart';

part 'currency_converter_event.dart';
part 'currency_converter_state.dart';

class CurrencyConverterBloc
    extends Bloc<CurrencyConverterEvent, CurrencyConverterState> {
  final AppDatabase _database;

  CurrencyConverterBloc({required AppDatabase database})
      : _database = database,
        super(const CurrencyConverterInitial()) {
    on<LoadLastSelectedCurrencyEvent>(_onLoadLastSelectedCurrency);
    on<SelectSourceCurrencyEvent>(_onSelectSourceCurrency);
    on<SelectDestinationCurrencyEvent>(_onSelectDestinationCurrency);
    on<UpdateConversionAmountEvent>(_onUpdateConversionAmount);
  }

  Future<void> _onLoadLastSelectedCurrency(
    LoadLastSelectedCurrencyEvent event,
    Emitter<CurrencyConverterState> emit,
  ) async {
    try {
      final lastCurrency = await _database.getLastSelectedCurrency();
      final selectedCurrency = lastCurrency ?? 'USD';

      // Find the rate of the last selected currency
      final currencyData = event.currencies.firstWhere(
        (c) => c.code == selectedCurrency,
        orElse: () => event.currencies.first,
      );

      emit(
        CurrencyConverterLoaded(
          selectedCurrency: currencyData.code,
          selectedCurrencyRate: currencyData.rate,
          destinationCurrency: 'USD',
          amount: '',
          convertedAmount: 0.0,
          currencies: event.currencies,
        ),
      );
    } catch (e) {
      emit(CurrencyConverterError('Failed to load last selected currency'));
    }
  }

  Future<void> _onSelectSourceCurrency(
    SelectSourceCurrencyEvent event,
    Emitter<CurrencyConverterState> emit,
  ) async {
    try {
      if (state is CurrencyConverterLoaded) {
        final currentState = state as CurrencyConverterLoaded;

        // Find the rate of the selected currency
        final selectedCurr = currentState.currencies.firstWhere(
          (c) => c.code == event.currencyCode,
          orElse: () => currentState.currencies.first,
        );

        // Save to database
        await _database.setLastSelectedCurrency(event.currencyCode);

        // Recalculate conversion
        final convertedAmount =
            _calculateConversion(currentState.amount, selectedCurr.rate, currentState.destinationCurrency, currentState.currencies);

        emit(
          CurrencyConverterLoaded(
            selectedCurrency: selectedCurr.code,
            selectedCurrencyRate: selectedCurr.rate,
            destinationCurrency: currentState.destinationCurrency,
            amount: currentState.amount,
            convertedAmount: convertedAmount,
            currencies: currentState.currencies,
          ),
        );
      }
    } catch (e) {
      emit(CurrencyConverterError('Failed to select currency'));
    }
  }

  Future<void> _onSelectDestinationCurrency(
    SelectDestinationCurrencyEvent event,
    Emitter<CurrencyConverterState> emit,
  ) async {
    try {
      if (state is CurrencyConverterLoaded) {
        final currentState = state as CurrencyConverterLoaded;

        // Recalculate conversion with new destination currency
        final convertedAmount =
            _calculateConversion(currentState.amount, currentState.selectedCurrencyRate, event.currencyCode, currentState.currencies);

        emit(
          CurrencyConverterLoaded(
            selectedCurrency: currentState.selectedCurrency,
            selectedCurrencyRate: currentState.selectedCurrencyRate,
            destinationCurrency: event.currencyCode,
            amount: currentState.amount,
            convertedAmount: convertedAmount,
            currencies: currentState.currencies,
          ),
        );
      }
    } catch (e) {
      emit(CurrencyConverterError('Failed to select destination currency'));
    }
  }

  Future<void> _onUpdateConversionAmount(
    UpdateConversionAmountEvent event,
      Emitter<CurrencyConverterState> emit,
  ) async {
    try {
      if (state is CurrencyConverterLoaded) {
        final currentState = state as CurrencyConverterLoaded;

        // Recalculate conversion with new amount
        final convertedAmount = _calculateConversion(
          event.amount,
          currentState.selectedCurrencyRate,
          currentState.destinationCurrency,
          currentState.currencies,
        );

        emit(
          CurrencyConverterLoaded(
            selectedCurrency: currentState.selectedCurrency,
            selectedCurrencyRate: currentState.selectedCurrencyRate,
            destinationCurrency: currentState.destinationCurrency,
            amount: event.amount,
            convertedAmount: convertedAmount,
            currencies: currentState.currencies,
          ),
        );
      }
    } catch (e) {
      emit(CurrencyConverterError('Failed to update amount'));
    }
  }

  /// Calculate conversion from source currency to destination currency
  double _calculateConversion(
    String amountText,
    double sourceRate,
    String destinationCode,
    List<Currency> currencies,
  ) {
    final amount = double.tryParse(amountText) ?? 0.0;

    if (amount <= 0) {
      return 0.0;
    }

    // Find the destination currency rate
    final destCurrency = currencies.firstWhere(
      (c) => c.code == destinationCode,
      orElse: () => currencies.first,
    );

    // Convert: (amount / sourceRate) * destRate
    // Both rates are against USD, so: amount in USD = amount / sourceRate
    // Then convert USD to destination: (amount / sourceRate) * destRate
    return (amount / sourceRate) * destCurrency.rate;
  }
}

