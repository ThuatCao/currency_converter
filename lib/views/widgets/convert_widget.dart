import 'package:currency_converter/constants/color_util.dart';
import 'package:currency_converter/data/database.dart';
import 'package:currency_converter/viewmodels/currency_converter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'input_widget.dart';
import 'output_widget.dart';

class ConvertWidget extends StatefulWidget {
  final bool isDarkMode;
  final List<Currency> currencies;

  const ConvertWidget({
    super.key,
    required this.isDarkMode,
    required this.currencies,
  });

  @override
  State<ConvertWidget> createState() => _ConvertWidgetState();
}

class _ConvertWidgetState extends State<ConvertWidget> {
  late TextEditingController _amountController;
  late TextEditingController _sourceSearchController;
  late TextEditingController _destinationSearchController;
  List<Currency> _filteredSourceCurrencies = [];
  List<Currency> _filteredDestinationCurrencies = [];
  bool _showSourceDropdown = false;
  bool _showDestinationDropdown = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _sourceSearchController = TextEditingController();
    _destinationSearchController = TextEditingController();
    _filteredSourceCurrencies = widget.currencies;
    _filteredDestinationCurrencies = widget.currencies;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _sourceSearchController.dispose();
    _destinationSearchController.dispose();
    super.dispose();
  }

  void _filterSourceCurrencies(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSourceCurrencies = widget.currencies;
      } else {
        _filteredSourceCurrencies = widget.currencies
            .where((currency) =>
                currency.code.toUpperCase().contains(query.toUpperCase()))
            .toList();
      }
    });
  }

  void _filterDestinationCurrencies(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDestinationCurrencies = widget.currencies;
      } else {
        _filteredDestinationCurrencies = widget.currencies
            .where((currency) =>
                currency.code.toUpperCase().contains(query.toUpperCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrencyConverterBloc, CurrencyConverterState>(
      builder: (context, converterState) {
        // Initialize search controllers only once on first successful load
        if (converterState is CurrencyConverterLoaded && !_isInitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_isInitialized) {
              setState(() {
                _sourceSearchController.text = converterState.selectedCurrency;
                _destinationSearchController.text =
                    converterState.destinationCurrency;
                _isInitialized = true;
              });
            }
          });
        }

        return Column(
          children: [
            // ===== CURRENCY CONVERTER SECTION =====
            if (converterState is CurrencyConverterLoaded)
              Builder(
                builder: (context) {
                  final state = converterState;
                  return Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Theme.of(context)
                      //         .primaryColor
                      //         .withValues(alpha: 0.3),
                      //     blurRadius: 8,
                      //     offset: const Offset(0, 4),
                      //   ),
                      // ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ===== INPUT WIDGET =====
                          InputWidget(
                            isDarkMode: widget.isDarkMode,
                            currencies: widget.currencies,
                            sourceSearchController: _sourceSearchController,
                            amountController: _amountController,
                            filteredSourceCurrencies: _filteredSourceCurrencies,
                            showSourceDropdown: _showSourceDropdown,
                            onSourceSearchChanged: (value) {
                              _filterSourceCurrencies(value);
                              setState(() {
                                _showSourceDropdown = true;
                              });
                            },
                            onSourceDropdownToggle: (show) {
                              setState(() {
                                _showSourceDropdown = show;
                              });
                            },
                            onSourceTap: () {
                              Future.delayed(const Duration(milliseconds: 50), () {
                                if (_sourceSearchController.text.isNotEmpty) {
                                  _sourceSearchController.selection = TextSelection.fromPosition(
                                    TextPosition(offset: _sourceSearchController.text.length),
                                  );
                                }
                              });
                              setState(() {
                                _showSourceDropdown = true;
                                _filteredSourceCurrencies =
                                    widget.currencies;
                              });
                            },
                            onAmountChanged: (value) {
                              context
                                  .read<CurrencyConverterBloc>()
                                  .add(
                                    UpdateConversionAmountEvent(
                                      amount: value,
                                    ),
                                  );
                            },
                            onSourceCurrencySelected: (currency) {
                              _sourceSearchController.text = currency.code;
                              context
                                  .read<CurrencyConverterBloc>()
                                  .add(
                                    SelectSourceCurrencyEvent(
                                      currencyCode: currency.code,
                                    ),
                                  );
                              setState(() {
                                _showSourceDropdown = false;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          // Arrow/Exchange Icon
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: widget.isDarkMode
                                    ? neutralDarkColor.withValues(
                                        alpha: 0.2,
                                      )
                                    : neutralColor.withValues(
                                        alpha: 0.2,
                                      ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_downward,
                                color: widget.isDarkMode
                                    ? neutralDarkColor
                                    : neutralColor,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // ===== OUTPUT WIDGET =====
                          OutputWidget(
                            isDarkMode: widget.isDarkMode,
                            currencies: widget.currencies,
                            destinationSearchController:
                                _destinationSearchController,
                            filteredDestinationCurrencies:
                                _filteredDestinationCurrencies,
                            showDestinationDropdown:
                                _showDestinationDropdown,
                            convertedAmount: state.convertedAmount,
                            selectedCurrency: state.selectedCurrency,
                            amount: state.amount,
                            destinationCurrency:
                                state.destinationCurrency,
                            onDestinationSearchChanged: (value) {
                              _filterDestinationCurrencies(value);
                              setState(() {
                                _showDestinationDropdown = true;
                              });
                            },
                            onDestinationDropdownToggle: (show) {
                              setState(() {
                                _showDestinationDropdown = show;
                              });
                            },
                            onDestinationTap: () {
                              Future.delayed(const Duration(milliseconds: 50), () {
                                if (_destinationSearchController.text.isNotEmpty) {
                                  _destinationSearchController.selection = TextSelection.fromPosition(
                                    TextPosition(offset: _destinationSearchController.text.length),
                                  );
                                }
                              });
                              setState(() {
                                _showDestinationDropdown = true;
                                _filteredDestinationCurrencies =
                                    widget.currencies;
                              });
                            },
                            onDestinationCurrencySelected: (currency) {
                              _destinationSearchController.text =
                                  currency.code;
                              context
                                  .read<CurrencyConverterBloc>()
                                  .add(
                                    SelectDestinationCurrencyEvent(
                                      currencyCode: currency.code,
                                    ),
                                  );
                              setState(() {
                                _showDestinationDropdown = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}


